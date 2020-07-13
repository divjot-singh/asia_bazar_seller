import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  ThemeData theme;
  bool isFetching = false, showScrollUp = false;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    _scrollController.addListener(scrollListener);
    BlocProvider.of<UserDatabaseBloc>(context).add(FetchMyOrders());
    super.initState();
  }

  scrollListener() {
    setState(() {
      showScrollUp = _scrollController.position.pixels >
          MediaQuery.of(context).size.height;
    });

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true) {
      _fetchMoreItems();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  _fetchMoreItems() {
  
  }

  Future<void> reloadPage() async {
    var route = Constants.ORDER_LIST;
    Navigator.popAndPushNamed(context, route);
  }

  Widget emptyState() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/no_orders.png'),
          SizedBox(
            height: Spacing.space20,
          ),
          Text(
            L10n().getStr('myOrders.noOrders'),
            textAlign: TextAlign.center,
            style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
          ),
        ],
      ),
    );
  }

  Widget orderCard(DocumentSnapshot order) {
    var statusColor;
    if (order['status'] == KeyNames['orderPlaced']) {
      statusColor = ColorShades.pacificBlue;
    }
    if (order['status'] == KeyNames['orderApproved']) {
      statusColor = ColorShades.greenBg;
    }
    if (order['status'] == KeyNames['orderDispatched'] ||
        order['status'] == KeyNames['orderReturnRequested']) {
      statusColor = ColorShades.darkOrange;
    }
    if (order['status'] == KeyNames['orderDelivered'] ||
        order['status'] == KeyNames['orderReturnApproved']) {
      statusColor = ColorShades.elfGreen;
    }
    if (order['status'] == KeyNames['orderRejected'] ||
        order['status'] == KeyNames['orderCancelled'] ||
        order['status'] == KeyNames['orderReturnRejected']) {
      statusColor = ColorShades.redOrange;
    }
    Timestamp time = order['timestamp'];
    if (order['status'] == KeyNames['orderDelivered'] &&
        order['deliveredTimestamp'] != null) {
      time = order['deliveredTimestamp'];
    }

    String timeString =
        DateFormatter.formatWithTime(time.millisecondsSinceEpoch.toString());

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context,
            Constants.ORDER_DETAILS.replaceAll(':orderId', order['orderId']));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Spacing.space16, vertical: Spacing.space4),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: Spacing.space16, vertical: Spacing.space12),
          margin: EdgeInsets.only(bottom: Spacing.space16),
          decoration: BoxDecoration(
            boxShadow: [Shadows.cardLight],
            color: ColorShades.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    L10n().getStr('order.orderId'),
                    style: theme.textTheme.h4
                        .copyWith(color: ColorShades.bastille),
                  ),
                  Text(
                    L10n().getStr('order.amount') + ': \$ ${order['amount']}',
                    style: theme.textTheme.body1Regular
                        .copyWith(color: ColorShades.redOrange),
                  ),
                ],
              ),
              SizedBox(
                height: Spacing.space4,
              ),
              Text(
                order['orderId'],
                style: theme.textTheme.body1Regular
                    .copyWith(color: ColorShades.bastille),
              ),
              SizedBox(
                height: Spacing.space12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.location_on, color: ColorShades.greenBg),
                  SizedBox(
                    width: Spacing.space8,
                  ),
                  Expanded(
                    child: Text(
                      order['address']['address_text'],
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: Spacing.space12,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          color: statusColor,
                          size: 20,
                        ),
                        SizedBox(width: Spacing.space4),
                        Text(
                          L10n().getStr('order.' + order['status']),
                          style:
                              theme.textTheme.h4.copyWith(color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.access_time, color: ColorShades.greenBg),
                        SizedBox(
                          width: Spacing.space8,
                        ),
                        Text(timeString,
                            style: theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.greenBg))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('myOrders.heading'),
        ),
        body: BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, currentState) {
            var state = currentState['ordersstate'];
            if (state is GlobalFetchingState) {
              return PageFetchingViewWithLightBg();
            } else if (state is GlobalErrorState) {
              return PageErrorView();
            } 
            return Container();
          },
        ),
      ),
    );
  }
}
