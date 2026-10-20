import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/solicitacao_screen/solicitacao_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitacoesWarningScreen extends StatefulWidget {
  final Szh010? solicitacoes;
  final String userId;
  final Function refreshFunction;
  final int soma;

  const SolicitacoesWarningScreen({
    Key? key,
    this.solicitacoes,
    required this.userId,
    required this.refreshFunction,
    required this.soma,
  }) : super(key: key);

  @override
  State<SolicitacoesWarningScreen> createState() =>
      _SolicitacoesWarningScreenState();
}

class _SolicitacoesWarningScreenState extends State<SolicitacoesWarningScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.solicitacoes?.zh_mat != '') {
      if (widget.soma == 0) {
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Ver períodos pendentes de aprovação',
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.actor(
                    textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              refresh();
            },
            icon: const Icon(Icons.forward_rounded),
          ),
        );
      } else {
        return ListTile(
          title: Text(
            'Nenhuma solicitação em aberto!',
            textAlign: TextAlign.center,
            style: GoogleFonts.actor(
              textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return ListTile(
        title: Row(
          children: [
            Text(
              'Nenhuma solicitação em aberto!',
              textAlign: TextAlign.center,
              style: GoogleFonts.actor(
                textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      );
    }
  }

  void refresh() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String? group = prefs.getString('group');

      if (firstName != null && lastName != null && group != null) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolicitacaoScreen(
              isloading: true,
              group: group,
            ),
          ),
        );
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
