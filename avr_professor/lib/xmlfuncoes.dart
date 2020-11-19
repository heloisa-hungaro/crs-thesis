import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:tuple/tuple.dart';

// ---------------------------------------------------------------------------------------------- //

// FILE XML FUNCTIONS

class FileXML {
  Directory directory;
  File file;

  List<Tuple2> contAcertos = [];
  List<Tuple2> _listAlunosQuestao = [];

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

  Future<List> getListPlotTurma(turmaName, email) async {
    List<Tuple2> list = [];
    double percentage;
    String datahora = '';
    int countAlunos = 0;
    int acertos = 0;
    String correta = '';
    contAcertos.clear();

    xml.XmlElement element;
    await findTurmaElement(turmaName, email).then((result) {
      element = result;
    });
    element = element.firstChild; //nome turma

    while (element.nextSibling != null) {
      countAlunos = 0;
      acertos = 0;
      element = element.nextSibling; // questao
      element = element.firstChild; // data
      datahora = element.text;
      element = element.nextSibling; //hora
      datahora = '$datahora às ${element.text}';
      element = element.nextSibling; //alternativas
      element = element.nextSibling; //correta
      correta = element.text;
      element = element.parent; // questao
      var elementEscolha = element.findAllElements("escolha");
      elementEscolha.forEach((k) {
        countAlunos++;
        if (correta == k.text) {
          acertos++;
        }
      });
      percentage = num.parse((100 * acertos / countAlunos).toStringAsFixed(2));
      contAcertos.add(
          Tuple2<String, String>(acertos.toString(), countAlunos.toString()));
      list.add(Tuple2<String, double>('$datahora', percentage));
    }
    return list;
  }

  Future<List> getListAlunosQuestao() async {
    _listAlunosQuestao.sort((a, b) => (a.item2).compareTo(b.item2));
    for (var i = 0; i < _listAlunosQuestao.length - 1; i++) {
      if (_listAlunosQuestao[i].item2 != _listAlunosQuestao[i + 1].item2) {
        continue;
      }
      if (_listAlunosQuestao[i]
              .item1
              .compareTo(_listAlunosQuestao[i + 1].item1) >
          0) {
        var aux = _listAlunosQuestao[i];
        _listAlunosQuestao[i] = _listAlunosQuestao[i + 1];
        _listAlunosQuestao[i + 1] = aux;
      }
    }
    return _listAlunosQuestao;
  }

  Future<List> getListPlotQuestaoTurma(turmaName, questaoName, email) async {
    List<int> list = [];
    xml.XmlElement element;
    int alternativas;
    String correta;
    _listAlunosQuestao.clear();

    await findQuestaoElement(turmaName, questaoName, email).then((result) {
      element = result;
    });
    element = element.firstChild; //data
    element = element.nextSibling; // hora
    element = element.nextSibling; // alternativas
    alternativas = int.parse(element.text);
    element = element.nextSibling; // correta
    correta = element.text;
    list.length = alternativas + 1;
    list[alternativas] = int.parse(correta);
    for (var i = 0; i < alternativas; i++) {
      list[i] = 0;
    }
    String aluno;
    String escolha;
    while (element.nextSibling != null) {
      //aluno
      element = element.nextSibling;
      element = element.firstChild; // //emailaluno
      element = element.nextSibling; // nomealuno
      aluno = element.text;
      element = element.nextSibling; //escolha
      escolha = element.text;
      list[int.parse(escolha) - 1]++;
      escolha = String.fromCharCode(64 + int.parse(escolha));
      _listAlunosQuestao.add(Tuple2<String, String>(aluno, escolha));
      element = element.parent;
    }
    return list;
  }

