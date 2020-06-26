import 'package:atmmartadmin/utils/constants.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class BrandService {
  Firestore _firestore = Firestore.instance;

  void createBrand(String name) {
    String brandId = getUuid();

    _firestore.collection(BRANDS).document(brandId).setData({BRAND: name});
  }

  Future<List<DocumentSnapshot>> getBrands() =>
      _firestore.collection(BRANDS).getDocuments().then((snaps) {
        return snaps.documents;
      });

  Future<List<DocumentSnapshot>> getBrandSuggestions(String suggestion) =>
      _firestore
          .collection(BRANDS)
          .where(BRAND, isEqualTo: suggestion)
          .getDocuments()
          .then((snap) {
        print(suggestion);
        print(snap.documents.length);
        return snap.documents;
      });
}
