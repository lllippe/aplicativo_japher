import 'package:projeto_aucs/models/aniversarios.dart';
import 'package:projeto_aucs/screens/warning_screen/warning_container_screen.dart';

List<ContainerWarningScreen> generateWarningScreen({
  required Map<String, Aniversarios> database,
  required Function refreshFunction,
  required String userId,
}) {
  List<ContainerWarningScreen> list = [];
  DateTime currentDay = DateTime.now();
  currentDay.month;
  int count = 0;
  int size = database.length;
  database.forEach(
        (key, value) {
      if (value.ze_niver != "        ") {
        if (DateTime.parse(value.ze_niver).month == currentDay.month){
          list.add(
            ContainerWarningScreen(
              userId: userId,
              aniversarios: value,
              refreshFunction: refreshFunction,
              lastLine: (count == size)? true : false,
            ),
          );
        }
      }
      count++;
    },
  );
  return list;
}
