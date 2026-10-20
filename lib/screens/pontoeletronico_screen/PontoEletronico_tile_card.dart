import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sp8010.dart';

class PontoEletronicoTileCard extends StatefulWidget {
  final Sp8010? sp8010;

  const PontoEletronicoTileCard({
    Key? key,
    this.sp8010,
  }) : super(key: key);

  @override
  State<PontoEletronicoTileCard> createState() => _PontoEletronicoTileCardState();
}

class _PontoEletronicoTileCardState extends State<PontoEletronicoTileCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.sp8010!.p8_data != '        ') {
      return ListTile(
        title: Text(
          'Horário do Registro: ${widget.sp8010!.p8_hora.toString().replaceAll('.', ':')} hrs',
          style: GoogleFonts.actor(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      return ListTile(
        title: Text(
          'Nenhum ponto cadastrado',
          style: GoogleFonts.actor(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
  }
}
