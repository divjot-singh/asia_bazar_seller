import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia_bazar_seller/theme/style.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  ThemeData theme;
  var cart;
  double grandTotal = 0;
  double totalCost = 0;
  double packagingCharges = 0;
  double otherCharges = 0;
  double deliveryCharges = 0;
  @override
  void initState() {
    BlocProvider.of<UserDatabaseBloc>(context)
        .add(FetchCartItems(callback: fetchItemsCallback));
    BlocProvider.of<GlobalBloc>(context)
        .add(FetchSellerInfo(callback: fetchSellerCallback));
    super.initState();
  }

  fetchSellerCallback(info) {
    if (info is Map) {
  
      setState(() {
        deliveryCharges = info['deliveryCharges'].toDouble();
        packagingCharges = info['packagingCharges'].toDouble();
        otherCharges = info['packagingCharges'].toDouble();
      });
    }
  }

  fetchItemsCallback(items) {
    if (items is Map && items.length > 0) {
      setState(() {
        cart = items;
      });
    }
  }

  Widget emptyState() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/empty_cart.png'),
          SizedBox(
            height: Spacing.space20,
          ),
          Text(
            L10n().getStr('cart.empty'),
            textAlign: TextAlign.center,
            style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
          ),
        ],
      ),
    );
  }

  void removeItemHandler(item) {
    setState(() {
      cart.remove(item['opc'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: BlocBuilder<UserDatabaseBloc, Map>(
        builder: (context, currentState) {
          var userState = currentState['userstate'];
          if (userState is GlobalFetchingState) {
            return Container(
                color: ColorShades.white, child: PageFetchingViewWithLightBg());
          } else if (userState is GlobalErrorState) {
            return PageErrorView();
          }
          return Container();
        },
      ),
    );
  }
}
