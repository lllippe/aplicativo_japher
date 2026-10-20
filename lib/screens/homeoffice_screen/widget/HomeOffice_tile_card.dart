import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeOfficeTileCard extends StatefulWidget {
  final String? name;

  const HomeOfficeTileCard({
    Key? key,
    this.name,
  }) : super(key: key);

  @override
  State<HomeOfficeTileCard> createState() => _HomeOfficeTileCardState();
}

class _HomeOfficeTileCardState extends State<HomeOfficeTileCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.name!.trim() != '') {
      return ListTile(
        leading: Icon(
          Icons.emoji_transportation_rounded,
          color: Colors.black.withAlpha(80),
        ),
        title: Text(
          widget.name!,
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
          'Nenhum HomeOffice cadastrado',
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
