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

  Future<List<DocumentSnapshot>> getCategories() =>
      _firestore.collection(CATEGORIES).getDocuments().then((snaps) {
        return snaps.documents;
      });

  Future<List<DocumentSnapshot>> getCategorySuggestions(String suggestion) =>
      _firestore
          .collection(CATEGORIES)
          .where(CATEGORY, isEqualTo: suggestion)
          .getDocuments()
          .then((snap) {
        print(suggestion);
        print(snap.documents.length);
        return snap.documents;
      });
}
