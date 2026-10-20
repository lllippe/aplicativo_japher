import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<dynamic> insertDaysDialog(BuildContext context,) {
  return showDialog(
    context: context,
    builder: (context) {
      int daysVacation = 0;
      return AlertDialog(
        title: const Text('Deseja inserir dias de férias no banco?'),
        content: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text('Selecione quantidade de horas',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                ),
              ),
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
                      size: 30,
                    ),
                    onTap: () {
                      if (daysVacation > 0) {
                        daysVacation -= 1;
                      }
                    },),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Text(daysVacation.toString(),
                      style: GoogleFonts.actor(
                        textStyle: const TextStyle(fontSize: 20),
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  InkWell(
                    child: Icon(
                      Icons.add_circle_rounded, 
                      color: Colors.black.withAlpha(200), 
                      size: 30,
                    ),
                    onTap: () {
                      daysVacation += 1;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, [false, 0]);
            },
            child: const Text(
              "Cancelar",
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, [true, daysVacation]);
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
