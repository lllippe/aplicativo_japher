import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/periodos.dart';
import 'package:projeto_aucs/models/quem_esta_ferias.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/models/sze010_falta_dias.dart';
import 'package:projeto_aucs/screens/add_screen/add_szh010_screen.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/explanation_dialog.dart';
import 'package:projeto_aucs/screens/ferias_screen/feriasPeriodo_screen_list.dart';
import 'package:projeto_aucs/services/ferias_service.dart';
import 'package:projeto_aucs/services/periodo_service.dart';
import 'package:projeto_aucs/services/srh010_service.dart';
import 'package:projeto_aucs/services/sze010_falta_dias_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ferias extends StatefulWidget {
  final Sze010FaltaDias? sze010;
  final bool isloading;

  const Ferias({
    Key? key,
    this.sze010,
    required this.isloading,
  }) : super(key: key);

  @override
  State<Ferias> createState() => _FeriasState();
}

class _FeriasState extends State<Ferias> {
  Sze010FaltaDias? sze010;
  String userId = '';
  String nomeColaborador = '';
  final PeriodoService _periodosService = PeriodoService();
  final FeriasService _feriasService = FeriasService();
  final Sze010Service _colaboradoresService = Sze010Service();
  final Srh010Service _feriasColaboradorService = Srh010Service();
  final Srh010FaltaDiasService _srh010FaltaDiasService =
      Srh010FaltaDiasService();
  Map<String, QuemEstaFerias> databaseFerias = {};
  Map<String, Sze010> databaseColaboradores = {};
  Map<String, Sze010FaltaDias> databaseFaltaDias = {};
  Map<String, Periodos> databasePeriodos = {};
  Map<String, Srh010> databasePeriodosColaborador = {};
  List<TableRow> tableContainer = [];
  List<TableRow> tableContainerPeriodos = [];
  List<ListTile> listTile = [];
  bool _isloading = false;
  final ScrollController _controller = ScrollController();
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    refreshFerias();
    getPeriodos();
    _isloading = widget.isloading;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _listScrollController = ScrollController();
    var deviceData = MediaQuery.of(context);
    double width_screen = deviceData.size.width;
    return (!_isloading)
        ? DefaultTabController(
            length: 3, // This is the number of tabs.
            child: Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Icon(
                              Icons.airplane_ticket_rounded,
                              size: 30,
                              color: Colors.black.withAlpha(130),
                            ),
                          ),
                          const Text('Férias'),
                          Padding(
                            padding: const EdgeInsets.only(left: 130.0),
                            child: InkWell(
                              onTap: () {
                                explanationDialog(context, 
                                'Como solicitar férias',
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                          size: 25,
                                          color: Colors.black.withAlpha(130)),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Text('O ícone mostra a quantidade de dias que você possui em aberto para solicitar férias.',
                                                overflow: TextOverflow.values.first
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_calendar,
                                          size: 25,
                                          color: Colors.black.withAlpha(130)),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Text('O ícone mostra a quantidade de dias que você solicitou. É atualizado automaticamente ao selecionar a data inicial e final desejada.',
                                                overflow: TextOverflow.values.first
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius: BorderRadius.circular(30)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(
                                                      'Solicitar',
                                                      style: GoogleFonts.actor(
                                                        textStyle: const TextStyle(fontSize: 20),
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(30),
                                                      color: Colors.black.withAlpha(50)
                                                    ),
                                                    child: const Icon(
                                                      Icons.chevron_right_rounded, 
                                                      size: 30, 
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Text('Clique em Solicitar e aguarde o processamento.',
                                                overflow: TextOverflow.values.first
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(30),
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.question_mark,
                                    size: 20,
                                    color: Colors.black.withAlpha(150)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      titleTextStyle: GoogleFonts.actor(
                          textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      )),
                      backgroundColor: Colors.greenAccent,
                      pinned: true,
                      floating: true,
                      bottom: TabBar(
                        labelStyle: GoogleFonts.actor(
                            textStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 23,
                        )),
                        labelColor: Colors.black,
                        indicatorColor: Colors.black,
                        unselectedLabelStyle: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                        tabs: const [
                          Tab(
                            text: 'Períodos',
                          ),
                          Tab(
                            text: 'Solicitar',
                          ),
                          Tab(
                            text: 'Quem está?',
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: SizedBox(
                  height: 400,
                  width: width_screen,
                  child: TabBarView(
                    children: <Widget>[
                      ListView(
                        controller: _listScrollController,
                        children: generateListFeriasPeriodoCards(
                          database: databasePeriodos,
                        ),
                      ),
                      (sze010 != null)
                          ? Scrollbar(
                              controller: _controller,
                              thickness: 6,
                              radius: const Radius.circular(15),
                              child: AddSzh010Screen(
                                sze010: sze010!,
                                createAppBar: false,
                              ),
                            )
                          : Text(
                            'Não há dias em aberto para fazer solicitação.',
                            style: GoogleFonts.actor(
                                textStyle: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            )),
                          ),
                      SingleChildScrollView(
                        controller: _controller,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            border: TableBorder.all(),
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(),
                              1: FixedColumnWidth(100),
                              2: FixedColumnWidth(100),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: tableContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  void refreshFerias() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String id = '';

      if (firstName != null && lastName != null) {
        _feriasService.getListVacation().then((List<QuemEstaFerias> listFerias) {
          setState(() {
            userId = id;
            databaseFerias = {};
            for (QuemEstaFerias ferias in listFerias) {
              databaseFerias[ferias.r_e_c_n_o_field.toString()] = ferias;
            }

            tableContainer.add(
              TableRow(
                children: <Widget>[
                  Container(
                    height: 25,
                    color: Colors.greenAccent,
                    child: Text(
                      'Nome',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.actor(
                        textStyle: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    color: Colors.greenAccent,
                    child: Text(
                      'Inicio',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.actor(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 25,
                    color: Colors.greenAccent,
                    child: Text(
                      'Fim',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.actor(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            databaseFerias.forEach((key, value) {
              tableContainer.add(
                TableRow(
                  children: <Widget>[
                    Container(
                      height: 25,
                      color: Colors.white,
                      child: Text(
                        value.ze_nome.trim(),
                        textAlign: TextAlign.start,
                        style: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 25,
                      color: Colors.white,
                      child: Text(
                        '${value.rh_dataini.substring(6, 8)}/'
                            '${value.rh_dataini.substring(4, 6)}/'
                            '${value.rh_dataini.substring(0, 4)}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 25,
                      color: Colors.white,
                      child: Text(
                        '${value.rh_datafim.substring(6, 8)}/'
                            '${value.rh_datafim.substring(4, 6)}/'
                            '${value.rh_datafim.substring(0, 4)}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.actor(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          });
        });

        _colaboradoresService
            .getAll()
            .then((List<Sze010> listColaboradores) {
          setState(() {
            databaseColaboradores = {};
            for (Sze010 colaborador in listColaboradores) {
              databaseColaboradores[colaborador.ze_mat] = colaborador;
            }
          });
        });

        databaseFerias.forEach((key, value) { });
        _colaboradoresService.getAll().then((List<Sze010> listColaboradores) {
          setState(() {
            userId = id;
            databaseColaboradores = {};
            for (Sze010 colaborador in listColaboradores) {
              databaseColaboradores[colaborador.ze_nome] = colaborador;
            }
          });
        });
        _srh010FaltaDiasService
            .getAll()
            .then((List<Sze010FaltaDias> listSze010FaltaDias) {
          setState(() {
            databaseFaltaDias = {};
            userId = prefs.getString('id')!;
            for (Sze010FaltaDias sze010 in listSze010FaltaDias) {
              databaseFaltaDias[sze010.ze_nome] = sze010;
            }

            databaseFaltaDias.forEach((key, value) {
              if (userId == value.ze_mat) {
                sze010 = value;
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

  void getPeriodos() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String? id = prefs.getString('id');

      if (firstName != null && lastName != null) {
        _periodosService.getId(id!).then((List<Periodos> listPeriodos) {
          setState(() {
            databasePeriodos = {};
            for (Periodos periodos in listPeriodos) {
              databasePeriodos[periodos.rf_databas] = periodos;
            }

            databasePeriodos.forEach((key, value) {
              _feriasColaboradorService
                  .getAll(value.rf_mat, value.rf_databas)
                  .then((List<Srh010> listPeriodoColaborador) {
                if(mounted){
                  setState(() {
                    userId = id;
                    databasePeriodosColaborador = {};
                    for (Srh010 feriasColaborador in listPeriodoColaborador) {
                      databasePeriodosColaborador[feriasColaborador.rh_dataini] =
                          feriasColaborador;
                    }

                    databasePeriodosColaborador.forEach((key, value) {
                      tableContainerPeriodos.add(
                        TableRow(
                          children: <Widget>[
                            Container(
                              height: 25,
                              color: Colors.white,
                              child: Text(
                                value.rh_dataini,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.actor(
                                  textStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                              color: Colors.white,
                              child: Text(
                                value.rh_datafim,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.actor(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 25,
                              color: Colors.white,
                              child: Text(
                                '${value.rh_dferias}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.actor(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                    _isloading = false;
                  });
                }
              });
            });
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
