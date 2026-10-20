import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sze010.dart';
import '../add_screen/add_sze010_screen.dart';

class Sze010TileCard extends StatefulWidget {
  final Sze010? sze010;
  final depto;

  const Sze010TileCard({
    Key? key,
    this.sze010,
    this.depto,
  }) : super(key: key);

  @override
  State<Sze010TileCard> createState() => _Sze010TileCardState();
}

class _Sze010TileCardState extends State<Sze010TileCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.sze010 != null) {
      return ListTile(
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    callAddSze010Screen(context, sze010: widget.sze010);
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
                    callAddSze010Screen(context, sze010: widget.sze010);
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

  callAddSze010Screen(BuildContext context, {Sze010? sze010}) {
    Sze010 internalSze010 = Sze010(
      ze_mat: '',
      ze_nome: '',
      ze_admissa: '',
      ze_fperaq: '',
      ze_fervenc: '',
      ze_dirferi: '',
      ze_feragen: '',
      ze_diasfer: 0,
      ze_saldfer: 0,
      ze_antefer: '',
      ze_ferpg: '',
      ze_depto: '',
      ze_conveni: '',
      ze_niver: '',
      ze_email: '',
      r_e_c_n_o_field: 0,
    );

    if (sze010 != null) {
      internalSze010 = sze010;
    }

    Map<String, dynamic> map = {
      'sze010': internalSze010,
      'is_editing': sze010 != null
    };

    Navigator.pushNamed(
      context,
      'edit_sze010',
      arguments: map,
    ).then((value) {
      if (value == DisposeStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registro salvo com sucesso."),
          ),
        );
      } else if (value == DisposeStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Houve uma falha ao registar."),
          ),
        );
      }
    });
  }
}
