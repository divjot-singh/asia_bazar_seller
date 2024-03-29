import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class OrderEvent {}

class FetchOrderDetails extends OrderEvent {
  String orderId;
  bool addListener;
  FetchOrderDetails({@required this.orderId});
}

class FetchOrderItems extends OrderEvent {
  String orderId;
  Function callback;

  FetchOrderItems({@required this.orderId, this.callback});
}

class UpdateOrderStatus extends OrderEvent {
  String orderId, newStatus;
  Function callback;
  List itemList;
  Map pointsDetails;
  UpdateOrderStatus(
      {@required this.orderId,
      @required this.newStatus,
      this.callback,
      this.itemList,
      this.pointsDetails});
}

class FetchTimeBasedOrders extends OrderEvent {
  Timestamp time;
  FetchTimeBasedOrders({@required this.time});
}
