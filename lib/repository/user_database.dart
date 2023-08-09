import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum UserType { Admin, User, New }

class UserDatabase {
  static Firestore _firestore = Firestore.instance;
  static CollectionReference userDatabase = _firestore.collection('users');
  static DocumentReference usersRef =
      _firestore.collection('users').document('user');
  static DocumentReference adminRef =
      _firestore.collection('users').document('admin');
  static CollectionReference inventoryRef = _firestore.collection('inventory');
  Future<UserDatabaseState> checkIfAdmin({@required String phoneNumber}) async {
    try {
      QuerySnapshot adminData = await adminRef
          .collection('entries')
          .where(KeyNames['phone'], isEqualTo: phoneNumber)
          .getDocuments();
      var snapshot =
          adminData.documents.length > 0 ? adminData.documents[0] : null;
      if (snapshot != null) {
        return UserIsAdmin(user: snapshot.data);
      } else {
        return UserIsNotAdmin();
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUsername(
      {@required String phone, @required String username}) async {
    QuerySnapshot snapshot = await adminRef
        .collection('entries')
        .where(KeyNames['phone'], isEqualTo: phone)
        .getDocuments();
    if (snapshot.documents.length > 0) {
      var documentId = snapshot.documents[0].documentID;
      await adminRef
          .collection('entries')
          .document(documentId)
          .updateData({KeyNames['userName']: username});
    }
  }

  Future<dynamic> getUser({@required String phone}) async {
    QuerySnapshot snapshot = await adminRef
        .collection('entries')
        .where(KeyNames['phone'], isEqualTo: phone)
        .getDocuments();
    if (snapshot.documents.length > 0) {
      return snapshot.documents[0].data;
    }
  }

  Future<dynamic> addNewAdmin({@required Map userData}) async {
    try {
      QuerySnapshot snapshot = await adminRef
          .collection('entries')
          .where(KeyNames['phone'], isEqualTo: userData[KeyNames['phone']])
          .getDocuments();
      if (snapshot.documents.length == 0)
        await adminRef.collection('entries').add({...userData});
      else
        return 'ADMIN_ALREADY_ADDED';
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List> fetchAllAdmins() async {
    try {
      QuerySnapshot snapshot =
          await adminRef.collection('entries').getDocuments();
      return snapshot.documents;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> updatePrivilege(
      {@required String documentId, @required isSuperAdmin}) async {
    try {
      await adminRef
          .collection('entries')
          .document(documentId)
          .updateData({KeyNames['superAdmin']: isSuperAdmin});
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePoints(Map pointsDetails) async {
    await usersRef
        .collection('entries')
        .document(pointsDetails['userId'])
        .updateData({
      KeyNames['points']: FieldValue.increment(pointsDetails['points'])
    });
  }

  Future<bool> deleteAdmin({@required String documentId}) async {
    try {
      await adminRef.collection('entries').document(documentId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