  Future<List> getListPlotAlunoTurma(turmaName, alunoEmail, email) async {
    List<Tuple2> list = [];
    double percentage;
    String datahora = '';
    int questoes = 0;
    int acertos = 0;
    String correta;
    bool _found = false;

    xml.XmlElement element;
    await findTurmaElement(turmaName, email).then((result) {
      element = result;
    });

    element = element.firstChild; //nome turma
    while (element.nextSibling != null) {
      element = element.nextSibling; // questao
      element = element.firstChild; // data
      datahora = element.text;
      element = element.nextSibling; //hora
      datahora = '$datahora às ${element.text}';
      element = element.nextSibling; //alternativas
      element = element.nextSibling; //correta
      correta = element.text;
      _found = false;
      while (element.nextSibling != null && _found == false) {
        element = element.nextSibling; // aluno
        element = element.firstChild; //emailaluno
        if (element.text == alunoEmail) {
          element = element.nextSibling; //nomealuno
          element = element.nextSibling; //escolhida

          if (correta == element.text) {
            acertos++;
          }
          questoes++;
          _found = true;
        }
        element = element.parent; // aluno
      }
      element = element.parent; // questionario
      if (_found == true) {
        percentage = num.parse((100 * acertos / questoes).toStringAsFixed(2));
        list.add(Tuple2<String, double>(datahora, percentage));
      }
    }
    //print(list);
    return list;
  }

  Future<List> getAlunosTurma(turmaName, email) async {
    xml.XmlElement element;
    element = await findTurmaElement(turmaName, email);
    var dadosAlunos = new Map();
    var alunos = element.findAllElements("nomealuno");
    var emails = element.findAllElements("emailaluno");
    List<String> listAlunos = [];
    List<String> listEmails = [];
    alunos.forEach((k) => listAlunos.add(k.text));
    emails.forEach((k) => listEmails.add(k.text));

    for (var i = 0; i < alunos.length; i++) {
      if (listAlunos[i] != 'Anônimo') {
        dadosAlunos[listEmails[i]] = listAlunos[i];
      }
    }

    List<Tuple2> list = new List();
    dadosAlunos.forEach((k, v) {
      list.add(Tuple2<String, String>(k, v));
    });
    list.sort((a, b) => (a.item2).compareTo((b.item2)));
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
    //print('${directory.path}/$email.xml');
    if (!existsFile) {
      await file.create();
      await _buildDadosNode(email, userName);
    }
  }

  // SAVE NEW QUESTION WHEN ANSWERED
  Future<String> _buildNewQuestion(
      turma, data, hora, numAlt, correta, mapAlunos, novaTurma) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    if (novaTurma) {
      builder.element('turma', nest: () {
        builder.element('nometurma', nest: ('$turma'));
        builder.element('questao', nest: () {
          builder.element('data', nest: ('$data'));
          builder.element('hora', nest: ('$hora'));
          builder.element('alternativas', nest: ('$numAlt'));
          builder.element('correta', nest: ('$correta'));
          mapAlunos.forEach((k, v) {
            builder.element('aluno', nest: () {
              builder.element('emailaluno', nest: ('$k'));
              builder.element('nomealuno', nest: ('${v.item1}'));
              builder.element('escolha', nest: ('${v.item2}'));
            });
          });
        });
      });
    } else {
      builder.element('questao', nest: () {
        builder.element('data', nest: ('$data'));
        builder.element('hora', nest: ('$hora'));
        builder.element('alternativas', nest: ('$numAlt'));
        builder.element('correta', nest: ('$correta'));
        mapAlunos.forEach((k, v) {
          builder.element('aluno', nest: () {
            builder.element('emailaluno', nest: ('$k'));
            builder.element('nomealuno', nest: ('${v.item1}'));
            builder.element('escolha', nest: ('${v.item2}'));
          });
        });
      });
    }
    xmlDoc = builder.build();
    return xmlDoc.toString();
  }

  Future<void> _addNewNode(email, newNode, novaTurma, turmaName) async {
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
          element = element.firstChild; // nometurma
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
      email, turma, data, hora, numAlt, correta, mapAlunos) async {
    if (mapAlunos.isEmpty) {
      return; // nenhum aluno respondeu. questão não será salva!
    }
    bool novaTurma;
    String newNode;
    xml.XmlElement element;
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
    await _buildNewQuestion(turma, data, hora, numAlt.toString(),
            correta.toString(), mapAlunos, novaTurma)
        .then((result) async {
      newNode = result;
      await _addNewNode(email, newNode, novaTurma, turma).then((_) {});
    });
  }
}
