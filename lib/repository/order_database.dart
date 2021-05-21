import 'package:asia_bazar_seller/repository/payment_repo.dart';
import 'package:asia_bazar_seller/repository/user_database.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDatabaseRepo {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference orderedItems = _firestore.collection('orderItems');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  static UserDatabase userDatabase = UserDatabase();
  Future<dynamic> fetchOrderDetails({@required String orderId}) async {
    var returnValue;
    try {
      QuerySnapshot snapshot =
          await orderRef.where('orderId', isEqualTo: orderId).limit(1).get();
      DocumentSnapshot order = snapshot.docs.length > 0 ? snapshot.docs[0] : {};
      returnValue = order;

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
      snapshot = await query.limit(limit).get();

      return snapshot.docs;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> fetchOrderItems({@required String orderId}) async {
    try {
      QuerySnapshot snapshot =
          await orderedItems.where('orderId', isEqualTo: orderId).get();
      List items = await fetchItemsFromOrder(snapshot: snapshot);
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStatus(
      {@required String orderId,
      @required String newStatus,
      List itemList,
      Map pointsDetails}) async {
    try {
      if (newStatus == KeyNames['orderDelivered']) {
        await orderRef.doc(orderId).update(
            {'status': newStatus, 'deliveryTimestamp': Timestamp.now()});
        if (pointsDetails != null)
          await userDatabase.updatePoints(pointsDetails);
      } else
        await orderRef.doc(orderId).update({'status': newStatus});
      if (newStatus == KeyNames['orderRejected']) {
        restoreItemsInInventory(itemList);
        refundUser(orderId);
      }
      return;
    } catch (e) {
      print(e);
    }
  }

  Future<void> refundUser(String orderId) async {
    var orderSnapshot = await fetchOrderDetails(orderId: orderId);
    if (orderSnapshot.data != null) {
      var orderData = orderSnapshot.data,
          transactionId = orderData['transactionId'],
          orderId = orderData['orderId'],
          userId = orderData['userId'];
      if (transactionId != null) {
        var response = await PaymentRepository.voidTransaction(
            transactionId: transactionId);

        Map<String, String> refundData = {
          'orderId': orderId,
          'userId': userId,
          'status': (response['success'] == true).toString()
        };
        orderRef
            .doc(orderId)
            .update({'refundStatus': response['success'] == true});
        var notificationResponse =
            await PaymentRepository.sendRefundStatusNotification(
                refundData: refundData);
        print(notificationResponse);
      }
    }
  }

  Future<void> restoreItemsInInventory(List itemList) async {
    try {
      itemList.forEach((item) async {
        await inventoryRef
            .doc(item['category_id'])
            .collection('items')
            .doc(item['itemId'])
            .update({
          'quantity': FieldValue.increment(item['quantity'] is String
              ? int.parse(item['quantity'])
              : item['quantity'])
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List> fetchDateBasedOrders({@required Timestamp time}) async {
    try {
      QuerySnapshot items = await orderRef
          .orderBy('timestamp')
          .where('timestamp', isGreaterThanOrEqualTo: time)
          .get();

      return items.docs;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List> fetchItemsFromOrder({@required QuerySnapshot snapshot}) async {
    List<Map<String, dynamic>> items = [];
    for (var document in snapshot.docs) {
      Map itemData = document.data();
      var itemdoc = itemData['itemDetails'];
      DocumentSnapshot itemSnapshot = await inventoryRef
          .doc(itemdoc['category_id'].toString())
          .collection('items')
          .doc(itemdoc['item_id'].toString())
          .get();
      items.add({'orderData': document, 'itemData': itemSnapshot});
    }
    return items;
  }
}
