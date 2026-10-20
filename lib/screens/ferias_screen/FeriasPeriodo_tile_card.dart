import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/srh010.dart';

class FeriasPeriodoTileCard extends StatefulWidget {
  final Srh010? srh010;

  const FeriasPeriodoTileCard({
    Key? key,
    this.srh010,
  }) : super(key: key);

  @override
  State<FeriasPeriodoTileCard> createState() => _FeriasPeriodoTileCardState();
}

class _FeriasPeriodoTileCardState extends State<FeriasPeriodoTileCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.srh010!.rh_dataini != '        ') {
      return ListTile(
        title: Text(
          '${widget.srh010!.rh_dataini.substring(6, 8)}/'
          '${widget.srh010!.rh_dataini.substring(4, 6)}/'
          '${widget.srh010!.rh_dataini.substring(0, 4)} a '
          '${widget.srh010!.rh_datafim.substring(6, 8)}/'
          '${widget.srh010!.rh_datafim.substring(4, 6)}/'
          '${widget.srh010!.rh_datafim.substring(0, 4)} - '
          '${widget.srh010!.rh_dferias.round()} dias',
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
          'Nenhum Período Cadastrado',
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
