import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/periodos.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/screens/ferias_screen/feriasPeriodo_tile_list.dart';
import 'package:projeto_aucs/services/srh010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeriasPeriodoCard extends StatefulWidget {
  final Periodos? periodos;

  const FeriasPeriodoCard({
    Key? key,
    this.periodos,
  }) : super(key: key);

  @override
  State<FeriasPeriodoCard> createState() => _FeriasPeriodoCardState();
}

class _FeriasPeriodoCardState extends State<FeriasPeriodoCard> {
  final Srh010Service _feriasColaboradorService = Srh010Service();
  Map<String, Srh010> databasePeriodosColaborador = {};
  int soma = 0;
  final ScrollController _controller = ScrollController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      );
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
              title: Text('Periodo de - ${widget.periodos!.rf_databas.substring(6, 8)}/'
                  '${widget.periodos!.rf_databas.substring(4, 6)}/'
                  '${widget.periodos!.rf_databas.substring(0, 4)}'),
            );
          },
          body: SizedBox(
            height: (soma >= 4) ? 300 : 150,
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              thickness: 13.0,
              radius: const Radius.circular(20.0),
              child: ListView(
                controller: _controller,
                children: generateListTileFeriasPeriodo(
                  database: databasePeriodosColaborador,
                  depto: widget.periodos!.rf_mat,
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

      if (firstName != null && lastName != null) {
        _feriasColaboradorService
            .getAll(widget.periodos!.rf_mat, widget.periodos!.rf_databas)
            .then((List<Srh010> listPeriodoColaborador) {
              if(mounted){
                setState(() {
                  databasePeriodosColaborador = {};
                  for (Srh010 feriasColaborador in listPeriodoColaborador) {
                    databasePeriodosColaborador[feriasColaborador.rh_dataini] =
                        feriasColaborador;
                  }
                });
              }
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
