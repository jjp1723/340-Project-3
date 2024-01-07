// ----- Amiibo Class -----
class Amiibo {
  // Fields for storing all relevant amiibo information
  String character = "";
  String gameSeries = "";
  String amiiboSeries = "";
  String model = "";
  String modelHead = "";
  String modelTail = "";
  String releaseNA = "";
  String releaseEU = "";
  String releaseJP = "";
  String releaseAU = "";
  String imageURL = "";
  int favorites = 0;
  Amiibo(String char, String game, String amiibo, String head, String tail,
      String na, String eu, String jp, String au, String url, int favs) {
    character = char;
    gameSeries = game;
    amiiboSeries = amiibo;
    model = head + tail;
    modelHead = head;
    modelTail = tail;
    releaseNA = na;
    releaseEU = eu;
    releaseJP = jp;
    releaseAU = au;
    imageURL = url;
    favorites = favs;
  }
}

// ----- Methods -----

// convertAmiiboToMap method converts an amiibo to a dynamic map of strings
Map<String, dynamic> convertAmiiboToMap(Amiibo amiibo) {
  Map<String, dynamic> mapped = {
    "character": amiibo.character,
    "gameSeries": amiibo.gameSeries,
    "amiiboSeries": amiibo.amiiboSeries,
    "modelHead": amiibo.modelHead,
    "modelTail": amiibo.modelTail,
    "releaseNA": amiibo.releaseNA,
    "releaseEU": amiibo.releaseEU,
    "releaseJP": amiibo.releaseJP,
    "releaseAU": amiibo.releaseAU,
    "imageURL": amiibo.imageURL,
    "favorites": amiibo.favorites,
  };
  return mapped;
}

// convertAmiiboToMap method converts all amiibos in a list to a list of dynamic maps of strings
List<Map<String, dynamic>> convertAllAmiiboToMapList(List<Amiibo> amiiboList) {
  List<Map<String, dynamic>> listed = [];
  for (int index = 0; index < amiiboList.length; index++) {
    listed.add(convertAmiiboToMap(amiiboList[index]));
  }
  return listed;
}

// convertAmiiboToMap method converts a dynamic map of strings to an amiibo
Amiibo convertMaptoAmiibo(Map<String, dynamic> map) {
  Amiibo amiibo = Amiibo(
      map["character"],
      map["gameSeries"],
      map["amiiboSeries"],
      map["modelHead"],
      map["modelTail"],
      map["releaseNA"],
      map["releaseEU"],
      map["releaseJP"],
      map["releaseAU"],
      map["imageURL"],
      map["favorites"]);
  amiibo.favorites = map["favorites"];
  return amiibo;
}

// convertAmiiboToMap method converts a list of dynamic maps of strings to a list of amiibos
List<Amiibo> convertListToAmiibos(List<dynamic> list) {
  List<Amiibo> listed = [];
  for (int index = 0; index < list.length; index++) {
    listed.add(convertMaptoAmiibo(list[index]));
  }
  return listed;
}
