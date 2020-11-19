// developed by Heloisa Hungaro - heloisa.hungaro@gmail.com
// 05-2019

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './buildpatterns.dart';
import './xmlfuncoes.dart';
import './xmlloginfuncoes.dart';
import './pagesobre.dart';
import './pageconfiguracoes.dart';
import './pagequestionario.dart';
import './pageestatisticas.dart';

// ---------------------------------------------------------------------------------------------- //

// VAR

final GoogleSignIn _googleSignIn = GoogleSignIn();
bool userLogged;
FileXML file = FileXML();
LoginXML loginFile = LoginXML();
String userEmail = '';
String userName = '';

// ---------------------------------------------------------------------------------------------- //

// MAIN

void main() async {
  await loginFile.isLoggedIn().then((result) {
    userLogged = result;
    userEmail = loginFile.userData.email;
    userName = loginFile.userData.name;
  });
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: 'Avaliação Rápida Aluno',
      routes: {
        '/home': (BuildContext context) => new Home(),
        '/sobre': (BuildContext context) => new Sobre(),
        '/configuracoes': (BuildContext context) =>
            new Configuracoes(email: userEmail),
        '/questionario': (BuildContext context) =>
            new Questionario(email: userEmail),
        '/estatisticas': (BuildContext context) =>
            new Estatisticas(email: userEmail),
      },
    ));
  });
}

// ---------------------------------------------------------------------------------------------- //

// HOME

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool loading = false;

  bool userCanceledLogin = false;

  @override
  initState() {
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userLogged == true) {
      return new Questionario(email: userEmail);
    }

    Widget buttonSection = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildButton('LOGIN COM CONTA GOOGLE', () async {
            bool success;
            setState(() {
              loading = true;
              animationController.repeat();
            });
            await _signInWithGoogle().then((result) {
              if (!userCanceledLogin) {
                success = result;
                if (success == true) {
                  Navigator.popAndPushNamed(context, '/questionario');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: Text("Erro ao efetuar login"),
                        content:
                            new Text("Verifique sua conexão com a internet."),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }
              setState(() {
                loading = false;
                animationController.stop(canceled: true);
              });
            });
          }),
          buildButton('ANÔNIMO', () {
            userEmail = 'anonimo';
            userName = 'Anônimo';
            Navigator.pushNamed(context, '/questionario');
          }),
          buildButton('SOBRE', () {
            Navigator.pushNamed(context, '/sobre');
          }),
        ],
      ),
    );

    Widget logoSection = Container(
      padding: const EdgeInsets.all(20),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Image.asset(
          'images/logo_avr.png',
          width: 315,
          height: 261,
          fit: BoxFit.scaleDown,
        ),
        Text(
          'Módulo Aluno',
          style: TextStyle(fontSize: 30, color: Colors.blueAccent),
        ),
      ]),
    );

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: loading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Buscando login Google...',
                        style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: animationController,
                      child: new Container(
                        height: 150.0,
                        width: 150.0,
                        child: Icon(Icons.rotate_right),
                      ),
                      builder: (BuildContext context, Widget _widget) {
                        return new Transform.rotate(
                          angle: animationController.value * 6.3,
                          child: _widget,
                        );
                      },
                    ),
                  ]),
            )
          : // not loading!
          Center(
              child: Column(children: [
                Expanded(
                  flex: 2,
                  child: logoSection,
                ),
                Expanded(
                  child: buttonSection,
                ),
              ]),
            ),
    );
  }

  Future<bool> _signInWithGoogle() async {
    try {
      userCanceledLogin = false;
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        userCanceledLogin = true;
        return false;
      }
      userLogged = true;
      userEmail = googleUser.email;
      userName = googleUser.displayName;
      await file.createIfDoesntExists(userEmail, userName);
      await loginFile.createIfDoesntExistsAndWrite(userEmail);
      _googleSignIn.disconnect();
      return true;
    } catch (e) {
      return false;
    }
  }
}
