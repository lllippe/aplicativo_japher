import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aucs/models/aniversarios.dart';

class ContainerWarningScreen extends StatefulWidget {
  final Aniversarios? aniversarios;
  final String userId;
  final Function refreshFunction;
  final bool lastLine;

  const ContainerWarningScreen({
    Key? key,
    this.aniversarios,
    required this.userId,
    required this.refreshFunction,
    required this.lastLine,
  }) : super(key: key);

  @override
  State<ContainerWarningScreen> createState() => _ContainerWarningScreenState();
}

class _ContainerWarningScreenState extends State<ContainerWarningScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.aniversarios?.ze_nome != null) {
      return ListTile(
        title: Row(
          children: [
            Icon(
              Icons.cake_outlined,
              size: 30,
              color: Colors.black.withAlpha(80),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text(
                  '${widget.aniversarios!.ze_nome.trim()} - ${DateFormat('dd/MM').format(DateTime.parse(widget.aniversarios!.ze_niver))}',
                  overflow: TextOverflow.values.first,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.actor(
                    textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 59, 25, 25)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return InkWell(
        onTap: () {},
        child: Container(
          height: 115,
          alignment: Alignment.center,
          child: const Text(
            'Nenhum aniversário esse mês!',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
