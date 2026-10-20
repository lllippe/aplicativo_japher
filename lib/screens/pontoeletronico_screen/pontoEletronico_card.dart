import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/sp8010.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/screens/pontoeletronico_screen/pontoEletronico_tile_list.dart';

class PontoEletronicoCard extends StatefulWidget {
  final Sp8010? data;
  final Map<int, Sp8010>? database;
  final int? soma;

  const PontoEletronicoCard({
    Key? key,
    this.data,
    this.database,
    this.soma,
  }) : super(key: key);

  @override
  State<PontoEletronicoCard> createState() => _PontoEletronicoCardState();
}

class _PontoEletronicoCardState extends State<PontoEletronicoCard> {
  Map<String, Srh010> databasePeriodosColaborador = {};
  int soma = 0;
  final ScrollController _controller = ScrollController();
  bool isExpanded = false;

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
              title: Text('Dia: ${widget.data!.p8_data.substring(6, 8)}/'
                  '${widget.data!.p8_data.substring(4, 6)}/'
                  '${widget.data!.p8_data.substring(0, 4)}'),
            );
          },
          body: SizedBox(
            height: (widget.soma! >= 4) ? 300 : 180,
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              thickness: 13.0,
              radius: const Radius.circular(20.0),
              child: ListView(
                controller: _controller,
                children: generateListTilePontoEletronico(
                  database: widget.database,
                ),
              ),
            ),
          ),
          isExpanded: isExpanded,
        ),
      ],
    );
  }
}
