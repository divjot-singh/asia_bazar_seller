import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDatabaseRepo {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference orderedItems = _firestore.collection('orderItems');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  Future<dynamic> fetchOrderDetails(
      {@required String orderId,
      @required String userId,
      bool addListener = true}) async {
    var returnValue;
    try {
      QuerySnapshot snapshot = await orderRef
          .where('orderId', isEqualTo: orderId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .getDocuments();
      DocumentSnapshot order =
          snapshot.documents.length > 0 ? snapshot.documents[0] : {};
      returnValue = order.data;
      if (addListener) {
        Stream<DocumentSnapshot> snapshotStream =
            orderRef.document(order.documentID).snapshots();
        returnValue = snapshotStream;
      }
      return returnValue;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchOrders(
      {String filter, DocumentSnapshot startAt, String searchQuery}) async {
    try {
      QuerySnapshot snapshot;
      Query query;
      int limit = 20;
      if (searchQuery != null && searchQuery.length > 0) {
        limit = 50;
        query = orderRef.orderBy('phoneNumber').startAt([searchQuery]).endAt(
            [searchQuery + '\uf8ff']).orderBy('timestamp', descending: true);
      } else {
        query = orderRef.orderBy('timestamp', descending: true);
      }
      if (filter != null && filter != 'all' && filter.length > 0) {
        query = query.where('status', isEqualTo: filter);
      }
      if (startAt != null && (searchQuery == null || searchQuery.length == 0)) {
        query = query.startAfterDocument(startAt);
      }
      snapshot = await query.limit(limit).getDocuments();
      return snapshot.documents;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> fetchOrderItems({@required String orderId}) async {
    try {
      QuerySnapshot snapshot = await orderedItems
          .where('orderId', isEqualTo: orderId)
          .getDocuments();
      List items = await fetchItemsFromOrder(snapshot: snapshot);
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchItemsFromOrder({@required QuerySnapshot snapshot}) async {
    List<Map<String, dynamic>> items = [];
    for (var document in snapshot.documents) {
      var itemdoc = document.data['itemDetails'];
      DocumentSnapshot itemSnapshot = await inventoryRef
          .document(itemdoc['categoryId'].toString())
          .collection('items')
          .document(itemdoc['opc'].toString())
          .get();
      items.add({'orderData': document, 'itemData': itemSnapshot});
    }
    return items;
  }
}
