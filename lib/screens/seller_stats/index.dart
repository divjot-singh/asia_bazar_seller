import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerStats extends StatelessWidget {
  final DateTime now = DateTime.now().toLocal();
  ThemeData theme;
  List filterTodayOrders(List orders) {
    Timestamp today =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day).toLocal());
    var currentOrders = [...orders];
    currentOrders.retainWhere((order) =>
        order.data['timestamp'].millisecondsSinceEpoch >=
        today.millisecondsSinceEpoch);
    return currentOrders;
  }

  List filterThisWeekOrders(List orders) {
    DateTime today = DateTime(now.year, now.month, now.day).toLocal();
    int diff = (7 + (today.weekday - DateTime.monday)) % 7;
    DateTime startOfWeek = today.add(Duration(days: -1 * diff)).toLocal();
    Timestamp startOfWeekTimeStamp = Timestamp.fromDate(startOfWeek);
    var currentOrders = [...orders];
    currentOrders.retainWhere((order) =>
        order.data['timestamp'].millisecondsSinceEpoch >=
        startOfWeekTimeStamp.millisecondsSinceEpoch);
    return currentOrders;
  }

  Future<void> refreshPage(context) async {
    Navigator.pushReplacementNamed(context, Constants.ORDER_STATS);
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    DateTime monthDate = DateTime(now.year, now.month, 1).toUtc();
    if (now.day == 1) {
      monthDate = DateTime(now.year, now.month - 1, 1).toUtc();
    }
    Timestamp monthTimestamp = Timestamp.fromDate(monthDate);

    BlocProvider.of<OrderDetailsBloc>(context)
        .add(FetchTimeBasedOrders(time: monthTimestamp));
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          title: L10n().getStr('stats.heading'),
          hasTransparentBackground: true,
        ),
        body: RefreshIndicator(
          backgroundColor: ColorShades.greenBg,
          onRefresh: () => refreshPage(context),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: BlocBuilder<OrderDetailsBloc, Map>(
              builder: (context, state) {
                var currentState = state['orderStatsState'];
                if (currentState is GlobalFetchingState) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [PageFetchingViewWithLightBg()],
                    ),
                  );
                } else if (currentState is GlobalErrorState) {
                  return PageErrorView();
                } else if (currentState is OrdersFetchedState) {
                  List orders = currentState.orders;
                  if (orders.length == 0) {
                    return EmptyState();
                  }
                  List todayOrders = filterTodayOrders(orders);
                  List thisWeekOrders = filterThisWeekOrders(orders);
                  return Container(
                    margin: EdgeInsets.only(
                        top: Spacing.space24, bottom: Spacing.space20),
                    padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StatsBlock(
                          heading: L10n().getStr(
                            'stats.today',
                          ),
                          orders: todayOrders,
                        ),
                        SizedBox(height: Spacing.space20),
                        StatsBlock(
                          heading: L10n().getStr(
                            'stats.thisWeek',
                          ),
                          orders: thisWeekOrders,
                        ),
                        SizedBox(height: Spacing.space20),
                        StatsBlock(
                          heading: L10n().getStr(
                            'stats.thisMonth',
                          ),
                          orders: orders,
                        ),
                      ],
                    ),
                  );
                }

                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class StatsBlock extends StatelessWidget {
  final List orders;
  final String heading;
  StatsBlock({@required this.orders, @required this.heading});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    int ordersDelivered = orders.fold(
        0,
        (value, order) =>
            order['status'] == KeyNames['orderDelivered'] ? value += 1 : value);
    int ordersRejected = orders.fold(
        0,
        (value, order) =>
            order['status'] == KeyNames['orderRejected'] ? value += 1 : value);
    double amount =
        orders.fold(0, (value, order) => order['amount'].toDouble() + value);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space20, vertical: Spacing.space16),
      decoration: BoxDecoration(
          color: ColorShades.white,
          border: Border.all(color: ColorShades.greenBg),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [Shadows.cardLight]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            heading,
            style: theme.textTheme.h2.copyWith(color: ColorShades.greenBg),
          ),
          SizedBox(height: Spacing.space12),
          Container(
            padding: EdgeInsets.only(left: Spacing.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: L10n().getStr('stats.ordersPlaced') + ": ",
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.bastille),
                    children: [
                      TextSpan(
                        text: orders.length.toString(),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.neon),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                RichText(
                  text: TextSpan(
                    text: L10n().getStr('stats.ordersDelivered') + ": ",
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.bastille),
                    children: [
                      TextSpan(
                        text: ordersDelivered.toString(),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                if (ordersRejected > 0)
                  RichText(
                    text: TextSpan(
                      text: L10n().getStr('stats.ordersRejected') + ": ",
                      style: theme.textTheme.h3
                          .copyWith(color: ColorShades.bastille),
                      children: [
                        TextSpan(
                          text: ordersRejected.toString(),
                          style: theme.textTheme.h4
                              .copyWith(color: ColorShades.redOrange),
                        )
                      ],
                    ),
                  ),
                if (ordersRejected > 0)
                  SizedBox(
                    height: Spacing.space12,
                  ),
                RichText(
                  text: TextSpan(
                    text: L10n().getStr('stats.totalAmount') + ": ",
                    style: theme.textTheme.h3
                        .copyWith(color: ColorShades.bastille),
                    children: [
                      TextSpan(
                        text: '\$ ' + amount.toStringAsFixed(2).toString(),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.neon),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/no_orders.png'),
            Text(
              L10n().getStr(
                'home.noOrders',
              ),
              style: Theme.of(context)
                  .textTheme
                  .h4
                  .copyWith(color: ColorShades.greenBg),
            )
          ],
        ),
      ),
    );
  }
}
