import 'dart:io';
import 'package:tuple/tuple.dart';
import 'package:date_format/date_format.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

// ---------------------------------------------------------------------------------------------- //

// FILE XML FUNCTIONS

class FileXML {
  Directory directory;
  File file;

  String _prof = '';
  int _acertos = 0;
  int _questoes = 0;

  // OPEN, WRITE, READ, PARSE

  Future<void> openFile(email) async {
    directory = await getApplicationDocumentsDirectory();
    file = File("${directory.path}/$email.xml");
  }

  Future<void> _writeToFile(newDoc, email) async {
    await openFile(email);
    await file.writeAsString('<?xml version="1.0"?>$newDoc');
  }

  Future<String> _read(email) async {
    await openFile(email);
    String fileText = await file.readAsString();
    return fileText;
  }

  Future<xml.XmlDocument> _parseXML(email) async {
    String xmlText;
    xml.XmlDocument xmlDoc;
    await _read(email).then((result) {
      xmlText = result;
    });
    try {
      xmlDoc = xml.parse(xmlText);
    } catch (e) {
      print('Erro: $e');
    }
    return xmlDoc;
  }

  // turmas

  Future<List> getTurmas(email) async {
    xml.XmlDocument xmlDoc;
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    var turmas = element.findAllElements("nometurma");
    List<String> list = new List();
    turmas.forEach((k) => list.add(k.text));
    list.sort((a, b) => a.compareTo(b));
    return list;
  }

  Future<xml.XmlElement> findTurmaElement(turmaName, email) async {
    xml.XmlDocument xmlDoc;
    xml.XmlElement elementTurma;
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    var turmas = element.findAllElements("nometurma");
    turmas.forEach((k) {
      if (k.text == turmaName) {
        elementTurma = k;
      }
    });
    if (elementTurma == null) {
      return null;
    }
    return elementTurma.parent;
  }

  Future<void> removeTurma(turmaName, email) async {
    xml.XmlDocument xmlDoc;
    String newDoc = '';
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    newDoc = '$newDoc<${element.name.toString()}>';
    element = element.firstChild;
    do {
      if (element.name.toString() == 'turma' &&
          element.firstChild.text == turmaName) {
        if (element.nextSibling == null) {
          element = element.parent;
          newDoc = '$newDoc<\/${element.name.toString()}>';
          break;
        } else {
          element = element.nextSibling;
        }
      }
      newDoc = '$newDoc<${element.name.toString()}>';
      if (element.firstChild.nodeType == xml.XmlNodeType.TEXT) {
        if (element.text.trim().isNotEmpty) {
          newDoc = '$newDoc${element.text.toString()}';
          newDoc = '$newDoc<\/${element.name.toString()}>';
        }
        if (element.nextSibling == null) {
          while (element.parent.nextSibling == null) {
            element = element.parent;
            newDoc = '$newDoc<\/${element.name.toString()}>';
            if (element.name.toString() == 'documento') {
              break;
            }
          }
          if (element.name.toString() == 'documento') {
            break;
          }
          element = element.parent;
          newDoc = '$newDoc<\/${element.name.toString()}>';
          element = element.nextSibling;
        } else {
          element = element.nextSibling;
        }
      } else {
        element = element.firstChild;
      }
    } while (element.name.toString() != 'documento');
    await _writeToFile(newDoc, email);
  }

  // questao

  Future<xml.XmlElement> findQuestaoElement(
      turmaName, questaoName, email) async {
    xml.XmlElement elementTurma;

    await findTurmaElement(turmaName, email).then((result) {
      elementTurma = result;
    });
    if (elementTurma == null) {
      return null;
    }
    var datas;
    var horas;
    datas = elementTurma.findAllElements("data");
    horas = elementTurma.findAllElements("hora");
    List<xml.XmlElement> listDatas = datas.toList();
    List<xml.XmlElement> listHoras = horas.toList();
    String questao;
    for (var i = 0; i < listDatas.length; i++) {
      questao = "${listDatas[i].text} às ${listHoras[i].text}";
      if (questao == questaoName) {
        return listDatas[i].parent;
      }
    }
    return null;
  }

