import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalRepo {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference sellerRef = _firestore.collection('sellerInfo');
  var sellerDocumentId;
  Future<Map> fetchSellerInfo() async {
    try {
      QuerySnapshot doc = await sellerRef.getDocuments();
      sellerDocumentId = doc.documents[0].documentID;
      return doc.documents[0].data;
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
      await sellerRef.document(sellerDocumentId).updateData(data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
