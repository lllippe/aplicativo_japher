import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/spi010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/add_screen/add_homeoffice_screen.dart';
import 'package:projeto_aucs/screens/homeoffice_screen/homeoffice_card.dart';
import 'package:projeto_aucs/services/homeoffice_service.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String userGroup = '';

class HomeOfficeScreen extends StatefulWidget {
  final bool isloading;

  const HomeOfficeScreen({Key? key, required this.isloading}) : super(key: key);

  @override
  State<HomeOfficeScreen> createState() => _HomeOfficeScreenState();
}

class _HomeOfficeScreenState extends State<HomeOfficeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Szh010> database = {};
  Map<String, Sze010> databaseSze = {};
  final Spi010 spi010 = Spi010.empty();
  final ScrollController listScrollController = ScrollController();
  final HomeOfficeService _homeOfficeService = HomeOfficeService();
  final Sze010Service _sze010Service = Sze010Service();
  String userId = '';
  final bool isEditing = false;
  bool _isloading = false;

  @override
  void initState() {
    refresh();
    super.initState();
    _isloading = widget.isloading;
  }

  @override
  Widget build(BuildContext context) {
    return (!_isloading)
        ? Scaffold(
            body: Scrollbar(
              controller: listScrollController,
              thickness: 6,
              child: (database.length > 0)
                ? const HomeOfficeCard()
                : ListTile(
                    title: Text(
                    'Nenhum colaborador cadastrado para trabalho presencial',
                    style: GoogleFonts.actor(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ),
            floatingActionButton: (userGroup == '1' || userGroup == '2')
                ? FloatingActionButton(
                    onPressed: () {
                      (userGroup == '1' || userGroup == '2')
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddHomeOfficeScreen(
                                      isLoading: true,
                                      isEditing: false,
                                      spi010: spi010),
                              ),
                            )
                          : Container();
                    },
                    mini: true,
                    backgroundColor: (userGroup == '1' || userGroup == '2')
                        ? Colors.greenAccent
                        : Colors.white,
                    child: (userGroup == '1' || userGroup == '2')
                        ? const Icon(
                            Icons.add,
                            color: Colors.black,
                          )
                        : Container(),
                  )
                : Container(),
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
      String? group = prefs.getString('group');

      if (group != null) {
        userGroup = group;
      }

      if (firstName != null && lastName != null) {
        _homeOfficeService.getAll().then((List<Szh010> listSzh010) {
          setState(() {
            database = {};
            for (Szh010 szh010 in listSzh010) {
              database[szh010.zh_dataini] = szh010;
            }
            _isloading = false;
          });
        });

        _sze010Service.getAll().then((List<Sze010> listSze010) {
          setState(() {
            databaseSze = {};
            for (Sze010 sze010 in listSze010) {
              databaseSze[sze010.ze_mat] = sze010;
            }
          });
        });
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