  // plots

  Future<String> getProfessor() async {
    return _prof;
  }

  Future<String> getAcertos() async {
    return '$_acertos de $_questoes';
  }

  bool _addBasedInTime(data, hora, dataAgora, horaAgora) {
    if (data != dataAgora) {
      // dias diferentes
      return true;
    }
    int difHora =
        int.parse(horaAgora.substring(0, 2)) - int.parse(hora.substring(0, 2));
    if ((difHora > 1)) {
      // mais de 1h de diferença
      return true;
    }
    int min = int.parse(hora.substring(3, 5));
    int minA = int.parse(horaAgora.substring(3, 5));
    if ((difHora == 0) && (minA - min > 30)) {
      // mais de 30 min de dif, mesma hora
      return true;
    }
    if ((difHora == 1) && (60 - min + minA > 30)) {
      // mais de 30 min de dif, hora já mudou
      return true;
    }
    return false;
  }

  Future<List> getListPlotTurma(turmaName, email) async {
    List<Tuple2> list = [];
    double percentage;
    String data = '';
    String hora = '';
    String datahora = '';
    int questoes = 0;
    int acertos = 0;
    bool addNext;
    DateTime agora = new DateTime.now();
    String dataAgora = formatDate(agora, [dd, '\/', mm, '\/', yy]);
    String horaAgora = formatDate(agora, [HH, ':', nn]);

    xml.XmlElement element;
    await findTurmaElement(turmaName, email).then((result) {
      element = result;
    });
    element = element.firstChild; //nome turma
    element = element.nextSibling; // professor
    _prof = element.text;
    while (element.nextSibling != null) {
      element = element.nextSibling; // questao
      element = element.firstChild; // data
      data = element.text;
      element = element.nextSibling; //hora
      hora = element.text;
      element = element.nextSibling; //acertou
      if (element.text.length == 2) {
        addNext = _addBasedInTime(data, hora, dataAgora, horaAgora);
      } else {
        addNext = true;
      }
      if (addNext) {
        if (int.parse(element.text[0]) == 1) {
          //acertou = TRUE
          acertos++;
        }
        questoes++;
        percentage = num.parse((100 * acertos / questoes).toStringAsFixed(2));
        _acertos = acertos;
        _questoes = questoes;
        datahora = '$data às $hora';
        list.add(Tuple2<String, double>('$datahora', percentage));
      }
      element = element.parent;
    }
    return list;
  }

  // get / change user name

  String _getValue(Iterable<xml.XmlElement> names) {
    //getValue from single node <___>
    var textValue;
    names.map((xml.XmlElement node) {
      textValue = node.text;
    }).toList();
    return textValue;
  }

  Future<String> getUserName(email) async {
    xml.XmlDocument xmlDoc;
    String name;
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    element = element.firstChild; // dados
    name = _getValue(element.findElements("nome"));
    return name;
  }

  Future<void> changeUserName(newName, email) async {
    xml.XmlDocument xmlDoc;
    String newDoc = '<?xml version="1.0"?>';
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    newDoc = '$newDoc<documento>';
    newDoc = '$newDoc<dados>';
    newDoc = '$newDoc<nome>$newName<\/nome>';
    newDoc = '$newDoc<email>$email<\/email>';
    newDoc = '$newDoc<\/dados>';
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    element = element.firstChild; // dados
    // adiciona as turmas
    while (element.nextSibling != null) {
      element = element.nextSibling;
      newDoc = '$newDoc${element.toString()}';
    }
    newDoc = '$newDoc<\/documento>';
    await _writeToFile(newDoc, email);
  }

  // if file still doesnt exists, create!!

