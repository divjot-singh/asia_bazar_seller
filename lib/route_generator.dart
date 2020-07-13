import 'package:asia_bazar_seller/screens/add_address/index.dart';
import 'package:asia_bazar_seller/screens/address_list/index.dart';
import 'package:asia_bazar_seller/screens/all_search/index.dart';
import 'package:asia_bazar_seller/screens/authentication_screen/authentication_screen.dart';
import 'package:asia_bazar_seller/screens/cart/index.dart';
import 'package:asia_bazar_seller/screens/category_listing/index.dart';
import 'package:asia_bazar_seller/screens/checkout/index.dart';
import 'package:asia_bazar_seller/screens/home/index.dart';
import 'package:asia_bazar_seller/screens/onboarding/index.dart';
import 'package:asia_bazar_seller/screens/order_details/index.dart';
import 'package:asia_bazar_seller/screens/order_details/item_details.dart';
import 'package:asia_bazar_seller/screens/order_list/index.dart';
import 'package:asia_bazar_seller/screens/redirector/index.dart';
import 'package:asia_bazar_seller/screens/search_orders/index.dart';
import 'package:asia_bazar_seller/screens/update_profile/index.dart';
import 'package:asia_bazar_seller/screens/user_not_admin/not_admin.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';

class FluroRouter {
  static Router router = Router();
  static Handler getCommonHandler(String route) {
    switch (route) {
      case Constants.AUTHENTICATION_SCREEN:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return AuthenticationScreen();
          },
        );
      case Constants.HOME:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return HomeScreen();
          },
        );
      case Constants.EDIT_PROFILE:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return UpdateProfile();
          },
        );
      case Constants.USER_NOT_ADMIN:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return NotAdmin();
          },
        );
      // case Constants.SEARCH_ORDER:
      //   return Handler(
      //     handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      //       return SearchOrders();
      //     },
      //   );
      case Constants.SEARCH:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return SearchItems();
          },
        );
      case Constants.CART:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Cart();
          },
        );
      case Constants.ONBOARDING:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Onboarding();
          },
        );
      case Constants.ORDER_LIST:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return OrderList();
          },
        );
      case Constants.ORDER_DETAILS:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            var orderId = params['orderId'][0];
            return BlocProvider.value(
                value: BlocHolder().getClubDetailsBloc(orderId),
                child: OrderDetails(orderId: orderId));
          },
        );
      case Constants.ORDER_ITEM_DETAILS:
        return Handler(
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
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return CategoryListing(
              categoryId: params['categoryId'][0],
              categoryName: params['categoryName'][0],
            );
          },
        );
      case Constants.POST_AUTHENTICATION_REDIRECTOR:
        return Handler(
          handlerFunc: (BuildContext context, Map<String, dynamic> params) {
            return Redirector();
          },
        );
      default:
        return Handler(
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
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.EDIT_PROFILE,
      handler: getCommonHandler(Constants.EDIT_PROFILE),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.HOME,
      handler: getCommonHandler(Constants.HOME),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.USER_NOT_ADMIN,
      handler: getCommonHandler(Constants.USER_NOT_ADMIN),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.SEARCH,
      handler: getCommonHandler(Constants.SEARCH),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      Constants.CART,
      handler: getCommonHandler(Constants.CART),
      transitionType: TransitionType.inFromBottom,
    );
    // router.define(
    //   Constants.SEARCH_ORDER,
    //   handler: getCommonHandler(Constants.SEARCH_ORDER),
    //   transitionType: TransitionType.inFromBottom,
    // );

    router.define(
      Constants.POST_AUTHENTICATION_REDIRECTOR,
      handler: getCommonHandler(Constants.POST_AUTHENTICATION_REDIRECTOR),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.ADD_ADDRESS,
      handler: getCommonHandler(Constants.ADD_ADDRESS),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      Constants.ORDER_DETAILS,
      handler: getCommonHandler(Constants.ORDER_DETAILS),
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      Constants.CATEGORY_LISTING,
      handler: getCommonHandler(Constants.CATEGORY_LISTING),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      Constants.ONBOARDING,
      handler: getCommonHandler(Constants.ONBOARDING),
      transitionType: TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ORDER_ITEM_DETAILS,
      handler: getCommonHandler(Constants.ORDER_ITEM_DETAILS),
      transitionType: TransitionType.cupertinoFullScreenDialog,
    );
    router.define(
      Constants.ORDER_LIST,
      handler: getCommonHandler(Constants.ORDER_LIST),
      transitionType: TransitionType.inFromLeft,
    );
    router.define(
      '/',
      handler: getCommonHandler(Constants.AUTHENTICATION_SCREEN),
      transitionType: TransitionType.fadeIn,
    );
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    String routeName = settings.name;
    switch (routeName) {
      case Constants.ADDRESS_LIST:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return AddressList(
              selectView: arguments['selectView'] != null
                  ? arguments['selectView']
                  : false);
        });
      case Constants.CHECKOUT:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return Checkout(amount: arguments['amount']);
        });
      case Constants.ADD_ADDRESS:
        return MaterialPageRoute(builder: (_) {
          Map<String, dynamic> arguments =
              settings.arguments != null ? settings.arguments : {};
          return AddAddress(
            isEdit: arguments['isEdit'],
            first: arguments['first'],
            address: arguments['address'],
          );
        });

      default:
        return FluroRouter.router.generator(settings);
    }
  }
}
