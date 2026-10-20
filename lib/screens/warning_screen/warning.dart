import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/aniversarios.dart';
import 'package:projeto_aucs/models/convenios.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/models/sze010_falta_dias.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/warning_screen/warning_convenio_database.dart';
import 'package:projeto_aucs/screens/warning_screen/warning_database.dart';
import 'package:projeto_aucs/screens/warning_screen/warning_ferias_database.dart';
import 'package:projeto_aucs/screens/warning_screen/warning_solicitacoes_database.dart';
import 'package:projeto_aucs/services/aniversarios_service.dart';
import 'package:projeto_aucs/services/convenios_service.dart';
import 'package:projeto_aucs/services/sze010_falta_dias_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/services/szh010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Warning extends StatefulWidget {
  const Warning({Key? key}) : super(key: key);

  @override
  State<Warning> createState() => WarningState();
}

class WarningState extends State<Warning> with TickerProviderStateMixin {
  int selectedPage = 0;
  final AniversariosService _aniversariosService = AniversariosService();
  final ConveniosService _convenioService = ConveniosService();
  final Srh010FaltaDiasService _faltaDiasService = Srh010FaltaDiasService();
  final Szh010Service _solicitacoesAbertoService = Szh010Service();
  final Sze010Service _sze010service = Sze010Service();
  Map<String, Sze010> databaseSze = {};
  Map<String, Aniversarios> database = {};
  Map<String, Convenios> databaseConvenios = {};
  Map<String, Sze010FaltaDias> databaseFaltaDias = {};
  Map<String, Szh010> databaseSolicitacoesAberto = {};
  String userId = '';
  String? group = '';
  String dptoMaster = '';
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return !_isloading
        ? Scaffold(
          backgroundColor: Colors.blueGrey.withAlpha(30),
          body: Scrollbar(
              thumbVisibility: true,
              thickness: 10,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsGeometry.only(top: 15, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.announcement_rounded,
                            size: 28,
                            color: Colors.black.withAlpha(130),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Avisos',
                              style: GoogleFonts.actor(
                                fontSize: 25,
                                color: Colors.black.withAlpha(200),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      child: Card(
                        shadowColor: Colors.black,
                        borderOnForeground: true,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Colors.black.withAlpha(20), // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: screenWidth,
                              child: ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: generateWarningScreen(
                                  database: database,
                                  refreshFunction: refresh,
                                  userId: userId,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      child: Card(
                        shadowColor: Colors.black,
                        borderOnForeground: true,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Colors.black.withAlpha(20), // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: 
                              Icon(
                                Icons.warning_rounded,
                                size: 30,
                                color: Colors.black.withAlpha(80),)
                            ),
                            SizedBox(
                              width: screenWidth - 100,
                              child: ListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: generateWarningConvenioScreen(
                                  database: databaseConvenios,
                                  refreshFunction: refresh,
                                  userId: userId,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                      child: Card(
                        shadowColor: Colors.black,
                        borderOnForeground: true,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Colors.black.withAlpha(20), // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: 
                              Icon(
                                Icons.flight_takeoff_rounded,
                                size: 25,
                                color: Colors.black.withAlpha(80),
                              ),
                            ),
                            (databaseFaltaDias.length > 0)
                                ? SizedBox(
                                  width: screenWidth - 100,
                                  child: ListView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: generateWarningFeriasScreen(
                                        databaseFaltaDias: databaseFaltaDias,
                                        refreshFunction: refresh,
                                        userId: userId,
                                      ),
                                    ),
                                )
                                : SizedBox(
                                  width: screenWidth - 80,
                                  child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: Text(
                                              'Todo o período já foi marcado!',
                                              overflow: TextOverflow.values.first,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.actor(
                                                textStyle: const TextStyle(
                                                    fontSize: 23,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    (group == '1' || group == '2')
                        ? (databaseSolicitacoesAberto.length > 0)
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5),
                                child: Card(
                                  shadowColor: Colors.black,
                                  borderOnForeground: true,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                      color: Colors.black.withAlpha(20), // Border color
                                      width: 1, // Border width
                                    ),
                                  ),
                                  child: Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Solicitações de Férias em Aberto',
                                        style: GoogleFonts.actor(
                                          textStyle: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    ListView(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: generateWarningSolicitacoesScreen(
                                        database: databaseSolicitacoesAberto,
                                        refreshFunction: refresh,
                                        userId: userId,
                                      ),
                                    ),
                                  ]),
                                ),
                              )
                            : Container()
                        : Container(),
                  ],
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

  void refresh() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      this.group = prefs.getString('group');
      String? group = prefs.getString('group');

      if (firstName != null && lastName != null && group != null) {
        setState(() {
          _isloading = true;
        });
        userId = prefs.getString('id')!;
        _aniversariosService
            .getAll()
            .then((List<Aniversarios> listAniversarios) {
          if (mounted) {
            setState(() {
              database = {};
              for (Aniversarios aniversarios in listAniversarios) {
                database[aniversarios.ze_nome] = aniversarios;
              }
            });
          }
        });

        _convenioService.getAll().then((List<Convenios> listConvenios) {
          if (mounted) {
            setState(() {
              databaseConvenios = {};
              for (Convenios convenios in listConvenios) {
                databaseConvenios[convenios.ze_nome] = convenios;
              }
            });
          }
        });
        _faltaDiasService
            .searchMat(userId)
            .then((List<Sze010FaltaDias> listFaltaDias) {
          if (mounted) {
            setState(() {
              databaseFaltaDias = {};
              for (Sze010FaltaDias faltaDias in listFaltaDias) {
                databaseFaltaDias[faltaDias.ze_nome] = faltaDias;
              }
            });
          }
        });
        _sze010service.getId(userId).then((List<Sze010> listSze) {
          if (mounted) {
            setState(() {
              databaseSze = {};
              for (Sze010 sze010 in listSze) {
                if (userId.trim() == sze010.ze_mat.trim()) {
                  _solicitacoesAbertoService
                      .getGroup(int.parse(sze010.ze_depto), int.parse(group))
                      .then((List<Szh010> listSolicitacoesAberto) {
                    int openVacation = 0;
                    if (mounted) {
                      setState(() {
                        databaseSolicitacoesAberto = {};
                        for (Szh010 solicitacoes in listSolicitacoesAberto) {
                          if (openVacation == 0) {
                            databaseSolicitacoesAberto[
                                solicitacoes.zh_dataini] = solicitacoes;
                            openVacation++;
                          }
                        }
                        openVacation = 0;
                      });
                    }
                  });
                }
              }
              _isloading = false;
            });
          }
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
