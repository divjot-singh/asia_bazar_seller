import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ItemDatabase {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference categoryRef = _firestore.collection('categories');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  static CollectionReference orderRef = _firestore.collection('orders');
  static CollectionReference orderedItems = _firestore.collection('orderItems');
  Future<List> fetchAllCategories() async {
    QuerySnapshot snapshot = await categoryRef.get();
    return snapshot.docs;
  }

  Future<List> fetchOutofStockItems({@required String categoryId}) async {
    QuerySnapshot snapshot;
    try {
      snapshot = await inventoryRef
          .doc(categoryId)
          .collection('items')
          .where('quantity', isEqualTo: 0)
          .get();
      return snapshot.docs;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<dynamic> removeItem(
      {@required String categoryId, @required String itemId}) async {
    try {
      await inventoryRef
          .doc(categoryId)
          .collection('items')
          .doc(itemId)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List> fetchCategoryListing(
      {@required String categoryId, @required DocumentSnapshot startAt}) async {
    var limit = 50;
    QuerySnapshot snapshot;
    var returnValue;
    if (startAt == null) {
      snapshot = await inventoryRef
          .doc(categoryId)
          .collection('items')
          .orderBy('quantity')
          .where('quantity', isGreaterThanOrEqualTo: 1)
          .limit(limit)
          .get();
      returnValue = snapshot.docs;
    } else {
      snapshot = await inventoryRef
          .doc(categoryId)
          .collection('items')
          .orderBy('quantity')
          .where('quantity', isGreaterThanOrEqualTo: 1)
          .startAfterDocument(startAt)
          .limit(limit)
          .get();
      returnValue = snapshot.docs == null ? {} : snapshot.docs;
    }

    if (returnValue != null) return [...returnValue];
    return null;
  }

  Future<List> searchCategoryListing(
      {@required String categoryId,
      @required String startAt,
      String query}) async {
    QuerySnapshot snapshot;
    var limit = 50;
    var returnValue;
    if (query.length == 0) {
      snapshot = await inventoryRef
          .doc(categoryId)
          .collection('items')
          .orderBy('quantity')
          .limit(limit)
          .get();
      returnValue = snapshot.docs;
    } else {
      snapshot = await inventoryRef
          .doc(categoryId)
          .collection('items')
          .orderBy('quantity')
          .where('tokens', arrayContains: query)
          .limit(limit)
          .get();
      returnValue = snapshot.docs;
      returnValue = snapshot.docs == null ? {} : snapshot.docs;
    }

    if (returnValue != null) return [...returnValue];
    return null;
  }

  Future<List> searchAllListing(
      {DocumentSnapshot startAt, String query}) async {
    QuerySnapshot snapshot;
    var limit = 50;
    var returnValue;
    if (query.length > 0) {
      if (startAt != null) {
        snapshot = await _firestore
            .collectionGroup('items')
            .orderBy('item_id')
            .where('tokens', arrayContains: query)
            .limit(limit)
            .startAfterDocument(startAt)
            .get();
      } else {
        snapshot = await _firestore
            .collectionGroup('items')
            .orderBy('item_id')
            .where('tokens', arrayContains: query)
            .limit(limit)
            .get();
      }
      returnValue = snapshot.docs;
      returnValue = snapshot.docs == null ? {} : snapshot.docs;
      if (returnValue != null) return [...returnValue];
      return null;
    }
    return [];
  }

  Future<dynamic> placeOrder(
      {@required Map details,
      @required String userId,
      @required Function callback}) async {
    var returnItem = {};
    //var transactionWriteArray = [];
    try {
      var cart = details['cart'];
      //var lastKey = cart.keys.toList()[cart.length - 1];
      WriteBatch batchWrite = _firestore.batch();
      //var successful = true;
      cart.forEach((key, item) async {
        var decrementValue = item['cartQuantity'];
        decrementValue *= -1;
        var ref = inventoryRef
            .doc(item['category_id'])
            .collection('items')
            .doc(key);
        try {
          print('wiriting' + ref.path.toString());
          batchWrite.update(
              ref, {'quantity': FieldValue.increment(decrementValue)});
        } catch (e) {
          print('update error');
          print(e);
        }
      });

      batchWrite.commit().then((value) async {
        var itemsOrdered = details['cart'].keys.toList();
        Map cart = {...details['cart']};
        details.remove('cart');
        details['cartItems'] = itemsOrdered;
        var orderId = details['orderId'];
        details['timestamp'] = Timestamp.fromDate(DateTime.now().toUtc());
        DocumentReference ref = await orderRef.add(details);
        cart.forEach((key, item) async {
          await orderedItems.add({
            'itemDetails': item,
            'orderId': orderId,
            'orderRef': ref.id
          });
        });

        callback(true);
        return;
      }, onError: (error) {
        print(error.toString());
        print('error in try catch');
        callback(returnItem);
        return;
      });
    } catch (e) {
      //error in try catch block
      print(e.toString());
      print('error in try catch 2');
      callback(false);
      return;
    }
  }

  Future<Map> fetchCartItems({@required Map cartKeys}) async {
    Map items = {};
    try {
      for (var i = 0; i < cartKeys.length; i++) {
        var key = cartKeys.keys.toList()[i];
        var value = cartKeys[key];
        var snapshot = await inventoryRef
            .doc(value['category_id'])
            .collection('items')
            .doc(value['item_id'])
            .get();
        items[key] = snapshot.data;
      }
      return items;
    } catch (e) {
      return null;
    }
  }

  Future<List> fetchMyOrders(
      {@required String userId, DocumentSnapshot startAt}) async {
    try {
      var limit = 50;
      QuerySnapshot snapshot;
      var returnValue;
      if (startAt == null) {
        snapshot = await orderRef
            .orderBy('timestamp', descending: true)
            .where('userId', isEqualTo: userId)
            .limit(limit)
            .get();
        returnValue = snapshot.docs;
      } else {
        snapshot = await orderRef
            .orderBy('timestamp', descending: true)
            .where('userId', isEqualTo: userId)
            .startAfterDocument(startAt)
            .limit(limit)
            .get();
        returnValue = snapshot.docs == null ? {} : snapshot.docs;
      }

      if (returnValue != null) return [...returnValue];
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
