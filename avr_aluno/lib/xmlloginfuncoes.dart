import 'dart:io';
import 'dart:core';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

// ---------------------------------------------------------------------------------------------- //

// XML LOGIN AND LOGOUT FUNCTIONS

class UserData {
  String email;
  String name;

  UserData(this.email, this.name);
}

class LoginXML {
  Directory directory;
  File file;
  UserData userData = UserData('', '');

  Future<void> openFile(fileName) async {
    directory = await getApplicationDocumentsDirectory();
    file = File("${directory.path}/$fileName.xml");
  }

  Future<String> _read(fileName) async {
    String text;
    await openFile(fileName);
    text = await file.readAsString();
    return text;
  }

  Future<xml.XmlDocument> _parseXML(fileName) async {
    String xmlText;
    xml.XmlDocument xmlDoc;
    await _read(fileName).then((result) {
      xmlText = result;
    });
    try {
      xmlDoc = xml.parse(xmlText);
    } catch (e) {
      print('Erro: $e');
    }
    return xmlDoc;
  }

  Future<void> _writeFile(newDoc) async {
    await openFile('login');
    await file.writeAsString(newDoc);
  }

  Future<void> _buildLogoutNode(email) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('login', nest: () {
      builder.element('logged', nest: ('false'));
      builder.element('email', nest: ('$email'));
    });
    xmlDoc = builder.build();
    await _writeFile(xmlDoc.toString());
  }

  Future<void> writeLoggedOut(email) async {
    await _buildLogoutNode(email);
  }

  Future<void> _buildLoginNode(email) async {
    var builder;
    var xmlDoc;
    builder = new xml.XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('login', nest: () {
      builder.element('logged', nest: ('true'));
      builder.element('email', nest: ('$email'));
    });
    xmlDoc = builder.build();
    await _writeFile(xmlDoc.toString());
  }

  Future<void> createIfDoesntExistsAndWrite(email) async {
    final existsFile = await _checkIfLoginFileExists();
    if (!existsFile) {
      await file.create();
    }
    await _buildLoginNode(email);
  }

  Future<bool> _checkIfLoginFileExists() async {
    await openFile('login');
    final existsFile = await file.exists();
    if (!existsFile) {
      return false;
    }
    return true;
  }

  String _getValue(Iterable<xml.XmlElement> names) {
    var textValue;
    names.map((xml.XmlElement node) {
      textValue = node.text;
    }).toList();
    return textValue;
  }

  Future<String> getUserName(email) async {
    String name;
    xml.XmlDocument xmlDoc;
    await _parseXML(email).then((result) {
      xmlDoc = result;
    });
    xml.XmlElement element;
    element = xmlDoc.rootElement; // documento
    element = element.firstChild; // dados
    name = _getValue(element.findElements("nome"));
    return name;
  }

  Future<bool> isLoggedIn() async {
    xml.XmlDocument xmlLog;
    xml.XmlElement element;
    String email;
    bool fileExists;
    await _checkIfLoginFileExists().then((result) {
      fileExists = result;
    });
    if (fileExists == false) {
      userData.email = '';
      userData.name = '';
      return false;
    } else {
      await _parseXML('login').then((result) {
        xmlLog = result;
      });
      element = xmlLog.rootElement; //login
      element = element.firstChild; // logged
      if (element.text == 'false') {
        userData.email = '';
        userData.name = '';
        return false;
      } else {
        element = element.nextSibling; //email
        email = element.text;
        userData.email = email;
        userData.name = await getUserName(email);
        return true;
      }
    }
  }
}
