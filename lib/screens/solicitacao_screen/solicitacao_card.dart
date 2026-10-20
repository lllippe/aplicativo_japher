import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/solicitacao_screen/solicitacao_tile_list.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/services/szh010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitacaoCard extends StatefulWidget {
  final Sze010? sze010;
  final Szh010? szh010;


  const SolicitacaoCard({
    Key? key,
    this.sze010,
    this.szh010,
  }) : super(key: key);

  @override
  State<SolicitacaoCard> createState() => _SolicitacaoCardState();
}

class _SolicitacaoCardState extends State<SolicitacaoCard> {
  Map<int, Szh010> database = {};
  int soma = 0;
  final Szh010Service _szh010Service = Szh010Service();
  final Sze010Service _sze010service = Sze010Service();
  final ScrollController _controller = ScrollController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    if (soma > 0) {
      return SingleChildScrollView(
        controller: _controller,
        child: Container(
          child: _buildPanel(),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
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
              title: Text(widget.sze010!.ze_nome.trim()),
            );
          },
          body: SizedBox(
            height: (soma >= 4) ? 300 : 150,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _controller,
              thickness: 13.0,
              radius: const Radius.circular(20.0),
              child: ListView(
                children: generateListTileSolicitacao(
                  database: database,
                  matricula: widget.sze010!.ze_mat,
                ),
              ),
            ),
          ),
          isExpanded: isExpanded,
        ),
      ],
    );
  }

  void getSze010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String? group = prefs.getString('group');
      String? userId = prefs.getString('id');

      if (firstName != null &&
          lastName != null &&
          group != null &&
          userId != null) {
        _sze010service.getId(userId).then((List<Sze010> listSze010) {
          setState(() {
            for (Sze010 sze010 in listSze010) {
              if (userId == sze010.ze_mat) {
                _szh010Service
                    .getGroup(int.parse(sze010.ze_depto), int.parse(group))
                    .then((List<Szh010> listSzh010) {
                  setState(() {
                    database = {};
                    for (Szh010 szh010 in listSzh010) {
                      database[szh010.r_e_c_n_o_field] = szh010;
                    }

                    database.forEach((key, value) {
                      if (widget.sze010!.ze_mat == value.zh_mat) {
                        soma += 1;
                      }
                    });
                  });
                });
              }
            }
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
