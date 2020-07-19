import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class UserDatabaseEvents {}

class CheckIfAdmin extends UserDatabaseEvents {}

class UpdateUsername extends UserDatabaseEvents {
  String username;
  Function callback;
  UpdateUsername({@required this.username, this.callback});
}

class AddNewAdmin extends UserDatabaseEvents {
  String username, phoneNumber;
  bool isSuperAdmin;
  Function callback;
  AddNewAdmin({@required this.username, @required this.phoneNumber, @required this.isSuperAdmin, this.callback});
}