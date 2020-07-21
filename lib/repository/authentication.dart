import 'dart:convert';
import 'dart:io';

import 'package:asia_bazar_seller/models/user.dart';
import 'package:asia_bazar_seller/services/log_printer.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/local_notifications.dart';
import 'package:asia_bazar_seller/utils/navigator_service.dart';
import 'package:asia_bazar_seller/utils/storage_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum AuthCallbackType { completed, failed, codeSent, timeout }

class AuthRepo {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseMessaging _fcm = FirebaseMessaging();
  static final logger = getLogger('AuthRepo');
  static List<String> serverNotificationIds = [];
  int notificationId = 0;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static List<String> onClickServerNotificationIds = [];
  var _verificationId = '';
  var _authCredential;
  void verifyPhoneNumber(
      {@required String phoneNumber, @required Function callback}) {
    _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 30),
        verificationCompleted: ((AuthCredential authCredential) async {
          await _verificationComplete(authCredential);
          callback(AuthCallbackType.completed, authCredential);
        }),
        verificationFailed: (AuthException authException) {
          callback(AuthCallbackType.failed, authException);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          _verificationId = verificationId;
          callback(AuthCallbackType.codeSent);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          callback(AuthCallbackType.timeout);
        });
  }

  Future<User> _verificationComplete(AuthCredential authCredential) async {
    _authCredential = authCredential;
    var authResult = await _auth.signInWithCredential(authCredential);
    logger.i(authResult);
    return await setupUserData(authResult.user);
  }

  Future<User> checkIfUserLoggedIn() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      return null;
    } else {
      User user = await setupUserData(firebaseUser);
      return user;
    }
  }

  Future<User> setupUserData(FirebaseUser firebaseUser) async {
    var user;
    try {
      IdTokenResult tokenResult = await firebaseUser.getIdToken(refresh: true);
      user = User(
          userId: firebaseUser.uid,
          userName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
          cart: null,
          firebaseToken: tokenResult.token);
    } catch (error) {
      user = User(
        userId: firebaseUser.uid,
        userName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        cart: null,
      );
    } finally {
      setUpFcm(userId: firebaseUser.uid);
      await StorageManager.setItem(KeyNames["userId"], user.userId);
      await StorageManager.setItem(KeyNames["userName"], user.userName);
      await StorageManager.setItem(KeyNames["phone"], user.phoneNumber);
      await StorageManager.setItem(KeyNames["token"], user.firebaseToken);
    }
    return user;
  }

  



  Future<void> setUpFcm({@required String userId}) async {
    var firebaseToken = await _fcm.getToken();

    if (firebaseToken != null) {
      await Firestore.instance
          .collection('adminTokens')
          .document(userId)
          .setData({
        'user_id': userId,
        'token': firebaseToken,
        'platform':
            Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'web'
      });
      await StorageManager.setItem(KeyNames['fcmToken'], firebaseToken);
    }
  }

  
  Future<User> signInWithSmsCode(String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.getCredential(
      smsCode: smsCode,
      verificationId: _verificationId,
    );
    return await _verificationComplete(authCredential);
  }

  Future<void> signout() async {
    await _auth.signOut();
  }
}
