import 'package:atmmartadmin/utils/constants.dart';
import 'package:atmmartadmin/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  Firestore _firestore = Firestore.instance;

  void createCategory(String name) {
    String categoryId = getUuid();

    _firestore
        .collection(CATEGORIES)
        .document(categoryId)
        .setData({CATEGORY: name});
  }

  Future<List<DocumentSnapshot>> getCategories() {
    _firestore.collection(CATEGORIES).getDocuments().then((snaps) {
      print(snaps.documents.length);
      return snaps.documents;
    });
  }
}
