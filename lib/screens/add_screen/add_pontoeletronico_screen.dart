import 'package:flutter/material.dart';
import 'package:projeto_aucs/models/ferias.dart';
import 'package:projeto_aucs/models/sp8010.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/menu_drawer.dart';
import 'package:projeto_aucs/screens/commom/success_dialog.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/services/sp8010_service.dart';
import 'package:projeto_aucs/services/srh010_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/validations/pontoEletronicoValidation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:projeto_aucs/services/worldtime_service.dart';

var depto;
const List<String> active = <String>['Sim', 'Não'];

class AddPontoEletronicoScreen extends StatefulWidget {
  final bool isLoading;

  const AddPontoEletronicoScreen({Key? key, required this.isLoading})
      : super(key: key);

  @override
  State<AddPontoEletronicoScreen> createState() =>
      _AddPontoEletronicoScreenState();
}

class _AddPontoEletronicoScreenState extends State<AddPontoEletronicoScreen> {
  String email = 'Seja bem-vindo(a)';
  final Sze010Service _sze010service = Sze010Service();
  final Sp8010Service _sp8010Service = Sp8010Service();
  final Srh010Service _srh010Service = Srh010Service();
  final WorldTimeService _worldtimeService = WorldTimeService();
  Map<String, String> database = {};
  Map<String, Sze010> databaseSze = {};
  Map<String, Srh010> databaseSrh = {};
  Map<int, FeriasSze> databaseVacation = {};
  List<String> name = [];
  DateTime initialDate = DateTime.now();
  String periodoInicial = '        ';
  DateTime time = DateTime.now();
  final ScrollController _controller = ScrollController();
  bool validateTime = false;
  bool validateVacation = false;
  pontoEletronicoValidation validation = pontoEletronicoValidation();
  var departamento;
  bool _isloading = false;
  bool _isRegisterReady = false;
  bool validateHoliday = false;
  String returnRegister = '';
  double hour = 0.0;
  String day = '';
  bool isRequestReady = true;

