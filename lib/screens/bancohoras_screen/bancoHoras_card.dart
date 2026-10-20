import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/spi010.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/screens/bancohoras_screen/bancoHoras_tile_list.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BancoHorasCard extends StatefulWidget {
  final Map<int, Spi010>? database;
  final int? soma;
  final double? totalDia;
  final String? titulo;
  final int? detail;

  const BancoHorasCard({
    Key? key,
    //this.data,
    this.database,
    this.soma,
    this.totalDia,
    this.titulo,
    this.detail,
  }) : super(key: key);

  @override
  State<BancoHorasCard> createState() => _BancoHorasCardState();
}

class _BancoHorasCardState extends State<BancoHorasCard> {
  Map<String, Srh010> databasePeriodosColaborador = {};
  int soma = 0;
  final ScrollController _controller = ScrollController();
  final ScrollController _controllerbar = ScrollController();
  Map<String, Sze010> databaseSze = {};
  final Sze010Service _sze010service = Sze010Service();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controllerbar,
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
              title: Text('${widget.titulo}: ${widget.totalDia} horas'),
                // 'Dia: ${widget.data!.pi_data.substring(6, 8)}/'
                //     '${widget.data!.pi_data.substring(4, 6)}/'
                //     '${widget.data!.pi_data.substring(0, 4)}
            );
          },
          body: SizedBox(
            height: (widget.soma! >= 4) ? 300 : 180,
            child: ListView(
              controller: _controller,
              children: generateListTileBancoHoras(
                database: widget.database,
                databaseSze: databaseSze,
                detail: widget.detail!,
                //data: widget.data,
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
      String? id = prefs.getString('id');
      String? group = prefs.getString('group');

      if (firstName != null &&
          lastName != null &&
          id != null &&
          group != null) {

        _sze010service.getAll().then((List<Sze010> listSze010) {
          if (mounted) {
            setState(() {
              for (Sze010 sze010 in listSze010) {
                databaseSze[sze010.ze_mat] = sze010;
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
