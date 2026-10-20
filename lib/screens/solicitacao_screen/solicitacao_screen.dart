import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sqb010.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:projeto_aucs/models/szh010.dart';
import 'package:projeto_aucs/screens/commom/menu_drawer.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/screens/solicitacao_screen/solicitacao_screen_list.dart';
import 'package:projeto_aucs/services/sze010_service.dart';
import 'package:projeto_aucs/services/szh010_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolicitacaoScreen extends StatefulWidget {
  final bool isloading;
  final String group;

  const SolicitacaoScreen({Key? key, required this.group, required this.isloading}) : super(key: key);

  @override
  State<SolicitacaoScreen> createState() => _SolicitacaoScreenState();
}

class _SolicitacaoScreenState extends State<SolicitacaoScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;
  int soma = 0;

  // A base de dados mostrada na lista
  Map<String, Sze010> database = {};
  Map<int, Szh010> databaseSzh = {};
  final Szh010Service _szh010Service = Szh010Service();
  final Sze010Service _sze010service = Sze010Service();
  final ScrollController _controller = ScrollController();
  final Sze010Service _sze010Service = Sze010Service();
  final Sze010 sze010 = Sze010.empty();
  final Sqb010 sqb010 = Sqb010.empty();
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: const Text(
          "Solicitações Férias",
        ),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            onPressed: () {
              refresh();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitacaoScreen(
                    isloading: true,
                    group: userGroup,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: (_isloading)
      ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        )
      : (soma > 0)
           ? ListView(
              controller: _controller,
              children: generateListSolicitacaoCards(
                databaseSzh: databaseSzh,
                database: database,
              ),
            )
          : Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.check,
                    size: 30,
                    color: Colors.black.withAlpha(80),
                  ),
                ),
                Text(
                    'Não há solicitações pendentes!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.actor(
                      textStyle: const TextStyle(fontSize: 20),
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),
      drawer: Drawer(
        child: menuDrawer(context),
      ),
    );
  }

  void refresh() async {
    SharedPreferences.getInstance().then((prefs) {
      String? firstName = prefs.getString('first_name');
      String? lastName = prefs.getString('last_name');
      String? userGroup = prefs.getString('group');
      String? userId = prefs.getString('id');

      if (firstName != null &&
          lastName != null &&
          userGroup != null &&
          userId != null) {
        _sze010service.getId(userId).then((List<Sze010> listSze010) {
          //setState(() {
            for (Sze010 sze010 in listSze010) {
              if (userId == sze010.ze_mat) {
                _szh010Service
                    .getGroup(int.parse(sze010.ze_depto), int.parse(userGroup))
                    .then((List<Szh010> listSzh010) {
                  setState(() {
                    databaseSzh = {};
                    for (Szh010 szh010 in listSzh010) {
                      databaseSzh[szh010.r_e_c_n_o_field] = szh010;
                    }
                    databaseSzh.forEach((key, value) {
                      soma += 1;
                    });
                    _isloading = false;
                  });
                });
              }
            }
          //});
        });

        _sze010Service.getAll().then((List<Sze010> listSze010) {
          setState(() {
            database = {};
            for (Sze010 sze010 in listSze010) {
                database[sze010.ze_mat] = sze010;
            }
          });
        });

      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }

  void returnHome() async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? user = prefs.getString('first_name');

      if (group != null && user != null) {
        HomeScreen(
          selectedIndex: 0,
          name: user,
          userGroup: group,
        );
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
}
