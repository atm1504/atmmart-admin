import 'package:atmmartadmin/utils/constants.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class BrandService {
  Firestore _firestore = Firestore.instance;

  void createBrand(String name) {
    String brandId = getUuid();

    _firestore.collection(BRANDS).document(brandId).setData({'brand': name});
  }

  Future<List<DocumentSnapshot>> getBrands() {
    _firestore.collection(BRANDS).getDocuments().then((snaps) {
      print(snaps.documents.length);
      return snaps.documents;
    });
  }
}
