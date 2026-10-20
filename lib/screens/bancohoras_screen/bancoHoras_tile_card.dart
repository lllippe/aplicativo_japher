import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/spi010.dart';
import 'package:projeto_aucs/screens/commom/confirmation_dialog.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/services/spi010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BancoHorasTileCard extends StatefulWidget {
  final Spi010? spi010;
  final String? nome;
  final int? detail;

  const BancoHorasTileCard({
    Key? key,
    this.spi010,
    this.nome,
    this.detail,
  }) : super(key: key);

  @override
  State<BancoHorasTileCard> createState() => _BancoHorasTileCardState();
}

class _BancoHorasTileCardState extends State<BancoHorasTileCard> {
  String groupUpdate = '';

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spi010!.pi_data != '        ') {
      return (groupUpdate == '1' || groupUpdate == '2')
          ? ListTile(
              title: Text(
                (widget.detail == 1)
                    ? '${widget.spi010!.pi_data.substring(6, 8)}/'
                        '${widget.spi010!.pi_data.substring(4, 6)}/'
                        '${widget.spi010!.pi_data.substring(0, 4)}: '
                        '${widget.spi010!.pi_quant.toString().replaceAll('.', ',')} horas: ${widget.spi010!.pi_justifi.trim()}'
                    : '${widget.spi010!.pi_data.substring(6, 8)}/'
                        '${widget.spi010!.pi_data.substring(4, 6)}/'
                        '${widget.spi010!.pi_data.substring(0, 4)}: '
                        '${widget.spi010!.pi_quant.toString().replaceAll('.', ',')} horas: ${widget.nome}',
                style: GoogleFonts.actor(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              onLongPress: () {})
          : ListTile(
              title: Text(
                (widget.detail == 1)
                    ? '${widget.spi010!.pi_data.substring(6, 8)}/'
                        '${widget.spi010!.pi_data.substring(4, 6)}/'
                        '${widget.spi010!.pi_data.substring(0, 4)}: '
                        '${widget.spi010!.pi_quant.toString().replaceAll('.', ',')} horas - ${widget.spi010!.pi_justifi.trim()}'
                    : '${widget.spi010!.pi_data.substring(6, 8)}/'
                        '${widget.spi010!.pi_data.substring(4, 6)}/'
                        '${widget.spi010!.pi_data.substring(0, 4)}: '
                        '${widget.spi010!.pi_quant.toString().replaceAll('.', ',')} horas - ${widget.nome}',
                style: GoogleFonts.actor(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
    } else {
      return ListTile(
        title: Text(
          'Nenhuma hora cadastrado',
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

  callAddSpi010Screen(BuildContext context) {
    Spi010 internalSqb010 = Spi010(
        pi_mat: widget.spi010!.pi_mat,
        pi_data: widget.spi010!.pi_data,
        pi_pd: widget.spi010!.pi_pd,
        pi_quant: widget.spi010!.pi_quant,
        pi_quantv: widget.spi010!.pi_quantv,
        pi_status: widget.spi010!.pi_status,
        pi_depto: widget.spi010!.pi_depto,
        pi_justifi: widget.spi010!.pi_justifi,
        d_e_l_e_t_field: widget.spi010!.d_e_l_e_t_field,
        r_e_c_n_o_field: widget.spi010!.r_e_c_n_o_field,
        r_e_c_d_e_l_field: widget.spi010!.r_e_c_d_e_l_field);

    Map<String, dynamic> map = {'spi010': internalSqb010, 'is_editing': true};

    Navigator.pushNamed(
      context,
      'edit_spi010',
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

  deleteSpi010(BuildContext context) {
    showConfirmationDialog(
      context,
      content:
          "Deseja realmente remover ${widget.spi010!.pi_quant} horas de ${widget.nome!.trim()} do dia "
          "${widget.spi010!.pi_data}?",
      affirmativeOption: "Remover",
    ).then((value) {
      if (value != null && value) {
        SharedPreferences.getInstance().then((prefs) {
          String? group = prefs.getString('group');
          String? name = prefs.getString('first_name');

          Spi010Service service = Spi010Service();
          if (widget.spi010 != null) {
            Spi010 internalSpi010 = Spi010(
                pi_mat: widget.spi010!.pi_mat,
                pi_data: widget.spi010!.pi_data,
                pi_pd: widget.spi010!.pi_pd,
                pi_quant: widget.spi010!.pi_quant,
                pi_quantv: widget.spi010!.pi_quant,
                pi_status: widget.spi010!.pi_status,
                pi_depto: widget.spi010!.pi_depto,
                pi_justifi: (widget.spi010!.pi_justifi ==
                        "                                                            ")
                    ? 'Exclusão'
                    : widget.spi010!.pi_justifi,
                d_e_l_e_t_field: '*',
                r_e_c_n_o_field: widget.spi010!.r_e_c_n_o_field,
                r_e_c_d_e_l_field: widget.spi010!.r_e_c_n_o_field);

            service
                .edit(widget.spi010!.r_e_c_n_o_field, internalSpi010)
                .then((value) {
              Navigator.pop(context, DisposeStatus.success);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => (name != null && group != null)
                      ? HomeScreen(
                          selectedIndex: 4,
                          name: name,
                          userGroup: group,
                        )
                      : Container(),
                ),
              );
            });
          }
        });
      }
    });
  }

  void getSze010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');

      if (group != null) {
        setState(() {
          groupUpdate = group;
        });
      }
    });
  }
}

enum DisposeStatus { exit, error, success }
