import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sze010_falta_dias.dart';
import 'package:projeto_aucs/screens/add_screen/add_szh010_screen.dart';

class Szh010TileCard extends StatefulWidget {
  final Sze010FaltaDias? sze010;
  final depto;

  const Szh010TileCard({
    Key? key,
    this.sze010,
    this.depto,
  }) : super(key: key);

  @override
  State<Szh010TileCard> createState() => _Szh010TileCardState();
}

class _Szh010TileCardState extends State<Szh010TileCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.sze010 != null) {
      return ListTile(
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSzh010Screen(
                          sze010: widget.sze010!,
                          createAppBar: true,
                        ),
                      ),
                    ); //callAddSzh010Screen(context, sze010: widget.sze010);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                  child: Icon(
                    Icons.edit,
                    size: 25,
                    color: Colors.black.withAlpha(80),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSzh010Screen(
                          sze010: widget.sze010!,
                          createAppBar: true,
                        ),
                      ),
                    ); //callAddSzh010Screen(context, sze010: widget.sze010);
                  });
                },
                child: Text(
                  widget.sze010!.ze_nome.trim(),
                  style: GoogleFonts.actor(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    } else {
      return const ListTile(
        title: Text('Nenhum colaborador Cadastrado'),
      );
    }
  }
}
