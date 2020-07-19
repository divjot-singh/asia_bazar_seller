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
  AddNewAdmin(
      {@required this.username,
      @required this.phoneNumber,
      @required this.isSuperAdmin,
      this.callback});
}

class FetchAllAdmins extends UserDatabaseEvents {}

class DeleteAdmin extends UserDatabaseEvents {
  String documentId;
  Function callback;
  DeleteAdmin({@required this.documentId, this.callback});
}

class UpdatePrivilege extends UserDatabaseEvents {
  String documentId;
  bool isSuperAdmin;
  Function callback;
  UpdatePrivilege({@required this.documentId, this.isSuperAdmin = false, this.callback});
}
