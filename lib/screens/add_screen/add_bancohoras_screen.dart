import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aucs/models/spi010.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/screens/commom/confirmation_dialog.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/menu_drawer.dart';
import 'package:projeto_aucs/screens/commom/success_dialog.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/services/spi010_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/validations/bancoHorasValidation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

var depto;
const List<String> active = <String>['Sim', 'Não'];

class AddBancoHorasScreen extends StatefulWidget {
  final bool isLoading;
  final Spi010? spi010;
  final bool isEditing;

  const AddBancoHorasScreen(
      {Key? key,
      required this.isLoading,
      required this.spi010,
      required this.isEditing})
      : super(key: key);

  @override
  State<AddBancoHorasScreen> createState() => _AddBancoHorasScreenState();
}

class _AddBancoHorasScreenState extends State<AddBancoHorasScreen> {
  String email = 'Seja bem-vindo(a)';
  final Sze010Service _sze010service = Sze010Service();
  final Spi010Service _spi010Service = Spi010Service();
  Map<String, String> database = {};
  Map<String, Sze010> databaseSze = {};
  Map<String, Srh010> databaseSrh = {};
  List<TableRow> tableContainer = [];
  List<String> name = [];
  TextEditingController inicioController = TextEditingController();
  TextEditingController horasController = TextEditingController();
  TextEditingController justificativaController = TextEditingController();
  DateTime? pickedDateInicio;
  DateTime initialDate = DateTime.now();
  String periodoInicial = '        ';
  final ScrollController _controller = ScrollController();
  bool validateHour = false;
  bool validateJust = false;
  bool validateDate = false;
  bool confirmationDialog = false;
  bool isHour = true;
  bancoHorasValidation validation = bancoHorasValidation();
  var departamento;
  var listReturnDialog;
  bool _isloading = false;
  String directory = '';
  bool isRequestReady = true;

