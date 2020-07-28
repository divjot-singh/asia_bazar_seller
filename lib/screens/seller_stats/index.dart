import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/circular_list.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FilterValues { today, thisWeek, thisMonth }

class SellerStats extends StatefulWidget {
  @override
  _SellerStatsState createState() => _SellerStatsState();
}

class _SellerStatsState extends State<SellerStats> {
  final DateTime now = DateTime.now().toLocal();
  FilterValues _filterValue = FilterValues.today;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  bool showOverlay = false;
  ThemeData theme;
  Map filterValues;
  @override
  void initState() {
    filterValues = {
      FilterValues.today: {
        'heading': L10n().getStr('stats.today'),
        'filterFunction': filterTodayOrders
      },
      FilterValues.thisMonth: {
        'heading': L10n().getStr('stats.thisMonth'),
        'filterFunction': (orders) => [...orders]
      },
      FilterValues.thisWeek: {
        'heading': L10n().getStr('stats.thisWeek'),
        'filterFunction': filterThisWeekOrders
      },
    };
    DateTime monthDate = DateTime(now.year, now.month, 1).toUtc();
    if (now.day == 1) {
      monthDate = DateTime(now.year, now.month - 1, 1).toUtc();
    }
    Timestamp monthTimestamp = Timestamp.fromDate(monthDate);

    BlocProvider.of<OrderDetailsBloc>(context)
        .add(FetchTimeBasedOrders(time: monthTimestamp));
    super.initState();
  }

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

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        body: BlocBuilder<OrderDetailsBloc, Map>(
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
              String heading = filterValues[_filterValue]['heading'];
              List filterOrders =
                  filterValues[_filterValue]['filterFunction'](orders);
              return Scaffold(
                appBar: MyAppBar(
                  backGroundColor: Colors.black.withOpacity(0.3),
                  hasTransparentBackground: !showOverlay,
                  title: heading,
                ),
                body: Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      backgroundColor: ColorShades.greenBg,
                      onRefresh: () => refreshPage(context),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: Spacing.space24, bottom: Spacing.space20),
                          padding:
                              EdgeInsets.symmetric(horizontal: Spacing.space16),
                          child: Center(
                            child: StatsBlock(
                              heading: heading,
                              orders: filterOrders,
                            ),
                          ),
                        ),
                      ),
                    ),
                    showOverlay
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black.withOpacity(0.3),
                          )
                        : Container()
                  ],
                ),
                floatingActionButton: Builder(
                  builder: (context) => FabCircularMenu(
                    key: fabKey,
                    // Cannot be `Alignment.center`
                    alignment: Alignment.bottomRight,
                    fabSize: 64.0,
                    ringColor: ColorShades.greenBg.withOpacity(0.7),
                    fabElevation: 8.0,
                    startAngle: -45,
                    range: 90,
                    fabColor: ColorShades.greenBg,
                    fabOpenColor: ColorShades.white,
                    fabOpenIcon:
                        Icon(Icons.filter_list, color: ColorShades.white),
                    fabCloseIcon: Icon(Icons.close, color: ColorShades.greenBg),

                    animationCurve: Curves.easeInOutCirc,
                    onDisplayChange: (isOpen) {
                      setState(() {
                        showOverlay = isOpen;
                      });
                    },
                    children: FilterValues.values.map((item) {
                      bool isSelected = item == _filterValue;

                      return InkWell(
                        onTap: () {
                          fabKey.currentState.close();
                          if (_filterValue != item) {
                            setState(() {
                              _filterValue = item;
                              showOverlay = false;
                            });
                          }
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: Spacing.space16,
                                horizontal: Spacing.space12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: isSelected
                                    ? ColorShades.greenBg
                                    : ColorShades.white,
                                border: Border.all(color: ColorShades.greenBg)),
                            child: Text(
                              L10n().getStr(filterValues[item]['heading']),
                              style: isSelected
                                  ? theme.textTheme.body1Bold
                                      .copyWith(color: ColorShades.white)
                                  : theme.textTheme.body1Regular
                                      .copyWith(color: ColorShades.greenBg),
                            )),
                      );
                    }).toList(),
                  ),
                ),
              );
            }

            return Container();
          },
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
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.spaceEvenly,
          children: <Widget>[
            StatCard(
              info: L10n().getStr('stats.totalAmount'),
              value: amount.toInt().toString(),
              valueColor: ColorShades.neon,
            ),
            StatCard(
              info: L10n().getStr('stats.ordersPlaced'),
              value: orders.length.toString(),
              valueColor: ColorShades.neon,
            ),
            StatCard(
              info: L10n().getStr('stats.ordersDelivered'),
              value: ordersDelivered.toString(),
              valueColor: ColorShades.greenBg,
            ),
            if (ordersRejected > 0)
              StatCard(
                info: L10n().getStr('stats.ordersRejected'),
                value: ordersRejected.toString(),
                valueColor: ColorShades.redOrange,
              ),
          ],
        ));
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

class StatCard extends StatelessWidget {
  final String info, value;
  final Color valueColor;
  StatCard(
      {@required this.value,
      @required this.info,
      this.valueColor = ColorShades.bastille});
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(minWidth: 150),
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space12),
      margin: EdgeInsets.only(right: Spacing.space16, bottom: Spacing.space16),
      decoration: BoxDecoration(
        color: ColorShades.white,
        boxShadow: [Shadows.cardLight],
        border: Border.all(color: ColorShades.grey200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        AutoSizeText(
          value,
          maxLines: 1,
          style: TextStyle(fontSize: 120, color: valueColor),
        ),
        Text(info,
            textWidthBasis: TextWidthBasis.parent,
            style: theme.textTheme.body1Medium
                .copyWith(color: ColorShades.bastille)),
      ]),
    );
  }
}
