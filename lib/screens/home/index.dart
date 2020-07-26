import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/state.dart';

import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/app_drawer.dart';
import 'package:asia_bazar_seller/shared_widgets/circular_list.dart';
import 'package:asia_bazar_seller/shared_widgets/firebase_notification_configuration.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/date_utils.dart';
import 'package:asia_bazar_seller/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:progress_indicators/progress_indicators.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ThemeData theme;
  String usertoken, countryCode = '';
  TextEditingController _controller = TextEditingController(text: '');
  String currentFilter = KeyNames['orderPlaced'];
  ScrollController _scrollController = ScrollController();
  bool isFetching = false, showFullFilter = false, showOverlay = false;
  DocumentSnapshot lastItem;
  Debouncer _debouncer = Debouncer();
  bool showScrollUp = false;
  var scrollHeight = 0;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  var orderFilterList = [
    KeyNames['allOrders'],
    KeyNames['orderPlaced'],
    KeyNames['orderApproved'],
    KeyNames['orderDispatched'],
    KeyNames['orderDelivered'],
    KeyNames['orderRejected'],
  ];

  @override
  void initState() {
    ConfigureNotification.configureNotifications();
    _controller.text = '';
    fetchCountryCode();
    fetchCurrentFilterOrders();
    _scrollController.addListener(scrollListener);

    super.initState();
  }

  fetchCountryCode() async {
    try {
      String countrycode = await FlutterSimCountryCode.simCountryCode;
      Map dialCode = Countries.firstWhere(
          (item) => item['code'].toLowerCase() == countrycode.toLowerCase());
      setState(() {
        countryCode = dialCode['dial_code'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    _debouncer = null;
    super.dispose();
  }

  scrollListener() {
    setState(() {
      showScrollUp = _scrollController.position.pixels >
          MediaQuery.of(context).size.height;
    });

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true &&
        _controller.text.length == 0) {
      setState(() {
        isFetching = true;
      });
      fetchCurrentFilterOrders(startAt: lastItem);
    }
  }

  Future<void> fetchCurrentFilterOrders({DocumentSnapshot startAt}) async {
    String searchQuery = countryCode != null && countryCode.length > 0
        ? countryCode + _controller.text
        : _controller.text;
    BlocProvider.of<ItemDatabaseBloc>(context).add(FetchOrdersFiltered(
        filter: currentFilter,
        startAt: startAt,
        searchQuery: searchQuery.length > 4 ? searchQuery : null,
        callback: (data) {
          if (data.length == 0) {
            _scrollController.removeListener(scrollListener);
          } else {
            if (!_scrollController.hasListeners)
              _scrollController.addListener(scrollListener);
          }
          setState(() {
            isFetching = false;
          });
        }));
  }

  Widget orderCard(DocumentSnapshot order) {
    var statusColor;
    if (order['status'] == KeyNames['orderPlaced']) {
      statusColor = ColorShades.pacificBlue;
    }
    if (order['status'] == KeyNames['orderApproved']) {
      statusColor = ColorShades.greenColor;
    }
    if (order['status'] == KeyNames['orderDispatched'] ||
        order['status'] == KeyNames['orderReturnRequested']) {
      statusColor = ColorShades.darkOrange;
    }
    if (order['status'] == KeyNames['orderDelivered'] ||
        order['status'] == KeyNames['orderReturnApproved']) {
      statusColor = ColorShades.greenColor;
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
                        Flexible(
                          child: Text(timeString,
                              style: theme.textTheme.body1Regular
                                  .copyWith(color: ColorShades.greenBg)),
                        )
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

  void searchOrders(value) {}
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: BlocBuilder<ItemDatabaseBloc, Map>(builder: (context, state) {
            var currentState = state['ordersListState'];
            if (currentState is GlobalFetchingState) {
              return PageFetchingViewWithLightBg();
            } else if (currentState is GlobalErrorState) {
              return PageErrorView();
            } else if ((currentState is OrdersListFetchedState &&
                    currentState.orderFilter == currentFilter) ||
                currentState is PartialOrderFetchingState) {
              var listing = currentState.orderItems;
              if (listing.length > 0) {
                lastItem = listing[listing.length - 1];
              }
              return Scaffold(
                backgroundColor: ColorShades.white,
                drawer: AppDrawer(),
                appBar: MyAppBar(
                    backGroundColor: Colors.black.withOpacity(0.3),
                    hasTransparentBackground: !showOverlay,
                    title: L10n().getStr('home.title'),
                    hideBackArrow: true,
                    leading: {
                      'icon': Icon(Icons.dehaze),
                      'onTap': (ctx) => {Scaffold.of(ctx).openDrawer()}
                    }),
                body: Stack(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          listing.length > 0 || _controller.text.length > 0
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.space16,
                                  ),
                                  child: InputBox(
                                    onChanged: (value) {
                                      if (value.length > 2 || value.length == 0)
                                        _debouncer.run(() {
                                          fetchCurrentFilterOrders();
                                        });
                                    },
                                    controller: _controller,
                                    hideShadow: true,
                                    hintText: countryCode != null &&
                                            countryCode.length > 0
                                        ? L10n().getStr('home.search')
                                        : L10n().getStr(
                                            'home.searchWithCountryCode'),
                                    prefixIcon: countryCode != null &&
                                            countryCode.length > 0
                                        ? Container(
                                            width: 50,
                                            margin: EdgeInsets.only(
                                                right: Spacing.space12),
                                            child: InputBox(
                                              hideShadow: true,
                                              value: countryCode,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft:
                                                      Radius.circular(16)),
                                              onChanged: (value) {
                                                setState(() {
                                                  countryCode = value;
                                                });
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.search,
                                            color: ColorShades.greenBg,
                                          ),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: Spacing.space16,
                          ),
                          if (listing.length > 0 && currentFilter != 'all')
                            Padding(
                              padding: EdgeInsets.only(bottom: Spacing.space16),
                              child: Text(
                                L10n().getStr('home.orderCount', {
                                  'count': listing.length.toString(),
                                  'type': currentFilter
                                }),
                                style: theme.textTheme.h4
                                    .copyWith(color: ColorShades.greenBg),
                              ),
                            ),
                          if (listing.length > 0 &&
                              currentState is! PartialOrderFetchingState)
                            Expanded(
                              child: RefreshIndicator(
                                color: ColorShades.greenBg,
                                onRefresh: fetchCurrentFilterOrders,
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  itemCount: listing.length,
                                  itemBuilder: (context, index) {
                                    return orderCard(listing[index]);
                                  },
                                ),
                              ),
                            )
                          else if (currentState is PartialOrderFetchingState)
                            PageFetchingViewWithLightBg()
                          else
                            Expanded(
                              child: RefreshIndicator(
                                color: ColorShades.greenBg,
                                onRefresh: fetchCurrentFilterOrders,
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                          'assets/images/no_orders.png'),
                                      Text(
                                        currentFilter != 'all'
                                            ? L10n().getStr(
                                                'home.drawer.noOrder',
                                                {'type': currentFilter})
                                            : L10n().getStr('home.noOrders'),
                                        style: theme.textTheme.h4.copyWith(
                                            color: ColorShades.greenBg),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            height: Spacing.space8,
                          ),
                          if (isFetching &&
                              currentState is OrdersListFetchedState)
                            Padding(
                              padding: EdgeInsets.only(bottom: Spacing.space12),
                              child: ScalingText(L10n().getStr('app.loading'),
                                  style: theme.textTheme.h3
                                      .copyWith(color: ColorShades.greenBg)),
                            ),
                        ],
                      ),
                    ),
                    showOverlay
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black.withOpacity(0.3),
                          )
                        : Container(),
                  ],
                ),
                floatingActionButton: Builder(
                  builder: (context) => FabCircularMenu(
                    key: fabKey,
                    // Cannot be `Alignment.center`
                    alignment: Alignment.centerRight,
                    fabSize: 64.0,
                    ringColor: ColorShades.greenBg.withOpacity(0.7),
                    fabElevation: 8.0,
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

                      // _showSnackBar(
                      //     context, "The menu is ${isOpen ? "open" : "closed"}");
                    },
                    children: orderFilterList.map((item) {
                      bool isSelected = item == currentFilter;

                      return GestureDetector(
                        onTap: () {
                          if (currentFilter != item) {
                            setState(() {
                              currentFilter = item;
                              showOverlay = false;
                            });
                            fetchCurrentFilterOrders();
                          }
                          fabKey.currentState.close();
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
                              L10n().getStr('home.$item'),
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
          }),
        ),
      ),
    );
  }
}
