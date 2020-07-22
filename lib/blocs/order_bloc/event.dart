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
  UpdateOrderStatus({@required this.orderId, @required this.newStatus, this.callback, this.itemList});
}