//add all the imports here

import 'dart:io';

import 'package:asia_bazar_seller/blocs/auth_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/index.dart';
import 'package:asia_bazar_seller/route_generator.dart';
import 'package:asia_bazar_seller/shared_widgets/firebase_notification_configuration.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  // enable network traffic logging
  HttpClient.enableTimelineLogging = true;
  WidgetsFlutterBinding.ensureInitialized();
  //Crashlytics.instance.enableInDevMode = true;
  //FlutterError.onError = recordFlutterError;
  Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
  FluroRouter.setupRouter();
  //runZoned(
  //() => {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => BlocHolder().authBloc(),
        ),
        BlocProvider<UserDatabaseBloc>(
          create: (BuildContext context) => BlocHolder().userDbBloc(),
        ),
        BlocProvider<ItemDatabaseBloc>(
          create: (BuildContext context) => BlocHolder().itemDbBloc(),
        ),
        BlocProvider<GlobalBloc>(
          create: (BuildContext context) => BlocHolder().globalBloc(),
        ),
      ],
      child: FutureBuilder(
        future: firebaseApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return PageErrorView();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return App();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return PageFetchingView();
        },
      ),
    ),
  );
  //};
  //onError: recordDartError,
  //);
}

class BlocHolder {
  AuthBloc _authBloc;
  UserDatabaseBloc _userDbBloc;
  ItemDatabaseBloc _itemDbBloc;
  GlobalBloc _globalBloc;
  BlocHolder._internal();
  static final BlocHolder _inst = BlocHolder._internal();

  factory BlocHolder() {
    return _inst;
  }
  AuthBloc authBloc() {
    if (_inst._authBloc == null) _inst._authBloc = AuthBloc();
    return _inst._authBloc;
  }

  UserDatabaseBloc userDbBloc() {
    if (_inst._userDbBloc == null) _inst._userDbBloc = UserDatabaseBloc();
    return _inst._userDbBloc;
  }

  ItemDatabaseBloc itemDbBloc() {
    if (_inst._itemDbBloc == null) _inst._itemDbBloc = ItemDatabaseBloc();
    return _inst._itemDbBloc;
  }

  GlobalBloc globalBloc() {
    if (_inst._globalBloc == null) _inst._globalBloc = GlobalBloc();
    return _inst._globalBloc;
  }

  Map<String, OrderDetailsBloc> _orderDetailsBloc = {};
  OrderDetailsBloc getClubDetailsBloc(String orderId) {
    OrderDetailsBloc bloc = _orderDetailsBloc[orderId] ?? OrderDetailsBloc();
    _orderDetailsBloc[orderId] = bloc;
    return bloc;
  }
}
