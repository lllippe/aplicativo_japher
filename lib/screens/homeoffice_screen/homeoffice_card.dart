import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aucs/models/home_office_list_names.dart';
import 'package:projeto_aucs/models/sqb010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/screens/commom/error_dialog.dart';
import 'package:projeto_aucs/screens/homeoffice_screen/widget/homeOffice_tile_list.dart';
import 'package:projeto_aucs/services/homeoffice_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeOfficeCard extends StatefulWidget {
  const HomeOfficeCard({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeOfficeCard> createState() => _HomeOfficeCardState();
}

class _HomeOfficeCardState extends State<HomeOfficeCard> {
  Map<String, Sze010> database = {};
  Map<int, HomeOfficeListNames> databaseSzh = {};
  int soma = 0;

  final HomeOfficeService _homeOfficeService = HomeOfficeService();
  final Sze010Service _sze010service = Sze010Service();
  final ScrollController _controller = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  bool isExpanded = false;
  TextEditingController inicioController = TextEditingController();
  TextEditingController fimController = TextEditingController();
  DateTime? pickedDateFim;
  DateTime? pickedDateInicio;
  bool _isSearchReady = false;
  bool _showSearch = false;
  String returnSearch = 'Realize sua pesquisa.';
  String dateSearch = '';
  bool isRequestReady = true;

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.withAlpha(30),
      body: SingleChildScrollView(
        child: Container(
            child: _buildPanel(),
          ),
      ),
    );
  }

  Widget _buildPanel() {
    DateTime lastDate = DateTime.now().add(const Duration(days: 90));
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 90));
    var deviceData = MediaQuery.of(context);
    double width_screen = deviceData.size.width;
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment_rounded,
                      size: 28,
                      color: Colors.black.withAlpha(130),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        'HomeOffice',
                        style: GoogleFonts.actor(
                          fontSize: 25,
                          color: Colors.black.withAlpha(200),
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width_screen - 20,
                  height: 150,
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
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: TextField(
                              controller: inicioController,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                labelText: "Selecione a data: ",
                              ),
                              readOnly: true,
                              onTap: () async {
                                pickedDateInicio = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 2),
                          child: (isRequestReady)
                              ? InkWell(
                                  onTap: () {
                                      if (inicioController.text == '') {
                                        ErrorDialog(context, "Selecionar a data para consulta.");
                                      } else {
                                        setState(() {
                                          isRequestReady = false;
                                        });
                                        search();
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
                                                'Pesquisar',
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
                              : 
                              InkWell(
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
                                ),
                        ),
                      ],
                    ),
                  ), // Inicio Ferias
                ),
                (_isSearchReady)
                    ? (_showSearch)
                        ? Column(
                            children: [
                              databaseSzh.isEmpty
                                  ? Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: Colors.black.withAlpha(20), // Border color
                                          width: 1, // Border width
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: width_screen - 20,
                                        height: 40,
                                        child: Text(
                                          'Ninguém cadastrado presencial',
                                          style: GoogleFonts.actor(
                                            textStyle: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: Colors.black.withAlpha(20), // Border color
                                          width: 1, // Border width
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: width_screen - 20,
                                        height: 40,
                                        child: Text(
                                          'Presencial dia: $dateSearch',
                                          style: GoogleFonts.actor(
                                            textStyle: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                              Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                    color: Colors.black.withAlpha(20), // Border color
                                    width: 1, // Border width
                                  ),
                                ),
                                child: SizedBox(
                                  width: width_screen - 20,
                                  height: 400,
                                  child: Scrollbar(
                                    controller: _controller,
                                    thickness: 6,
                                    radius: const Radius.circular(5),
                                    child: ListView(
                                      controller: _listScrollController,
                                      children: generateListTilHomeOffice(
                                        database: databaseSzh,
                                      ),
                                    ),
                                  ),
                                ),
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
                          )
                    : Container()
              ],
            ),
          ],
        ),
      );
  }

  void search() {
    setState(() {
      if (inicioController.text != '') {
        setState(() {
          _showSearch = false;
        });
        getSze010();
        _isSearchReady = true;
        dateSearch = inicioController.text;
      } else {
        returnSearch = 'O campo Data Inicial não pode\n'
            'ficar em branco.';
      }
    });
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
      //widget.refreshFunction();

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

  void getSze010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');

      if (firstName != null && lastName != null) {
        String inicio = inicioController.text.substring(6, 10) +
            inicioController.text.substring(3, 5) +
            inicioController.text.substring(0, 2);

        _homeOfficeService
            .searchDay(inicio)
            .then((List<HomeOfficeListNames> listSzh010) {
          setState(() {
            databaseSzh = {};
            for (HomeOfficeListNames szh010 in listSzh010) {
              databaseSzh[soma] = szh010;
              soma += 1;
            }
          });
        });

        _sze010service.getAll().then((List<Sze010> listSze010) {
          setState(() {
            database = {};
            for (Sze010 sze010 in listSze010) {
              database[sze010.ze_nome] = sze010;
            }
            setState(() {
              isRequestReady = true;
            });
            _showSearch = true;
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}

enum DisposeStatus { exit, error, success }
