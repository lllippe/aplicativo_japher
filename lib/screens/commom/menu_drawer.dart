import 'package:flutter/material.dart';
import 'package:projeto_aucs/helpers/logout.dart';
import 'package:projeto_aucs/screens/commom/under_construction.dart';
import 'package:projeto_aucs/screens/home_screen/home_screen.dart';
import 'package:projeto_aucs/screens/solicitacao_screen/solicitacao_screen.dart';
import 'package:projeto_aucs/screens/sze010_screen/sze010_screen.dart';
import 'package:projeto_aucs/screens/szh010_screen/szh010_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String email = '';
String userGroup = '';

ListView menuDrawer(BuildContext context) {
  void returnHome() async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');
      String? user = prefs.getString('first_name');

      if (group != null && user != null) {
        //if (group == '1') {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(
                    selectedIndex: 0,
                    name: user,
                    userGroup: group,
                  ),
            ),
          );
        //} else {
        //  Navigator.pushReplacementNamed(context, 'home');
        //}
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }
  refresh();

  return (userGroup == '1')
    ? ListView(
    children: [
      ListTile(
        leading: Icon(
          Icons.home,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Home'),
        onTap: () {
          returnHome();
          //Navigator.pushReplacementNamed(context, 'home');
        },
      ),
      ListTile(
        leading: Icon(
          Icons.airplane_ticket_rounded,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Manutenção - Férias'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Szh010Screen(isloading: true,)),
          );
        },
      ),
      ListTile(
        leading: Icon(
          Icons.calendar_month,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Manutenção - Ponto Eletrônico'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UnderConstruction('assets/images/construcao.png')),
          );
        },
      ),
      ListTile(
        leading: Icon(
          Icons.account_circle,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Manutenção - Colaborador'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Sze010Screen(isloading: true,)),
          );
        },
      ),
      ListTile(
        leading: Icon(
          Icons.door_front_door_outlined,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Manutenção - Solicitações'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SolicitacaoScreen(group: userGroup, isloading: true,)),
          );
        },
      ),
      ListTile(
        leading: Icon(
          Icons.logout,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text("Sair"),
        onTap: () {
          logout(context);
        },
      )
    ],
  )
    : ListView(
    children: [
      ListTile(
        leading: Icon(
          Icons.home,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text('Home'),
        onTap: () {
          returnHome();
          //Navigator.pushReplacementNamed(context, 'home');
        },
      ),
      ListTile(
        leading: Icon(
          Icons.logout,
          color: Colors.black.withAlpha(80),
        ),
        title: const Text("Sair"),
        onTap: () {
          logout(context);
        },
      )
    ],
  );
}

void refresh() async {
  await SharedPreferences.getInstance().then(
    (prefs) {
      String? email_prefs = prefs.getString('first_name');
      String? group = prefs.getString('group');

      if (email_prefs != null) {
        email = email_prefs;
      }
      if (group != null) {
        userGroup = group;
      }
    },
  );
}


