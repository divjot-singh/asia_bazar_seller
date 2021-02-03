import 'package:asia_bazar_seller/blocs/order_bloc/bloc.dart';
import 'package:asia_bazar_seller/screens/add_admin/index.dart';
import 'package:asia_bazar_seller/screens/authentication_screen/authentication_screen.dart';
import 'package:asia_bazar_seller/screens/category_listing/index.dart';

import 'package:asia_bazar_seller/screens/home/index.dart';
import 'package:asia_bazar_seller/screens/inventory/index.dart';
import 'package:asia_bazar_seller/screens/manage_admins/index.dart';
import 'package:asia_bazar_seller/screens/order_details/index.dart';
import 'package:asia_bazar_seller/screens/order_details/item_details.dart';
import 'package:asia_bazar_seller/screens/redirector/index.dart';
import 'package:asia_bazar_seller/screens/seller_stats/index.dart';
import 'package:asia_bazar_seller/screens/update_info/index.dart';
import 'package:asia_bazar_seller/screens/update_profile/index.dart';
import 'package:asia_bazar_seller/screens/user_not_admin/not_admin.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart' as Fluro;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';

class FluroRouter {
  static Fluro.Router router = Fluro.Router();
  static Fluro.Handler getCommonHandler(String route) {
    switch (route) {
      case Constants.AUTHENTICATION_SCREEN:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );
      case Constants.HOME:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return HomeScreen();
          },
        );
      case Constants.EDIT_PROFILE:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return UpdateProfile();
          },
        );

      case Constants.ORDER_STATS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return BlocProvider.value(
                value: OrderDetailsBloc(), child: SellerStats());
          },
        );
      case Constants.USER_NOT_ADMIN:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return NotAdmin();
          },
        );
      case Constants.INVENTORY:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Inventory();
          },
        );
      case Constants.ADD_ADMIN:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AddAdmin();
          },
        );

      case Constants.MANAGE_ADMINS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return ManageAdmins();
          },
        );
      case Constants.UPDATE_INFO:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return UpdateInfo();
          },
        );

      case Constants.ORDER_DETAILS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            var orderId = params['orderId'][0];
            return BlocProvider.value(
                value: BlocHolder().getClubDetailsBloc(orderId),
                child: OrderDetails(orderId: orderId));
          },
        );
      case Constants.ORDER_ITEM_DETAILS:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            var orderId = params['orderId'][0];
            var editView = params['editView'][0] == "true";
            return BlocProvider.value(
                value: BlocHolder().getClubDetailsBloc(orderId),
                child: OrderItemDetails(
                  orderId: orderId,
                  editView: editView,
                ));
          },
        );
      case Constants.CATEGORY_LISTING:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return CategoryListing(
              categoryId: params['categoryId'][0],
              categoryName: params['categoryName'][0],
            );
          },
        );
      case Constants.POST_AUTHENTICATION_REDIRECTOR:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Redirector();
          },
        );
      default:
        return Fluro.Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );
    }
  }

  static void setupRouter() {
    router.define(
      Constants.AUTHENTICATION_SCREEN,
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.EDIT_PROFILE,
      handler: getCommonHandler(Constants.EDIT_PROFILE),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.HOME,
      handler: getCommonHandler(Constants.HOME),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.CATEGORY_LISTING,
      handler: getCommonHandler(Constants.CATEGORY_LISTING),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.INVENTORY,
      handler: getCommonHandler(Constants.INVENTORY),
      transitionType: Fluro.TransitionType.fadeIn,
    );

    router.define(
      Constants.USER_NOT_ADMIN,
      handler: getCommonHandler(Constants.USER_NOT_ADMIN),
      transitionType: Fluro.TransitionType.fadeIn,
    );
    router.define(
      Constants.ORDER_STATS,
      handler: getCommonHandler(Constants.ORDER_STATS),
      transitionType: Fluro.TransitionType.fadeIn,
    );

    router.define(
      Constants.POST_AUTHENTICATION_REDIRECTOR,
      handler: getCommonHandler(Constants.POST_AUTHENTICATION_REDIRECTOR),
      transitionType: Fluro.TransitionType.fadeIn,
    );

    router.define(
      Constants.ORDER_DETAILS,
      handler: getCommonHandler(Constants.ORDER_DETAILS),
      transitionType: Fluro.TransitionType.inFromBottom,
    );
    router.define(
      Constants.MANAGE_ADMINS,
      handler: getCommonHandler(Constants.MANAGE_ADMINS),
      transitionType: Fluro.TransitionType.inFromBottom,
    );

    router.define(
      Constants.ORDER_ITEM_DETAILS,
      handler: getCommonHandler(Constants.ORDER_ITEM_DETAILS),
      transitionType: Fluro.TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ADD_ADMIN,
      handler: getCommonHandler(Constants.ADD_ADMIN),
      transitionType: Fluro.TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.UPDATE_INFO,
      handler: getCommonHandler(Constants.UPDATE_INFO),
      transitionType: Fluro.TransitionType.cupertinoFullScreenDialog,
    );

    router.define(
      '/',
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: Fluro.TransitionType.fadeIn,
    );
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    String routeName = settings.name;
    switch (routeName) {
      default:
        return FluroRouter.router.generator(settings);
    }
  }
}
