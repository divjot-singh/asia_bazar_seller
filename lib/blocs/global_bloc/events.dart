import 'package:flutter/material.dart';

abstract class GlobalEvents {}

class FetchSellerInfo extends GlobalEvents {
  Function callback;
  FetchSellerInfo({this.callback});
}

class UpdateSellerInfo extends GlobalEvents {
  Function callback;
  Map data;
  UpdateSellerInfo({this.callback, @required this.data});
}
