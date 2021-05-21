import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRepo {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference sellerRef = _firestore.collection('sellerInfo');
  var sellerDocumentId;
  Future<Map> fetchSellerInfo() async {
    try {
      QuerySnapshot doc = await sellerRef.get();
      sellerDocumentId = doc.docs[0].id;
      return doc.docs[0].data();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updateSellerInfo({Map data}) async {
    try {
      if (sellerDocumentId == null) {
        await fetchSellerInfo();
      }
      await sellerRef.doc(sellerDocumentId).update(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
