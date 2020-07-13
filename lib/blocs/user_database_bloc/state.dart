import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:flutter/material.dart';

abstract class UserDatabaseState {
  static Map userstate = {
    'userstate': GlobalUninitialisedState,
    'ordersstate': GlobalUninitialisedState
  };
}

class UserIsAdmin extends UserDatabaseState {
  var user;
  UserIsAdmin({@required this.user});
}

class UserIsNotAdmin extends UserDatabaseState {}
