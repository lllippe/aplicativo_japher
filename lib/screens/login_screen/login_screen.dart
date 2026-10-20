import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/app_version.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/exception_dialog.dart';
import 'package:projeto_aucs/services/app_version_service.dart';
import 'package:projeto_aucs/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool _passwordVsible = false;
  bool isButtonReleased = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(top: 10),
        margin: const EdgeInsets.all(16),
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    child: Image.asset(
                      'assets/images/robot.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "Japher Assessoria Contábil",
                    style: GoogleFonts.actor(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("por FrPelissari",
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(thickness: 2),
                  ),
                  const Text("Entre"),
                  SizedBox(
                    width: screenWidth - 60,
                    child: AutofillGroup(
                      child: TextFormField(
                        autofillHints: const [AutofillHints.username],
                        controller: _emailController,
                        decoration: const InputDecoration(
                          label: Text("Usuário"),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth - 60,
                    child: AutofillGroup(
                      child: TextFormField(
                        autofillHints: const [AutofillHints.password],
                        controller: _passwordController,
                        decoration: InputDecoration(
                          label: const Text("Senha"),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _passwordVsible = !_passwordVsible;
                              });
                            },
                            icon: Icon(
                              _passwordVsible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        maxLength: 16,
                        obscureText: _passwordVsible
                            ? false
                            : true,
                      ),
                    ),
                  ),
                  (isButtonReleased)
                  ? Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isButtonReleased = false;
                        });
                        tryLogin(context);
                      },
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'Continuar',
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(fontSize: 20),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.black.withAlpha(50)
                                ),
                                child: const Icon(
                                  Icons.chevron_right_rounded, 
                                  size: 30, 
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                    : 
                    InkWell(
                      onTap: () {
                          ErrorDialog(context, 'Aguarde o processamento.');
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'Aguarde',
                                      style: GoogleFonts.actor(
                                        textStyle: const TextStyle(fontSize: 20),
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void changeVisible(BuildContext context) {
    _passwordVsible = !_passwordVsible;
  }

  void tryLogin(BuildContext context) {
    String email = _emailController.text;
    String password = _passwordController.text;

    authService.login(email, password).then((token) {
      Navigator.pushReplacementNamed(context, 'transfer');
    }).catchError((e) {
      setState(() {
        isButtonReleased = true;  
      });
      ErrorDialog(context, 'Usuário não cadastrado');
    }, test: (e) => e is UserNotFoundException).catchError((e) {
      setState(() {
        isButtonReleased = true;  
      });
      showExceptionDialog(context,
          content:
              "O servidor demorou para responder, tente novamente mais tarde.");
    }, test: (e) => e is TimeoutException);
  }
}
