import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_aucs/models/sze010.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddHomeOfficeTileCard extends StatefulWidget {
  final Sze010? sze010;
  final List<String>? selectedItems;

  const AddHomeOfficeTileCard({Key? key, this.sze010, this.selectedItems})
      : super(key: key);

  @override
  State<AddHomeOfficeTileCard> createState() => _AddHomeOfficeTileCardState();
}

class _AddHomeOfficeTileCardState extends State<AddHomeOfficeTileCard> {
  String groupUpdate = '';
  List _selectedItems = [];

  @override
  void initState() {
    super.initState();
    getSze010();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sze010 != null) {
      return ListTile(
        tileColor:
            (widget.selectedItems!.contains(widget.sze010!.ze_mat.trim())
                ? Colors.red
                : Colors.transparent),
        title: Text(
          widget.sze010!.ze_nome.trim(),
          style: GoogleFonts.actor(
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color:
                  (widget.selectedItems!.contains(widget.sze010!.ze_mat.trim())
                      ? Colors.white
                      : Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        onLongPress: () {
          if (!widget.selectedItems!.contains(widget.sze010!.ze_mat.trim())) {
            setState(
                () => widget.selectedItems!.add(widget.sze010!.ze_mat.trim()));
          }
        },
        onTap: () {
          if (widget.selectedItems!.contains(widget.sze010!.ze_mat.trim())) {
            setState(() =>
                widget.selectedItems!.remove(widget.sze010!.ze_mat.trim()));
          }
        },
      );
    } else {
      return ListTile(
        title: Text(
          'Nenhuma hora cadastrado',
          style: GoogleFonts.actor(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
  }

  void getSze010() async {
    SharedPreferences.getInstance().then((prefs) {
      String? group = prefs.getString('group');

      if (group != null) {
        setState(() {
          groupUpdate = group;
        });
      }
    });
  }
}

enum DisposeStatus { exit, error, success }
