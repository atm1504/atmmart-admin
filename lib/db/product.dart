import 'package:atmmartadmin/utils/constants.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProductService {
  Firestore _firestore = Firestore.instance;

  void uploadProduct(Map<String, dynamic> data) {
    String prodId = getUuid();
    data["id"] = prodId;
    _firestore.collection(PRODUCTS).document(prodId).setData(data);
  }
}
