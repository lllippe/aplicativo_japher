import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aucs/models/email_departamento.dart';
import 'package:projeto_aucs/models/srf010.dart';
import 'package:projeto_aucs/models/srh010.dart';
import 'package:projeto_aucs/models/sze010_falta_dias.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/commom/menu_drawer.dart';
import 'package:projeto_aucs/screens/commom/success_dialog.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/screens/szh010_screen/szh010_screen.dart';
import 'package:projeto_aucs/services/sqb010_service.dart';
import 'package:projeto_aucs/services/srf010_service.dart';
import 'package:projeto_aucs/services/srh010_service.dart';
import 'package:projeto_aucs/services/szh010_service.dart';
import 'package:projeto_aucs/validations/dateValidation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

const List<String> active = <String>['Sim', 'Não'];

class AddSzh010Screen extends StatefulWidget {
  final Sze010FaltaDias sze010;
  final createAppBar;

  const AddSzh010Screen({
    Key? key,
    required this.sze010,
    required this.createAppBar,
  }) : super(key: key);

  @override
  State<AddSzh010Screen> createState() => _AddSzh010ScreenState();
}

class _AddSzh010ScreenState extends State<AddSzh010Screen> {
  String email = 'Seja bem-vindo(a)';
  final Srf010Service _srf010service = Srf010Service();
  final Szh010Service _szh010service = Szh010Service();
  final Srh010Service _srh010service = Srh010Service();
  dateValidation validation = dateValidation();
  Map<String, Szh010> databaseShz = {};
  Map<String, Srh010> databaseSrh = {};
  List<TableRow> tableContainer = [];
  int qtdeDias = 0;
  int diasDireito = 0;
  int diasSzh = 40;
  int diasSrh = 40;
  TextEditingController inicioController = TextEditingController();
  TextEditingController fimController = TextEditingController();
  DateTime? pickedDateFim;
  DateTime? pickedDateInicio;
  DateTime initialDate = DateTime.now();
  String periodoInicial = '        ';
  String periodoFinal = '        ';
  bool validateStartHoliday = false;
  bool validateEndHoliday = false;
  bool validateDaysAvailable = false;
  bool validatePeriodLong = false;
  bool validateDateWeekend = false;
  bool validatePeriodAvailable = false;
  bool tableTab = false;
  final ScrollController _controller = ScrollController();
  bool isRequestReady = true;

