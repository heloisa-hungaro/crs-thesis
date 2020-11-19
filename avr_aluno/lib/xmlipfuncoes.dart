import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

// ---------------------------------------------------------------------------------------------- //

// FILE XML FUNCTIONS

class Conexao {
  String ip;
  String porta;

  Conexao(this.ip, this.porta);
}

class IpXML {
  Directory directory;
  File file;
  Conexao conexao = Conexao('', '');
  // OPEN, WRITE, READ, PARSE

  Future<void> openFile() async {
    directory = await getApplicationDocumentsDirectory();
    file = File("${directory.path}/ip.xml");
  }

  Future<void> _writeToFile(newDoc) async {
    await openFile();
    await file.writeAsString('<?xml version="1.0"?>$newDoc');
  }

  Future<String> _read() async {
    await openFile();
    String fileText = await file.readAsString();
    return fileText;
  }

  Future<xml.XmlDocument> _parseXML() async {
    String xmlText;
    xml.XmlDocument xmlDoc;
    await _read().then((result) {
      xmlText = result;
    });
    try {
      xmlDoc = xml.parse(xmlText);
    } catch (e) {
      print('Erro: $e');
    }
    return xmlDoc;
  }

  Future<void> _buildIpPortNode(ip, port) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('conexao', nest: () {
      builder.element('ip', nest: ('$ip'));
      builder.element('porta', nest: ('$port'));
    });
    xmlDoc = builder.build();
    //print(xmlDoc);
    await _writeToFile(xmlDoc.toString());
  }

  Future<void> saveIpData(ip, port) async {
    await openFile();
    final existsFile = await file.exists();
    if (!existsFile) {
      await file.create();
    }
    await _buildIpPortNode(ip, port);
  }

  Future<void> getIpData() async {
    xml.XmlDocument xmlDoc;
    await _parseXML().then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // conexao
    element = element.firstChild; // ip
    conexao.ip = element.text;
    element = element.nextSibling; // porta
    conexao.porta = element.text;
  }

  Future<bool> checkIfIpFileExists() async {
    await openFile();
    final existsFile = await file.exists();
    if (!existsFile) {
      return false;
    }
    return true;
  }
}