  @override
  void initState() {
    _isloading = widget.isLoading;
    if (widget.isEditing) {
      justificativaController.text = widget.spi010!.pi_justifi;
      horasController.text = widget.spi010!.pi_quant.toString();
      inicioController.text = DateFormat('dd/MM/yyyy')
          .format(DateTime.parse(widget.spi010!.pi_data));
    } else {
      horasController.text = "0.0";
    }
    getSze010();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now().subtract(const Duration(days: 90));
    DateTime lastDate = DateTime.now();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return (!_isloading)
        ? Scaffold(
            backgroundColor: Colors.blueGrey.withAlpha(30),
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isHour = !isHour;
                                        });
                                      },
                                      child: Icon(
                                        (isHour) ? Icons.access_time : Icons.calendar_month, 
                                        size: 30,
                                        color: Colors.black.withAlpha(130),
                                      ),
                                    )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.remove_circle_rounded, 
                                            color: Colors.black.withAlpha(200),
                                            size: 25,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (isHour) {
                                                horasController.text = (double.parse(horasController.text) - 0.5).toString();
                                              } else {
                                                horasController.text = (double.parse(horasController.text) - 7.5).toString();
                                              }
                                              
                                            });
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black.withAlpha(100),
                                                width: 1.5,
                                              ),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 10, right: 10),
                                              child: Text(horasController.text,
                                                style: GoogleFonts.actor(
                                                  textStyle: const TextStyle(fontSize: 20),
                                                  color: Colors.black,
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          child: Icon(
                                            Icons.add_circle_rounded, 
                                            color: Colors.black.withAlpha(200), 
                                            size: 25,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (isHour) {
                                                horasController.text = (double.parse(horasController.text) + 0.5).toString();
                                              } else {
                                                horasController.text = (double.parse(horasController.text) + 7.5).toString();
                                              }
                                              });
                                          },
                                        ),
                                        (double.parse(horasController.text) != 0)
                                        ? Padding(
                                          padding: const EdgeInsets.only(left: 30.0),
                                          child: InkWell(
                                            child: Icon(
                                              Icons.block, 
                                              color: Colors.black.withAlpha(200),
                                              size: 25,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                horasController.text = '0.0';
                                              });
                                            },
                                          ),
                                        )
                                        : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0, right: 20),
                              child: Icon(
                                Icons.text_fields,
                                size: 30,
                                color: Colors.black.withAlpha(130),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                              child: Container(
                                alignment: Alignment.center,
                                width: screenWidth - 140,
                                height: 100,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: "Justificativa",
                                    ),
                                    controller: justificativaController,
                                    keyboardType: TextInputType.multiline,
                                    style: const TextStyle(fontSize: 18),
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    maxLength: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ), // Nome
                        SizedBox(
                          width: screenWidth - 30,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, right: 20),
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.black.withAlpha(130),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: departamento,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black.withAlpha(200),
                                      fontSize: 16),
                                  items: name.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: SizedBox(
                                        width: screenWidth - 150,
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
                              ],
                            ),
                          ),
                        ), // Nome
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0, right: 15),
                                child: Icon(
                                  Icons.today,
                                  size: 30,
                                  color: Colors.black.withAlpha(130),
                                ),
                              ),
                              Text(DateFormat('dd/MM/yyyy').format(initialDate),
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              (initialDate.weekday == 6 || initialDate.weekday == 7)
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: InkWell(
                                    child: Icon(
                                      Icons.block, 
                                      color: Colors.black.withAlpha(80),
                                      size: 25,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        ErrorDialog(context, "Solicitar autorização para inserir horas de final de semana.");
                                      });
                                    },
                                  ),
                                )
                                : Container(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                          child: (isRequestReady)
                              ? InkWell(
                                onTap: () {
                                  if (initialDate.weekday == 6 || initialDate.weekday == 7) {
                                      ErrorDialog(context, 'Usuário não autorizado a fazer hora extra no final de semana.');
                                    } else {
                                      showConfirmationDialog(context, 
                                        content: "Deseja inserir ${horasController.text} horas "
                                          "no seu banco?").then((onValue) {
                                            setState(() {
                                              confirmationDialog = onValue;
                                              inicioController.text = initialDate.toString();
                                            });
                                        if(!confirmationDialog) {
                                          setState(() {
                                            horasController.text = '0.0';
                                            justificativaController.text = '';
                                            inicioController.text = '';
                                          });
                                        } else {
                                          validateBancoHoras(context);
                                          (validateJust ||
                                                  validateHour ||
                                                  validateDate)
                                              ? ErrorDialog(context,
                                                  'Existem erros que impedem a gravação, verificar!')
                                              : setState(() {
                                                  isRequestReady = false;
                                                  registerSpi010(context);
                                                });
                                          }
                                        }
                                      );
                                    }
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
                                              'Adicionar',
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
                                    ErrorDialog(
                                        context, "Aguarde o processamento.");
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
                              ),
                        ), // Button Solicitar
                      ],
                    ),
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

  void validateBancoHoras(BuildContext context) {
    String initialDate = (inicioController.text != '')
        ? inicioController.text.substring(6, 10) +
            inicioController.text.substring(3, 5) +
            inicioController.text.substring(0, 2)
        : '';
    double hourValidator = (horasController.text != '')
        ? (horasController.text.contains(','))
            ? double.parse(horasController.text.replaceAll(',', '.'))
            : double.parse(horasController.text)
        : 0.0;

    if (validation.hourDifferentZero(hourValidator)) {
      validateHour = true;
      ErrorDialog(context, 'Quantidade de horas deve ser preenchida!');
    } else {
      validateHour = false;
    }

    if (validation.justificationDifferentBlank(justificativaController.text)) {
      validateJust = true;
      ErrorDialog(context, 'Justificativa deve ser preenchida!');
    } else {
      validateJust = false;
    }
  }

  registerSpi010(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? name = prefs.getString('first_name');

      String matricula = '';
      String dpto = '';

      databaseSze.forEach((key, value) {
        if (value.ze_nome.trim() == departamento) {
          matricula = value.ze_mat;
          dpto = value.ze_depto;
        }
      });

      if (widget.isEditing) {
        double horas = (horasController.text.contains(','))
            ? double.parse(horasController.text.replaceAll(',', '.'))
            : double.parse(horasController.text);

        Spi010 internalSpi010 = Spi010(
            pi_mat: widget.spi010!.pi_mat,
            pi_data: widget.spi010!.pi_data,
            pi_pd: (horas < 0) ? '002' : '001',
            pi_quant: horas,
            pi_quantv: widget.spi010!.pi_quantv,
            pi_status: widget.spi010!.pi_status,
            pi_depto: widget.spi010!.pi_depto,
            pi_justifi: justificativaController.text.trim(),
            d_e_l_e_t_field: '',
            r_e_c_n_o_field: widget.spi010!.r_e_c_n_o_field,
            r_e_c_d_e_l_field: widget.spi010!.r_e_c_d_e_l_field);

        _spi010Service
            .edit(widget.spi010!.r_e_c_n_o_field, internalSpi010)
            .then((value) {
          if (value) {
            setState(() {
              isRequestReady = true;
            });
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
            return SuccessDialog(context, 'Horas alteradas com sucesso!');
          } else {
            Navigator.pop(context, DisposeStatus.error);
            return ErrorDialog(
                context, 'Erro na solicitação, tente mais tarde!');
          }
        });
      } else {
        double horas = (horasController.text.contains(','))
            ? double.parse(horasController.text.replaceAll(',', '.'))
            : double.parse(horasController.text);

        Spi010 internalSpi010 = Spi010(
            pi_mat: matricula,
            pi_data: inicioController.text.substring(0, 4) +
              inicioController.text.substring(5, 7) +
              inicioController.text.substring(8, 10),
            pi_pd: (horas < 0) ? '002' : '001',
            pi_quant: horas,
            pi_quantv: 0,
            pi_status: 'A',
            pi_depto: dpto,
            pi_justifi: justificativaController.text.trim(),
            d_e_l_e_t_field: '',
            r_e_c_n_o_field: 0,
            r_e_c_d_e_l_field: 0);

        _spi010Service.register(internalSpi010).then((value) {
          if (value) {
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
            return SuccessDialog(context, 'Horas inseridas com sucesso!');
          } else {
            Navigator.pop(context, DisposeStatus.error);
            return ErrorDialog(
                context, 'Erro na solicitação, tente mais tarde!');
          }
        });
      }
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
        directory = id;
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

        _sze010service.getAll().then((List<Sze010> listSze010) {
          if (mounted) {
            setState(() {
              for (Sze010 sze010 in listSze010) {
                if (group == '1') {
                  if (widget.isEditing) {
                    if (widget.spi010!.pi_mat == sze010.ze_mat) {
                      name.add(sze010.ze_nome.trim());
                    }
                  } else {
                    name.add(sze010.ze_nome.trim());
                  }
                } else if (group == '2') {
                  if (widget.isEditing) {
                    if (widget.spi010!.pi_mat == sze010.ze_mat) {
                      if (sze010.ze_depto == depto) {
                        name.add(sze010.ze_nome.trim());
                      }
                    }
                  } else {
                    if (sze010.ze_depto == depto) {
                      name.add(sze010.ze_nome.trim());
                    }
                  }
                } else if (group == '3') {
                  if (widget.isEditing) {
                    if (widget.spi010!.pi_mat == sze010.ze_mat) {
                      if (id == sze010.ze_mat) {
                        name.add(sze010.ze_nome.trim());
                      }
                    }
                  } else {
                    if (id == sze010.ze_mat) {
                      name.add(sze010.ze_nome.trim());
                    }
                  }
                }
                databaseSze[sze010.ze_mat] = sze010;
              }

              departamento = name.first;
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

enum DisposeStatus { exit, error, success }
