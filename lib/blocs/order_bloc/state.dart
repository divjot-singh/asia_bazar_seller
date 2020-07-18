import 'package:flutter/foundation.dart';

abstract class OrderState {
  static Map orderState = {
    'ordersListState': UninitialisedState(),
  };
}

class UninitialisedState extends OrderState {}

class OrderFetchedState extends OrderState {
  dynamic orderDetails;
  dynamic documentId;
  OrderFetchedState({@required this.orderDetails, @required this.documentId});
}

class ItemFetchedState extends OrderState {
  List orderItems;
  String orderId;
  ItemFetchedState({@required this.orderId, @required this.orderItems});
}