  @override
  void initState() {
    _isloading = widget.isLoading;
    getSze010();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);
    double width_screen = deviceData.size.width;
    return (!_isloading)
        ? Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                controller: _controller,
                child: Card(
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
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Icon(
                                Icons.person,
                                size: 25,
                                color: Colors.black.withAlpha(80),
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: SizedBox(
                                width: width_screen - 120,
                                child: DropdownButton<String>(
                                  value: departamento,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black,
                                      fontSize: 16),
                                  items: name.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: SizedBox(
                                        width: width_screen - 150,
                                        child: Text(
                                          value,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      departamento = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnalogClock(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2.0, color: Colors.black),
                                  color: Colors.black,
                                  shape: BoxShape.circle),
                              width: width_screen - 170,
                              height: 230,
                              isLive: true,
                              hourHandColor: Colors.white70,
                              minuteHandColor: Colors.white,
                              secondHandColor: Colors.yellow,
                              showSecondHand: true,
                              numberColor: Colors.white,
                              showNumbers: true,
                              showAllNumbers: true,
                              textScaleFactor: 1.8,
                              showTicks: true,
                              showDigitalClock: true,
                              digitalClockColor: Colors.orange,
                              datetime: time,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0, bottom: 30),
                        child: (isRequestReady)
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    isRequestReady = false;
                                  });
                                  register();
                                  },
                                  child: Container(
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
                                              'Registrar',
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
                              )
                            : InkWell(
                                onTap: () { 
                                    ErrorDialog(context, "Aguarde processamento.");
                                  },
                                  child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(30)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 4, top: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              'Aguarde',
                                              style: GoogleFonts.actor(
                                                textStyle: const TextStyle(fontSize: 20),
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              )
                      ), // Button Solicitar
                      (_isRegisterReady)
                          ? Center(
                            child: SizedBox(
                                width: width_screen - 20,
                                height: 200,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  returnRegister,
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            drawer: menuDrawer(context),
          )
        : Container(
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
  }

  void register() {
    _worldtimeService.getAll().then((List<String> listWorldTime) {
      for (String worldtime in listWorldTime) {
        if (mounted) {
          setState(() {
            time = DateTime(
                int.parse(worldtime.substring(0, 4)),
                int.parse(worldtime.substring(5, 7)),
                int.parse(worldtime.substring(8, 10)),
                int.parse(worldtime.substring(11, 13)),
                int.parse(worldtime.substring(14, 16)),
                int.parse(worldtime.substring(17, 19)));
          });
        }
      }
    });

    validateRegister(context);
  }

  void validateRegister(BuildContext context) {
    if (validation.availableTime(time)) {
      ErrorDialog(
          context, 'Colaborador sem autorização para fazer hora extra.');
      setState(() {
        isRequestReady = true;
        validateTime = true;
      });
    } else {
      setState(() {
        validateTime = false;
      });
    }

    if (validation.dayHoliday(time)) {
      ErrorDialog(context,
          'Colaborador sem autorização para fazer hora extra no feriado.');
      setState(() {
        isRequestReady = true;
        validateHoliday = true;
      });
    } else {
      setState(() {
        validateHoliday = false;
      });
    }

    setState(() {
      validateVacation = false;
    });
    databaseVacation.forEach((key, value) {
      if (value.rh_dataini != '        ' && value.rh_datafim != '        ') {
        DateTime dateInitialPeriod = DateTime(
            int.parse(value.rh_dataini.substring(0, 4)),
            int.parse(value.rh_dataini.substring(4, 6)),
            int.parse(value.rh_dataini.substring(6, 8)));
        DateTime dateFinalPeriod = DateTime(
            int.parse(value.rh_datafim.substring(0, 4)),
            int.parse(value.rh_datafim.substring(4, 6)),
            int.parse(value.rh_datafim.substring(6, 8)));
        if ((time.isAfter(dateInitialPeriod) &&
                time.isBefore(dateFinalPeriod)) ||
            (time.isAtSameMomentAs(dateInitialPeriod) ||
                time.isAtSameMomentAs(dateFinalPeriod))) {
          setState(() {
            validateVacation = true;
            isRequestReady = true;
          });
          ErrorDialog(
              context, 'Colaborador em férias não pode registrar ponto.');
        }
      }
    });

    if (validateTime || validateVacation) {
    } else {
      setState(() {
        _isRegisterReady = true;
        returnRegister =
            'Registro feito.\nData: ${time.day}/${time.month}/${time.year}\n'
            'Horário: ${time.hour}:'
            '${(time.minute.toString().length == 1) ? time.minute.toString().padLeft(2, '0') : time.minute}:'
            '${(time.second.toString().length == 1) ? time.second.toString().padLeft(2, '0') : time.second}';
      });
      registerSp8010(context);
    }
  }

  registerSp8010(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? name = prefs.getString('first_name');
      double hour = double.parse(
          '${time.hour.toString()}.${(time.minute < 10) ? time.minute.toString().padLeft(2, '0') : time.minute.toString().padRight(2, '0')}');
      String month = (time.month.toString().length == 1)
          ? time.month.toString().padLeft(2, '0')
          : time.month.toString();
      String day = (time.day.toString().length == 1)
          ? time.day.toString().padLeft(2, '0')
          : time.day.toString();
      String date = time.year.toString() + month + day;

      String matricula = '';
      String dpto = '';

      databaseSze.forEach((key, value) {
        if (value.ze_nome.trim() == departamento) {
          matricula = value.ze_mat;
          dpto = value.ze_depto;
        }
      });

      Sp8010 internalSp8010 = Sp8010(
          p8_mat: matricula,
          p8_data: date,
          p8_hora: hour,
          p8_depto: dpto,
          p8_seqjrn: 0,
          p8_motivrg: '',
          p8_usuario: matricula,
          d_e_l_e_t_field: '',
          r_e_c_n_o_field: 0,
          r_e_c_d_e_l_field: 0);

      _sp8010Service.register(internalSp8010).then((value) {
        if (value) {
          setState(() {
            isRequestReady = true;
          });
          //Navigator.pop(context, DisposeStatus.success);
          //Navigator.push(
          //  context,
          //  MaterialPageRoute(
          //    builder: (context) => (name != null && group != null)
          //        ? HomeScreen(
          //            selectedIndex: 0,
          //            name: name,
          //            userGroup: group,
          //          )
          //        : Container(),
          //  ),
          //);
          return SuccessDialog(context, 'Ponto registrado com Sucesso!');
        } else {
          setState(() {
            isRequestReady = true;
          });
          Navigator.pop(context, DisposeStatus.error);
          return ErrorDialog(context, 'Erro na solicitação, tente mais tarde!');
        }
      });
    });
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
        _sze010service.getId(id).then((List<Sze010> listSze010) {
          if (mounted) {
            setState(() {
              depto = '';
              for (Sze010 sze010 in listSze010) {
                depto = sze010.ze_depto;
              }
            });
          }
        });

        _worldtimeService.getAll().then((List<String> listWorldTime) {
          for (String worldtime in listWorldTime) {
            if (mounted) {
              setState(() {
                time = DateTime(
                    int.parse(worldtime.substring(0, 4)),
                    int.parse(worldtime.substring(5, 7)),
                    int.parse(worldtime.substring(8, 10)),
                    int.parse(worldtime.substring(11, 13)),
                    int.parse(worldtime.substring(14, 16)),
                    int.parse(worldtime.substring(17, 19)));
              });
            }
          }
        });

        _sze010service.getAll().then((List<Sze010> listSze010) {
          if (mounted) {
            setState(() {
              for (Sze010 sze010 in listSze010) {
                if (id == sze010.ze_mat) {
                  name.add(sze010.ze_nome.trim());
                }
                databaseSze[sze010.ze_mat] = sze010;
              }

              departamento = name.first;
              _isloading = false;
            });
          }
        });

        _srh010Service.getId(id).then((List<FeriasSze> listSrh010) {
          if (mounted) {
            setState(() {
              databaseVacation = {};
              for (FeriasSze srh010 in listSrh010) {
                databaseVacation[srh010.r_e_c_n_o_field] = srh010;
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

enum DisposeStatus { exit, error, success }