  @override
  void initState() {
    getSrf010();
    getSzh010();
    diasDireito = widget.sze010.ze_saldfer.round();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime lastDate = DateTime.parse(
            '${(int.parse(widget.sze010.ze_fperaq.substring(0, 4)) + 1).toString()}-'
            '${widget.sze010.ze_fperaq.substring(4, 6)}-'
            '${widget.sze010.ze_fperaq.substring(6, 8)}')
        .subtract(const Duration(days: 7));
    DateTime initialDate =
        (DateTime.now().add(const Duration(days: 10)).weekday ==
                DateTime.saturday)
            ? DateTime.now().add(const Duration(days: 9))
            : (DateTime.now().add(const Duration(days: 10)).weekday ==
                    DateTime.sunday)
                ? DateTime.now().add(const Duration(days: 8))
                : DateTime.now().add(const Duration(days: 10));

    return (widget.createAppBar)
        ? Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.black,
              title: const Text('Solicitação Férias'),
              titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              backgroundColor: Colors.greenAccent,
              actions: [
                IconButton(
                  onPressed: () {
                    registerSzh010(context);
                  },
                  icon: const Icon(Icons.check),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    Card(
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
                            padding: const EdgeInsets.only(top: 12, bottom: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                                  child: Icon(
                                    Icons.person,
                                    size: 25,
                                    color: Colors.black.withAlpha(30)
                                  ),
                                ),
                                Text(
                                  widget.sze010.ze_nome.trim(),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ), // Nome
                            const Divider(
                              height: 2,
                              thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                                  child: Icon(
                                    Icons.date_range,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                ),
                                Text(
                                  '${periodoInicial.substring(6, 8)}/'
                                  '${periodoInicial.substring(4, 6)}/'
                                  '${periodoInicial.substring(0, 4)}  a  '
                                  '${periodoFinal.substring(6, 8)}/'
                                  '${periodoFinal.substring(4, 6)}/'
                                  '${periodoFinal.substring(0, 4)}',
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ), // Periodo Aquisitivo
                          const Divider(
                            height: 2,
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                ),
                                Text(
                                  (diasSzh < diasDireito)
                                      ? '${diasSzh.toString()} Dias'
                                      : '${diasDireito.toString()} Dias',
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ), // Dias Pendentes
                          const Divider(
                            height: 2,
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0, right: 20),
                                  child: Icon(
                                    Icons.edit_calendar,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                ),
                                Text(
                                  '${qtdeDias.toString()} Dias',
                                  style: GoogleFonts.actor(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ), // Dias Solicitados
                          const Divider(
                            height: 2,
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0, left: 10, right: 10),
                            child: TextField(
                                controller: inicioController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  labelText: "Inicio das Férias: ",
                                ),
                                readOnly: true,
                                onTap: () async {
                                  pickedDateInicio = await showDatePicker(
                                    selectableDayPredicate: (DateTime date) {
                                      if (date.weekday == DateTime.saturday ||
                                          date.weekday == DateTime.sunday) {
                                        return false;
                                      }
                                      return true;
                                    },
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: initialDate,
                                    lastDate: lastDate,
                                  );

                                  if (pickedDateInicio != null) {
                                    String formattedDate = DateFormat('dd/MM/yyyy')
                                        .format(pickedDateInicio!);

                                    setState(() {
                                      inicioController.text =
                                          formattedDate; //set foratted date to TextField value.
                                    });
                                  } else {
                                    String formattedDate =
                                        DateFormat('dd/MM/yyyy').format(initialDate);

                                    setState(() {
                                      formattedDate; //set foratted date to TextField value.
                                    });
                                  }
                                }),
                          ), // Inicio Ferias
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0, left: 10, right: 10),
                            child: TextField(
                                controller: fimController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  labelText: "Fim das Férias: ",
                                ),
                                readOnly: true,
                                onTap: () async {
                                  pickedDateFim = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        DateTime.now().add(const Duration(days: 10)),
                                    firstDate:
                                        DateTime.now().add(const Duration(days: 10)),
                                    lastDate: lastDate,
                                  );

                                  if (pickedDateFim != null) {
                                    String formattedDate = DateFormat('dd/MM/yyyy')
                                        .format(pickedDateFim!);

                                    setState(() {
                                      fimController.text = formattedDate;
                                      validateDate(context);
                                    });
                                  } else {
                                    String formattedDate =
                                        DateFormat('dd/MM/yyyy').format(initialDate);

                                    setState(() {
                                      formattedDate; //set foratted date to TextField value.
                                    });
                                  }
                                }),
                          ), // Fim Ferias
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0, bottom: 30),
                            child: (isRequestReady)
                                ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            isRequestReady = false;
                                          });
                                          validateDate(context);
                                          (validateDaysAvailable ||
                                                  validateDateWeekend ||
                                                  validateEndHoliday ||
                                                  validatePeriodLong ||
                                                  validateStartHoliday)
                                              ? ErrorDialog(
                                                  context,
                                                  'Existem erros que impedem a '
                                                  'solicitação do período de férias, favor verificar!')
                                              : registerSzh010(context);
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
                                      )
                                : InkWell(
                                    onTap: () {
                                        ErrorDialog(context, 'Aguarde o processamento.');
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
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(
                        (diasSzh < 40 || diasSrh < 40)
                            ? 'Períodos Solicitados'
                            : 'Nenhum Período Solicitado',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(100),
                        2: FlexColumnWidth(),
                        3: FlexColumnWidth(),
                        4: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: tableContainer,
                    ),
                  ],
                ),
              ),
            ),
            drawer: menuDrawer(context),
          )
        : Scaffold(
          backgroundColor: Colors.blueGrey.withAlpha(30),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: Colors.black.withAlpha(20), // Border color
                          width: 1, // Border width
                        ),
                      ),                      
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      widget.sze010.ze_nome.trim(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.actor(
                                        textStyle: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ), // Nome
                            const Divider(
                              height: 2,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.date_range,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      '${periodoInicial.substring(6, 8)}/'
                                      '${periodoInicial.substring(4, 6)}/'
                                      '${periodoInicial.substring(0, 4)}  a  '
                                      '${periodoFinal.substring(6, 8)}/'
                                      '${periodoFinal.substring(4, 6)}/'
                                      '${periodoFinal.substring(0, 4)}',
                                      style: GoogleFonts.actor(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ), // Periodo Aquisitivo
                            const Divider(
                              height: 2,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      (diasSzh < diasDireito)
                                          ? '${diasSzh.toString()} Dias'
                                          : '${diasDireito.toString()} Dias',
                                      style: GoogleFonts.actor(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ), // Dias Pendentes
                            const Divider(
                              height: 2,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_calendar,
                                    size: 25,
                                    color: Colors.black.withAlpha(130)
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      '${qtdeDias.toString()} Dias',
                                      style: GoogleFonts.actor(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ), // Dias Solicitados
                            const Divider(
                              height: 2,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: TextField(
                                  controller: inicioController,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration(
                                    labelText: "Inicio das Férias: ",
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    pickedDateInicio = await showDatePicker(
                                      selectableDayPredicate: (DateTime date) {
                                        if (date.weekday == DateTime.saturday ||
                                            date.weekday == DateTime.sunday) {
                                          return false;
                                        }
                                        return true;
                                      },
                                      context: context,
                                      initialDate: initialDate,
                                      firstDate: initialDate,
                                      lastDate: lastDate,
                                    );
                        
                                    if (pickedDateInicio != null) {
                                      String formattedDate = DateFormat('dd/MM/yyyy')
                                          .format(pickedDateInicio!);
                        
                                      setState(() {
                                        inicioController.text = formattedDate;
                                      });
                                    } else {
                                      String formattedDate =
                                          DateFormat('dd/MM/yyyy').format(initialDate);
                        
                                      setState(() {
                                        formattedDate; //set foratted date to TextField value.
                                      });
                                    }
                                  }),
                            ), // Inicio Ferias
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: TextField(
                                  controller: fimController,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration(
                                    labelText: "Fim das Férias: ",
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    pickedDateFim = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          DateTime.now().add(const Duration(days: 10)),
                                      firstDate:
                                          DateTime.now().add(const Duration(days: 10)),
                                      lastDate: lastDate,
                                    );
                        
                                    if (pickedDateFim != null) {
                                      String formattedDate = DateFormat('dd/MM/yyyy')
                                          .format(pickedDateFim!);
                        
                                      setState(() {
                                        validateDate(context);
                                        if (validateDaysAvailable ||
                                            validateDateWeekend ||
                                            validateEndHoliday ||
                                            validatePeriodLong ||
                                            validateStartHoliday ||
                                            validatePeriodAvailable) {
                                          fimController.text = '';
                                          inicioController.text = '';
                                          qtdeDias = 0;
                                          diasDireito = ((diasSzh <
                                                      widget.sze010.ze_saldfer.round())
                                                  ? diasSzh
                                                  : widget.sze010.ze_saldfer.round()) -
                                              qtdeDias;
                                        } else {
                                          fimController.text = formattedDate;
                                        }
                                      });
                                    } else {
                                      String formattedDate =
                                          DateFormat('dd/MM/yyyy').format(initialDate);
                        
                                      setState(() {
                                        formattedDate; //set foratted date to TextField value.
                                      });
                                    }
                                  }),
                            ), // Fim Ferias
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0, bottom: 30),
                              child: (isRequestReady)
                                  ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            isRequestReady = false;
                                          });
                                          validateDate(context);
                                          (validateDaysAvailable ||
                                                  validateDateWeekend ||
                                                  validateEndHoliday ||
                                                  validatePeriodLong ||
                                                  validateStartHoliday ||
                                                  validatePeriodAvailable)
                                              ? ErrorDialog(
                                                  context,
                                                  'Existem erros que impedem a '
                                                  'solicitação do período de férias, favor verificar!')
                                              : registerSzh010(context);
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
                                      )
                                  : InkWell(
                                      onTap: () {
                                          ErrorDialog(context, 'Aguarde o processamento.');
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text(
                        (diasSzh < 40 || diasSrh < 40)
                            ? 'Períodos Solicitados'
                            : 'Nenhum Período Solicitado',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(100),
                        2: FlexColumnWidth(),
                        3: FlexColumnWidth(),
                        4: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: tableContainer,
                    ),
                  ],
                ),
              ),
            ),
            drawer: menuDrawer(context),
          );
  }

  void validateDate(BuildContext context) {
    if (pickedDateInicio != null) {
      qtdeDias = pickedDateFim!.difference(pickedDateInicio!).inDays + 1;
      diasDireito = ((diasSzh < widget.sze010.ze_saldfer.round())
              ? diasSzh
              : widget.sze010.ze_saldfer.round()) -
          qtdeDias;

      if (validation.startHoliday(pickedDateInicio)) {
        ErrorDialog(context, 'Férias não pode iniciar em Feriado!');
        validateStartHoliday = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validateStartHoliday = false;
      }

      if (validation.endHoliday(pickedDateInicio, pickedDateFim, diasDireito)) {
        ErrorDialog(
            context,
            'Férias não pode terminar em Véspera de Feriado,'
            ' exceto no encerramento do período!');
        validateEndHoliday = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validateEndHoliday = false;
      }

      if (validation.daysAvailable(qtdeDias, diasDireito)) {
        ErrorDialog(context, 'Dias solicitados maior que dias disponíveis!');
        validateDaysAvailable = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validateDaysAvailable = false;
      }

      if (validation.periodLong(qtdeDias, diasDireito)) {
        ErrorDialog(
            context,
            'Férias não pode ser menor que 7 dias, '
            'exceto no encerramento do período!');
        validatePeriodLong = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validatePeriodLong = false;
      }

      if (validation.dateWeekend(pickedDateFim, diasDireito)) {
        ErrorDialog(
            context,
            'Férias não pode terminar Sexta-Feira ou Sábado, '
            'exceto no encerramento do período!');
        validateDateWeekend = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validateDateWeekend = false;
      }

      if (validation.periodAvailable(widget.sze010.ze_mat, periodoInicial,
          periodoFinal, pickedDateInicio!, pickedDateFim!)) {
        ErrorDialog(
            context,
            'O período que está solicitando faz parte de outro período '
            'já solicitado, favor rever!');
        validatePeriodAvailable = true;
        setState(() {
          isRequestReady = true;
        });
      } else {
        validatePeriodAvailable = false;
      }
    }
  }

  registerSzh010(BuildContext context) async {
    Szh010Service szh010Service = Szh010Service();
    Sqb010Service _getMail = Sqb010Service();
    String mailTo = '';

    _getMail
        .getEmail(widget.sze010.ze_depto)
        .then((List<EmailDpto> listEmailDpto) {
      for (EmailDpto emailDpto in listEmailDpto) {
        mailTo = emailDpto.qb_email;
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? name = prefs.getString('first_name');
      String emailMessage =
          '${widget.sze010.ze_nome.trim()} fez a requisição do '
          'seguinte período de férias:\n'
          'Inicio: ${inicioController.text.substring(0, 2)}/'
          '${inicioController.text.substring(3, 5)}/'
          '${inicioController.text.substring(6, 10)}\n'
          'Fim: ${fimController.text.substring(0, 2)}/'
          '${fimController.text.substring(3, 5)}/'
          '${fimController.text.substring(6, 10)}\n'
          'Totalizando: $qtdeDias dia(s)\n'
          'Entre no aplicativo para aprovar ou rejeitar essa solicitação.';

      Szh010 internalSzh010 = Szh010(
          zh_mat: widget.sze010.ze_mat,
          zh_inipaq: periodoInicial,
          zh_fimpaq: periodoFinal,
          zh_saldfer: double.parse(diasDireito.toString()),
          zh_diasfer: double.parse(qtdeDias.toString()),
          zh_dataini: inicioController.text.substring(6, 10) +
              inicioController.text.substring(3, 5) +
              inicioController.text.substring(0, 2),
          zh_datafim: fimController.text.substring(6, 10) +
              fimController.text.substring(3, 5) +
              fimController.text.substring(0, 2),
          zh_aprvges: '2',
          zh_aprvdir: '2',
          zh_recibvi: '2',
          zh_dtrecvi: '2',
          zh_recibap: '2',
          zh_dtrecap: '',
          zh_integra: '2',
          zh_depto: widget.sze010.ze_depto,
          r_e_c_n_o_field: 0,
          r_e_c_d_e_l_field: 0,
          d_e_l_e_t_field: '');

      szh010Service.register(internalSzh010).then((value) {
        setState(() {
          isRequestReady = true;
        });
        if (value) {
          Navigator.pop(context, DisposeStatus.success);
          if (group == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Szh010Screen(
                        isloading: true,
                      )),
            );
          } else {
            if (group != null && name != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                      selectedIndex: 0, userGroup: group, name: name),
                ),
              );
            }
          }
          return SuccessDialog(
              context, 'Solicitação de Férias Feita com Sucesso!');
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

  void getSrf010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      int ano = int.parse(widget.sze010.ze_fperaq.substring(0, 4)) - 1;
      String periodo = '$ano${widget.sze010.ze_fperaq.substring(4, 8)}';

      if (firstName != null && lastName != null) {
        _srf010service
            .getAll(widget.sze010.ze_mat, periodo)
            .then((List<Srf010> listSrf010) {
          setState(() {
            for (Srf010 srf010 in listSrf010) {
              periodoInicial = srf010.rf_databas;
              periodoFinal = srf010.rf_datafim;
            }
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  void getSzh010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      int ano = int.parse(widget.sze010.ze_fperaq.substring(0, 4)) - 1;
      String periodo = '$ano${widget.sze010.ze_fperaq.substring(4, 8)}';

      if (firstName != null && lastName != null) {
        _szh010service.getAll().then((List<Szh010> listSzh010) {
          setState(() {
            for (Szh010 szh010 in listSzh010) {
              if (szh010.zh_mat == widget.sze010.ze_mat) {
                if (periodo == szh010.zh_inipaq) {
                  if (szh010.zh_aprvdir != '2' ||
                      szh010.zh_aprvges != '2' ||
                      szh010.zh_integra == '0') {
                    databaseShz[szh010.zh_dataini] = szh010;
                  }
                }
              }
            }

            databaseShz.forEach((key, value) {
              if (value.zh_dataini != '        ') {
                if (diasSzh == 40) {
                  diasSzh = widget.sze010.ze_saldfer.round() -
                      value.zh_diasfer.round();
                } else {
                  diasSzh = diasSzh - value.zh_diasfer.round();
                }

                if (tableTab == false) {
                  tableContainer.add(
                    TableRow(
                      children: <Widget>[
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
                        Container(
                          height: 25,
                          color: Colors.greenAccent,
                          child: Text(
                            'Dias',
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
                            'Status',
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
                            'Excluir',
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
                  tableTab = true;
                }

                tableContainer.add(
                  TableRow(
                    children: <Widget>[
                      Container(
                        height: 28,
                        color: Colors.white,
                        child: Text(
                          '${value.zh_dataini.substring(6, 8)}/'
                          '${value.zh_dataini.substring(4, 6)}/'
                          '${value.zh_dataini.substring(0, 4)}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 28,
                        color: Colors.white,
                        child: Text(
                          '${value.zh_datafim.substring(6, 8)}/'
                          '${value.zh_datafim.substring(4, 6)}/'
                          '${value.zh_datafim.substring(0, 4)}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 28,
                        color: Colors.white,
                        child: Text(
                          value.zh_diasfer.round().toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 28,
                        color: Colors.white,
                        child:
                            (value.zh_aprvges == '0' && value.zh_aprvdir == '0')
                                ? const Icon(
                                    Icons.query_builder,
                                    size: 18,
                                  )
                                : (value.zh_aprvges == '1' &&
                                        value.zh_aprvdir == '0')
                                    ? const Icon(
                                        Icons.person,
                                        size: 18,
                                      )
                                    : (value.zh_aprvges == '1' &&
                                            value.zh_aprvdir == '1' &&
                                            value.zh_integra == '0')
                                        ? const Icon(
                                            Icons.people,
                                            size: 18,
                                          )
                                        : (value.zh_aprvges == '2' ||
                                                value.zh_aprvdir == '2')
                                            ? const Icon(
                                                Icons.cancel_rounded,
                                                size: 18,
                                              )
                                            : const Icon(
                                                Icons.check_sharp,
                                                size: 18,
                                              ),
                      ),
                      Center(
                        child: Container(
                          height: 28,
                          color: Colors.white,
                          child: ((value.zh_aprvdir == '0' &&
                                      value.zh_aprvges == '0') ||
                                  (value.zh_aprvdir == '2' ||
                                      value.zh_aprvges == '2'))
                              ? IconButton(
                                  icon: const Icon(Icons.cancel_rounded),
                                  onPressed: () {
                                    Szh010 internalSzh010 = Szh010(
                                        zh_mat: value.zh_mat,
                                        zh_inipaq: value.zh_inipaq,
                                        zh_fimpaq: value.zh_fimpaq,
                                        zh_saldfer: value.zh_saldfer,
                                        zh_diasfer: value.zh_diasfer,
                                        zh_dataini: value.zh_dataini,
                                        zh_datafim: value.zh_datafim,
                                        zh_aprvges: value.zh_aprvges,
                                        zh_aprvdir: value.zh_aprvdir,
                                        zh_recibvi: value.zh_recibvi,
                                        zh_dtrecvi: value.zh_dtrecvi,
                                        zh_recibap: value.zh_recibap,
                                        zh_dtrecap: value.zh_dtrecap,
                                        zh_integra: value.zh_integra,
                                        zh_depto: value.zh_depto,
                                        r_e_c_n_o_field: value.r_e_c_n_o_field,
                                        r_e_c_d_e_l_field:
                                            value.r_e_c_n_o_field,
                                        d_e_l_e_t_field: '*');

                                    deleteSzh010(
                                      context,
                                      internalSzh010,
                                      value.r_e_c_n_o_field,
                                    );
                                  },
                                  iconSize: 15,
                                  alignment: Alignment.topCenter,
                                  tooltip: 'Excluir solicitação.',
                                )
                              : const Icon(
                                  Icons.do_disturb_on_outlined,
                                  size: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            });

            getSrh010();
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  void getSrh010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      int ano = int.parse(widget.sze010.ze_fperaq.substring(0, 4)) - 1;
      String periodo = '$ano${widget.sze010.ze_fperaq.substring(4, 8)}';

      if (firstName != null && lastName != null) {
        _srh010service
            .getAll(widget.sze010.ze_mat, periodo)
            .then((List<Srh010> listSrh010) {
          setState(() {
            for (Srh010 srh010 in listSrh010) {
              if (srh010.rh_mat == widget.sze010.ze_mat) {
                if (srh010.rh_dataini != '        ') {
                  diasSrh = srh010.rh_dferven.round();
                }
                databaseSrh[srh010.rh_dataini] = srh010;
              }
            }

            databaseSrh.forEach((key, value) {
              if (value.rh_dataini != '        ') {
                if (tableTab == false) {
                  tableContainer.add(
                    TableRow(
                      children: <Widget>[
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
                        Container(
                          height: 25,
                          color: Colors.greenAccent,
                          child: Text(
                            'Dias',
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
                            'Status',
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
                            'Excluir',
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
                  tableTab = true;
                }

                tableContainer.add(
                  TableRow(
                    children: <Widget>[
                      Container(
                        height: 25,
                        color: Colors.white,
                        child: Text(
                          '${value.rh_dataini.substring(6, 8)}/'
                          '${value.rh_dataini.substring(4, 6)}/'
                          '${value.rh_dataini.substring(0, 4)}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
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
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
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
                          value.rh_dferias.round().toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 25,
                        color: Colors.white,
                        child: const Icon(
                          Icons.check_sharp,
                          size: 18,
                        ),
                      ),
                      Container(
                          height: 25,
                          color: Colors.white,
                          child: const Icon(
                            Icons.do_disturb_on_outlined,
                            size: 18,
                          )),
                    ],
                  ),
                );
              }
            });
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  deleteSzh010(BuildContext context, Szh010 internalSzh010, int recno) async {
    Szh010Service szh010Service = Szh010Service();

    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? name = prefs.getString('first_name');

      szh010Service.edit(recno, internalSzh010).then((value) {
        if (value) {
          if (group == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Szh010Screen(
                        isloading: true,
                      )),
            );
          } else {
            if (group != null && name != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                      selectedIndex: 0, userGroup: group, name: name),
                ),
              );
            }
          }
          return SuccessDialog(context, 'Exclusão Feita com Sucesso!');
        } else {
          Navigator.pop(context, DisposeStatus.error);
          return ErrorDialog(context, 'Erro na solicitação, tente mais tarde!');
        }
      });
    });
  }
}

enum DisposeStatus { exit, error, success }
