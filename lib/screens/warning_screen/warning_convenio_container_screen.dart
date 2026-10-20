import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/convenios.dart';

class ConvenioWarningScreen extends StatefulWidget {
  final Convenios? convenio;
  final String userId;
  final Function refreshFunction;

  const ConvenioWarningScreen({
    Key? key,
    this.convenio,
    required this.userId,
    required this.refreshFunction,
  }) : super(key: key);

  @override
  State<ConvenioWarningScreen> createState() => _ConvenioWarningScreenState();
}

class _ConvenioWarningScreenState extends State<ConvenioWarningScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.convenio?.ze_conveni != '        ') {
      int currentday = DateTime.now().day;
      int currentMonth =
          (int.parse(widget.convenio!.ze_conveni.substring(6, 8)) < currentday)
              ? DateTime.now().month + 1
              : DateTime.now().month;
      return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Não esqueça de enviar o boleto do seu convênio. Vencimento - '
                '${widget.convenio!.ze_conveni.substring(6, 8)}/'
                '${(currentMonth.toString().length == 1) ? currentMonth.toString().padLeft(2, '0') : currentMonth.toString()}/'
                '${DateTime.now().year}',
                overflow: TextOverflow.values.first,
                textAlign: TextAlign.start,
                style: GoogleFonts.actor(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Nenhum convênio cadastrado!',
                overflow: TextOverflow.values.first,
                textAlign: TextAlign.start,
                style: GoogleFonts.actor(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
