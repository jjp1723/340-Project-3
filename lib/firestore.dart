import 'package:cloud_firestore/cloud_firestore.dart';
import 'amiibo.dart';

// A reference to the FireStore collection
CollectionReference favoritesReference =
    FirebaseFirestore.instance.collection("FavoriteAmiibos");

// addData Method add or updates data to the FireStore collection
Future addData(Amiibo amiibo) async {
  Map<String, dynamic> amiiboMap = convertAmiiboToMap(amiibo);

  try {
    DocumentSnapshot amiiboDoc =
        await favoritesReference.doc(amiibo.model).get();
    // If there is already a relevant document for an amiibo, its data is updated
    if (amiiboDoc.exists) {
      amiiboMap["favorites"] = amiiboDoc.get("favorites") + 1;
      favoritesReference.doc(amiibo.model).update(amiiboMap);
    }
    // If there is not already a relevant document for an amiibo, one is created
    else {
      favoritesReference.doc(amiibo.model).set(amiiboMap);
    }
  } catch (e) {
    throw (e);
  }
}

// removeData Method
Future removeData(Amiibo amiibo) async {
  Map<String, dynamic> amiiboMap = convertAmiiboToMap(amiibo);

  try {
    DocumentSnapshot amiiboDoc =
        await favoritesReference.doc(amiibo.model).get();
    // If there is already a relevant document for an amiibo, its data is updated
    if (amiiboDoc.exists) {
      amiiboMap["favorites"] = amiiboDoc.get("favorites") - 1;
      // Prevents the updated favorites count from dropping below 0
      if (amiiboMap["favorites"] < 0) {
        amiiboMap["favorites"] = 0;
      }
      favoritesReference.doc(amiibo.model).update(amiiboMap);
    }
    // If, for some reason, there is not already a relevant document for an amiibo, one is created
    else {
      favoritesReference.doc(amiibo.model).set(amiiboMap);
    }
  } catch (e) {
    throw e;
  }
}

// loadData Method
Future loadData(List<Amiibo> favorites) async {
  QuerySnapshot favoritesSnapshot = await favoritesReference.get();

  for (int i = 0; i < favoritesSnapshot.size; i++) {
    String id = favoritesSnapshot.docs[i].id;
    DocumentSnapshot amiiboDoc = await favoritesReference.doc(id).get();
    favorites.add(Amiibo(
        amiiboDoc.get("character"),
        amiiboDoc.get("gameSeries"),
        amiiboDoc.get("amiiboSeries"),
        amiiboDoc.get("modelHead"),
        amiiboDoc.get("modelTail"),
        amiiboDoc.get("releaseNA"),
        amiiboDoc.get("releaseEU"),
        amiiboDoc.get("releaseJP"),
        amiiboDoc.get("releaseAU"),
        amiiboDoc.get("imageURL"),
        amiiboDoc.get("favorites")));
  }
  return favorites;
}