  Future<void> _buildDadosNode(email, userName) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('documento', nest: () {
      builder.element('dados', nest: () {
        builder.element('nome', nest: ('$userName'));
        builder.element('email', nest: ('$email'));
      });
    });
    xmlDoc = builder.build();
    await _writeToFile(xmlDoc.toString(), email);
  }

  Future<void> createIfDoesntExists(email, userName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$email.xml');
    final existsFile = await file.exists();
    if (!existsFile) {
      await file.create();
      await _buildDadosNode(email, userName);
    }
  }

  // SAVE NEW QUESTION WHEN ANSWERED
  Future<String> _buildNewQuestion(
      turma, professor, data, hora, acertou, novaTurma) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    if (novaTurma) {
      builder.element('turma', nest: () {
        builder.element('nometurma', nest: ('$turma'));
        builder.element('professor', nest: ('$professor'));
        builder.element('questao', nest: () {
          builder.element('data', nest: ('$data'));
          builder.element('hora', nest: ('$hora'));
          builder.element('acertou', nest: ('$acertou'));
        });
      });
    } else {
      builder.element('questao', nest: () {
        builder.element('data', nest: ('$data'));
        builder.element('hora', nest: ('$hora'));
        builder.element('acertou', nest: ('$acertou'));
      });
    }
    xmlDoc = builder.build();
    return xmlDoc.toString();
  }

  Future<void> _addNewNode(
      email, newNode, novaTurma, turmaName, professor) async {
    xml.XmlDocument xmlDoc;
    String newDoc = '<?xml version="1.0"?>';
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    newDoc = '$newDoc<documento>';
    element = element.firstChild; // dados
    newDoc = '$newDoc${element.toString()}';
    if (novaTurma) {
      while (element.nextSibling != null) {
        element = element.nextSibling; // proxima turma
        newDoc = '$newDoc${element.toString()}';
      }
      // já adicionou todas as turmas, agora insere a nova
      newDoc = '$newDoc$newNode';
    } else {
      // adiciona as turmas
      while (element.nextSibling != null) {
        element = element.nextSibling; // proxima turma
        if (element.firstChild.text == turmaName) {
          // se for a turma da questao, adiciona diferente
          newDoc = '$newDoc<turma>';
          newDoc = '$newDoc<nometurma>$turmaName<\/nometurma>';
          newDoc = '$newDoc<professor>$professor<\/professor>';
          element = element.firstChild; // nometurma
          element = element.nextSibling; //professor
          while (element.nextSibling != null) {
            element = element.nextSibling; // proxima questao
            newDoc = '$newDoc${element.toString()}';
          }
          element = element.parent;
          // já adicionou todas as questoes, agora insere a nova
          newDoc = '$newDoc$newNode';
          newDoc = '$newDoc<\/turma>';
        } else {
          // senao adiciona a turma como está
          newDoc = '$newDoc${element.toString()}';
        }
      }
    }
    newDoc = '$newDoc<\/documento>';
    await _writeToFile(newDoc, email);
  }

  Future<void> saveNewQuestion(
      email, turma, professor, data, hora, acertou) async {
    String questao = "$data às $hora";
    bool novaTurma;
    String newNode;
    xml.XmlElement element;
    await findQuestaoElement(turma, questao, email).then((result) {
      element = result;
    });
    if (element != null) {
      return; // a questão já foi respondida! dados novos não serão salvos
    }
    // questao ainda não foi respondida...
    await findTurmaElement(turma, email).then((result) {
      element = result;
    });
    if (element == null) {
      // a turma ainda não existe, tem que criar
      novaTurma = true;
    } else {
      // a turma já existe! basta criar node da questão
      novaTurma = false;
    }
    await _buildNewQuestion(turma, professor, data, hora, acertou, novaTurma)
        .then((result) async {
      newNode = result;
      await _addNewNode(email, newNode, novaTurma, turma, professor)
          .then((_) {});
    });
  }
}
