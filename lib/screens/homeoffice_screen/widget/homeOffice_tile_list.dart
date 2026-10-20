import 'package:projeto_aucs/models/home_office_list_names.dart';
import 'package:projeto_aucs/screens/homeoffice_screen/widget/HomeOffice_tile_card.dart';

List<HomeOfficeTileCard> generateListTilHomeOffice({
  required Map<int, HomeOfficeListNames>? database,
}) {

  List<HomeOfficeTileCard> list = [];

  if(database != null ){
    database.forEach((key, value) {
      list.add(HomeOfficeTileCard(
        name: value.ze_nome.trim(),
      ));
    });
  }

  return list;

}
