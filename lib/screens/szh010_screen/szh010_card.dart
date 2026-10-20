import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sqb010.dart';
import 'package:projeto_aucs/models/sze010_falta_dias.dart';
import 'package:projeto_aucs/screens/commom/confirmation_dialog.dart';
import 'package:projeto_aucs/screens/szh010_screen/Szh010_tile_list.dart';
import 'package:projeto_aucs/services/sze010_falta_dias_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Szh010Card extends StatefulWidget {
  final Sqb010? sqb010;
  final Function refreshFunction;

  const Szh010Card({
    Key? key,
    this.sqb010,
    required this.refreshFunction,
  }) : super(key: key);

  @override
  State<Szh010Card> createState() => _Szh010CardState();
}

class _Szh010CardState extends State<Szh010Card> {
  Map<String, Sze010FaltaDias> database = {};
  int soma = 0;
  final Srh010FaltaDiasService _srh010FaltaDiasService =
  Srh010FaltaDiasService();
  bool _isloading = false;
  final ScrollController _controller = ScrollController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.refreshFunction();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    if (soma > 0) {
      return SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPanel() {
    return (!_isloading)
          ? ExpansionPanelList(
            dividerColor: Colors.grey,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                this.isExpanded = isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title:
                    Text('${widget.sqb010!.qb_descric
                        .trim()}  -  $soma Colaboradores',
                        style: GoogleFonts.lato(
                          fontSize: 14,

                        ),),
                  );
                },
                body: SizedBox(
                  height: (soma >= 4) ? 300 : 150,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 13.0,
                    controller: _controller,
                    radius: const Radius.circular(20.0),
                    child: ListView(
                      controller: _controller,
                      children: generateListTileSzh010(
                        database: database,
                        depto: widget.sqb010!.qb_depto,
                      ),
                    ),
                  ),
                ),
                isExpanded: isExpanded,
              ),
            ],
          )
        : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
             child: CircularProgressIndicator(),
            ),
          ],
        );
  }

  callAddSqb010Screen(BuildContext context, {Sqb010? sqb010}) {
    Sqb010 internalSqb010 = Sqb010(
      qb_depto: '',
      qb_descric: '',
      r_e_c_n_o_field: 0,
    );

    if (sqb010 != null) {
      internalSqb010 = sqb010;
    }

    Map<String, dynamic> map = {
      'sqb010': internalSqb010,
      'is_editing': sqb010 != null
    };

    Navigator.pushNamed(
      context,
      'edit_sqb010',
      arguments: map,
    ).then((value) {
      widget.refreshFunction();

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

  deleteSze010(BuildContext context) {
    showConfirmationDialog(
      context,
      content:
      "Deseja realmente remover a campanha ${widget.sqb010!.qb_descric} ?",
      affirmativeOption: "Remover",
    ).then((value) {
      if (value != null && value) {
        Sze010Service service = Sze010Service();
        if (widget.sqb010 != null) {
          service.remove(widget.sqb010!.qb_depto).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text((value)
                    ? "Removido com sucesso!"
                    : "Houve um erro ao remover")));
          }).then((value) {
            widget.refreshFunction();
          });
        }
      }
    });
  }

  void getSze010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');

      if (firstName != null && lastName != null) {

        _srh010FaltaDiasService
            .getAll()
            .then((List<Sze010FaltaDias> listSze010FaltaDias) {
          setState(() {
            database = {};
            for (Sze010FaltaDias sze010 in listSze010FaltaDias) {
              database[sze010.ze_nome] = sze010;
            }

            database.forEach((key, value) {
              if (widget.sqb010!.qb_depto.substring(0, 1) == value.ze_depto) {
                soma += 1;
              }
            });

            _isloading = false;

          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}

enum DisposeStatus { exit, error, success }