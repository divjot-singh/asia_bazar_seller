import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/customLoader.dart';
import 'package:asia_bazar_seller/shared_widgets/custom_dialog.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/secondary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/slider_button/index.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  final String orderId;
  OrderDetails({@required this.orderId});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  ThemeData theme;
  String sellerPhoneNumber, documentId;
  List statusChronology = [
    KeyNames['orderPlaced'],
    KeyNames['orderApproved'],
    KeyNames['orderDispatched'],
    KeyNames['orderDelivered'],
    KeyNames['orderRejected'],
  ];
  double pointsValue;
  @override
  void initState() {
    BlocProvider.of<OrderDetailsBloc>(context)
        .add(FetchOrderDetails(orderId: widget.orderId));
    BlocProvider.of<OrderDetailsBloc>(context)
        .add(FetchOrderItems(orderId: widget.orderId));
    BlocProvider.of<GlobalBloc>(context)
        .add(FetchSellerInfo(callback: fetchInfoCallback));
    super.initState();
  }

  void fetchInfoCallback(info) {
    if (info['loyalty_point_value'] != null) {
      setState(() {
        pointsValue = info['loyalty_point_value'];
      });
    }
  }

  void acceptOrRejectOrder(DismissDirection direction, {List itemList}) {
    if (direction == DismissDirection.startToEnd) {
      updateStatus(KeyNames['orderApproved']);
    } else {
      updateStatus(KeyNames['orderRejected'], itemList: itemList);
    }
  }

  Future<bool> showRejectDialog(DismissDirection direction) async {
    if (direction == DismissDirection.endToStart) {
      return await showCustomDialog(
          context: context,
          child: Column(
            children: <Widget>[
              Text(
                L10n().getStr('orderDetails.reject.confirm'),
                textAlign: TextAlign.center,
                style: theme.textTheme.h4.copyWith(
                  color: ColorShades.bastille,
                ),
              ),
              SizedBox(
                height: Spacing.space20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.space8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    PrimaryButton(
                      text: L10n().getStr('confirmation.yes'),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                    SecondaryButton(
                      hideShadow: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: Spacing.space16,
                          vertical: Spacing.space12),
                      noWidth: true,
                      text: L10n().getStr('confirmation.cancel'),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if (direction == DismissDirection.startToEnd) {
      return true;
    }
    return false;
  }

  updateStatus(status, {List itemList, Map pointsDetails}) {
    if (documentId != null) {
      showCustomLoader(context);
      BlocProvider.of<OrderDetailsBloc>(context).add(UpdateOrderStatus(
          newStatus: status,
          orderId: documentId,
          itemList: itemList,
          pointsDetails: pointsDetails,
          callback: (value) {
            Navigator.pop(context);
            if (value) {
              refreshPage();
            } else {
              showCustomSnackbar(
                context: context,
                type: SnackbarType.error,
                content: L10n().getStr('profile.address.error'),
              );
            }
          }));
    }
  }

  Widget fetchBottomCta(status, {List itemList, Map pointsDetails}) {
    if (status == KeyNames['orderPlaced']) {
      return CenterSliderButton(
        onDismiss: (direction) =>
            acceptOrRejectOrder(direction, itemList: itemList),
        confirmDismiss: showRejectDialog,
        leftShimmerHighlightColor: Colors.red[200],
        rightShimmerHighlightColor: Colors.green[200],
        leftShimmerBaseColor: ColorShades.white,
        rightShimmerBaseColor: ColorShades.white,
        leftChild: Text(
          L10n().getStr('orderDetails.reject'),
          textAlign: TextAlign.right,
          style:
              Theme.of(context).textTheme.h3.copyWith(color: ColorShades.white),
        ),
        rightChild: Text(
          L10n().getStr('orderDetails.approve'),
          textAlign: TextAlign.right,
          style:
              Theme.of(context).textTheme.h3.copyWith(color: ColorShades.white),
        ),
        centerChild: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesome.backward,
              size: 16,
              color: ColorShades.greenBg,
            ),
            SizedBox(width: Spacing.space4),
            Icon(
              FontAwesome.forward,
              size: 16,
              color: ColorShades.greenBg,
            ),
          ],
        ),
      );
    } else if (status == KeyNames['orderDispatched'] ||
        status == KeyNames['orderApproved']) {
      int statusIndex = statusChronology.indexOf(status);
      return SliderButton(
        action: () {
          updateStatus(statusChronology[statusIndex + 1],
              pointsDetails: pointsDetails);
        },
        backgroundColor: ColorShades.greenBg,
        buttonBoxShadow: BoxShadow(
          color: ColorShades.darkGreenBg,
          blurRadius: 4,
        ),
        baseColor: ColorShades.veryLightGrey,
        highlightedColor: ColorShades.white,
        alignLabel: Alignment.center,
        label: Text(
          L10n().getStr("orderDetails." + statusChronology[statusIndex + 1]),
          style: theme.textTheme.h3.copyWith(color: ColorShades.white),
        ),
        icon: Icon(Icons.fast_forward, size: 32, color: ColorShades.greenBg),
      );
    } else if (status == KeyNames['orderDelivered']) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(100),
            color: ColorShades.greenColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: ColorShades.white,
              size: 32,
            ),
            SizedBox(
              width: Spacing.space8,
            ),
            Text(
              L10n().getStr('orderDetails.orderDelivered'),
              style: theme.textTheme.h3.copyWith(color: ColorShades.white),
            ),
          ],
        ),
      );
    } else if (status == KeyNames['orderRejected']) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.circular(100),
          color: ColorShades.redOrange,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.cancel,
              color: ColorShades.white,
              size: 32,
            ),
            SizedBox(
              width: Spacing.space8,
            ),
            Flexible(
              child: Text(
                L10n().getStr('orderDetails.orderRejected'),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.h3.copyWith(color: ColorShades.white),
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget orderInfo(details) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: Spacing.space12),
        padding: EdgeInsets.symmetric(
            horizontal: Spacing.space8, vertical: Spacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(L10n().getStr('orderDetails.heading') + ": ",
                style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg)),
            SizedBox(
              height: Spacing.space16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(L10n().getStr('orderDetails.orderId') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        details['orderId'],
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(L10n().getStr('orderDetails.orderStatus') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        L10n().getStr('home.' + details['status']),
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  children: <Widget>[
                    Text(L10n().getStr('editProfile.phone') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Text(
                      details['phoneNumber'],
                      style: theme.textTheme.body1Regular
                          .copyWith(color: ColorShades.bastille),
                    ),
                    SizedBox(
                      width: Spacing.space4,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.phone,
                        color: ColorShades.greenBg,
                        size: 20,
                      ),
                      onTap: () {
                        contactCustomer(
                            context: context,
                            phoneNumber: details['phoneNumber']);
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(L10n().getStr('profile.address') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        details['address']['address_text'],
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                    SizedBox(
                      width: Spacing.space4,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.directions,
                        color: ColorShades.greenBg,
                        size: 24,
                      ),
                      onTap: () async {
                        var address = details['address'];
                        var lat = address['lat'], long = address['long'];
                        final url =
                            'https://www.google.com/maps/search/?api=1&query=$lat,$long';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          showCustomSnackbar(
                              type: SnackbarType.error,
                              context: context,
                              content: L10n().getStr('address.cantLaunch'));
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(L10n().getStr('order.amount') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        '\$ ${details['amount'].toString()}',
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(L10n().getStr('orderDetails.paymentMethod') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        details['paymentMethod']['title'],
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(L10n().getStr('orderDetails.placedOn') + ': ',
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                    Flexible(
                      child: Text(
                        DateFormatter.formatWithTime(details['timestamp']
                            .millisecondsSinceEpoch
                            .toString()),
                        style: theme.textTheme.body1Regular
                            .copyWith(color: ColorShades.bastille),
                      ),
                    ),
                  ],
                ),
                if (details['deliveryTimestamp'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: Spacing.space12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(L10n().getStr('orderDetails.deliveredOn') + ': ',
                            style: theme.textTheme.h4
                                .copyWith(color: ColorShades.greenBg)),
                        Flexible(
                          child: Text(
                            DateFormatter.formatWithTime(
                                details['deliveryTimestamp']
                                    .millisecondsSinceEpoch
                                    .toString()),
                            style: theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.bastille),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemDetails(Map orderDetails) {
    return BlocBuilder<OrderDetailsBloc, Map>(
      builder: (context, state) {
        var currentState = state['itemState'];
        if (currentState is ItemFetchedState &&
            currentState.orderId == widget.orderId) {
          List items = currentState.orderItems;

          double totalCost = double.parse(orderDetails['amount'].toString()),
              otherCharges = 0,
              cartTotal = 0;
          cartTotal = items.fold(0, (value, item) {
            var details = item['orderData'].data['itemDetails'];
            var price = details['price'] != null ? details['price'] : 0;
            return value + (price * details['cartQuantity']);
          });
          cartTotal = ((cartTotal * 100).ceil() / 100);
          otherCharges = totalCost - cartTotal;
          //otherCharges =
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  L10n().getStr('orderDetails.itemDetails') + ": ",
                  style:
                      theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
                ),
                SizedBox(
                  height: Spacing.space16,
                ),
                Table(
                  border: TableBorder.all(width: 4, color: Colors.transparent),
                  columnWidths: {
                    0: FixedColumnWidth(60),
                    1: FlexColumnWidth(1),
                    2: FixedColumnWidth(80),
                    3: FixedColumnWidth(80)
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: Text(
                            L10n().getStr('orderDetails.price'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.h4
                                .copyWith(color: ColorShades.bastille),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TableCell(
                          child: Text(
                            L10n().getStr('orderDetails.quantity'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.h4
                                .copyWith(color: ColorShades.bastille),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    ...items.map((item) {
                      var orderedItemDetails =
                          item['orderData'].data['itemDetails'];
                      var itemDetails = item['itemData'].data;
                      return TableRow(children: [
                        TableCell(
                          child: itemDetails['image_url'] != null
                              ? FadeInImage.assetNetwork(
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.fill,
                                  placeholder: 'assets/images/loader.gif',
                                  image: itemDetails['image_url'],
                                )
                              : Image.asset(
                                  'assets/images/not-available.jpeg',
                                  height: 60,
                                  width: 60,
                                ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(left: Spacing.space12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  itemDetails['description'],
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.h4
                                      .copyWith(color: ColorShades.bastille),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: Spacing.space4,
                                ),
                                Text(
                                  itemDetails['dept_name'],
                                  textAlign: TextAlign.left,
                                  style: theme.textTheme.body1Regular
                                      .copyWith(color: ColorShades.grey300),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        TableCell(
                          child: Text(
                            '\$ ${orderedItemDetails['price']}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.bastille),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TableCell(
                          child: Text(
                            '${orderedItemDetails['cartQuantity']}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.bastille),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]);
                    }),
                    TableRow(
                      children: [
                        TableCell(
                          child: SizedBox(
                            height: Spacing.space24,
                            width: 60,
                          ),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: Spacing.space8),
                                child: Text(
                                    L10n().getStr('orderDetails.cartTotal'),
                                    textAlign: TextAlign.left,
                                    style: theme.textTheme.h4
                                        .copyWith(color: ColorShades.bastille)),
                              ),
                            ],
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              '\$ ${cartTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.body1Medium
                                  .copyWith(color: ColorShades.bastille),
                            ),
                          ),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        TableCell(
                          child: SizedBox(
                            height: Spacing.space16,
                            width: 60,
                          ),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                        TableCell(
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    if (otherCharges > 0)
                      TableRow(
                        children: [
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: Spacing.space8),
                                  child: Text(
                                      L10n()
                                          .getStr('orderDetails.otherCharges'),
                                      textAlign: TextAlign.left,
                                      style: theme.textTheme.h4.copyWith(
                                          color: ColorShades.bastille)),
                                ),
                              ],
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                '\$ ${(otherCharges).toStringAsFixed(2)}',
                                style: theme.textTheme.body1Medium
                                    .copyWith(color: ColorShades.bastille),
                              ),
                            ),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    if (otherCharges > 0)
                      TableRow(
                        children: [
                          TableCell(
                            child: SizedBox(
                              height: Spacing.space16,
                              width: 60,
                            ),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    if (otherCharges > 0)
                      TableRow(
                        children: [
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: Spacing.space8),
                                  child: Text(
                                      L10n().getStr('orderDetails.total'),
                                      textAlign: TextAlign.left,
                                      style: theme.textTheme.h4.copyWith(
                                          color: ColorShades.bastille)),
                                ),
                              ],
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                '\$ ${(totalCost).toStringAsFixed(2)}',
                                style: theme.textTheme.body1Medium
                                    .copyWith(color: ColorShades.bastille),
                              ),
                            ),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    if (otherCharges > 0)
                      TableRow(
                        children: [
                          TableCell(
                            child: SizedBox(
                              height: Spacing.space16,
                              width: 60,
                            ),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                          TableCell(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(
                  height: Spacing.space12,
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.space12),
          child: ScalingText(L10n().getStr('app.loading'),
              style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg)),
        );
      },
    );
  }

  Widget takeCashBanner(amount) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.space16),
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space12),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorShades.greenBg,
      ),
      child: Text(
          L10n().getStr('orderDetails.takeCash', {'amount': amount.toString()}),
          textAlign: TextAlign.center,
          style: theme.textTheme.h3.copyWith(color: ColorShades.white)),
    );
  }

  Future<void> refreshPage() async {
    Navigator.pushReplacementNamed(context,
        Constants.ORDER_DETAILS.replaceAll(":orderId", widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('orderDetails.heading'),
        ),
        body: BlocBuilder<OrderDetailsBloc, Map>(
          builder: (context, currentState) {
            var state = currentState['orderState'];

            if (state is GlobalFetchingState) {
              return Scaffold(
                  backgroundColor: ColorShades.white,
                  body: PageFetchingViewWithLightBg());
            } else if (state is GlobalErrorState) {
              return PageErrorView();
            } else if (state is OrderFetchedState) {
              if (state.orderDetails.length == 0) {
                return PageEmptyView();
              } else {
                var orderDetails = state.orderDetails;
                documentId = state.documentId;
                var pointsDetails;
                if (pointsValue != null) {
                  pointsDetails = {
                    'userId': orderDetails['userId'],
                    'points': pointsValue * orderDetails['amount']
                  };
                }

                return RefreshIndicator(
                  backgroundColor: ColorShades.greenBg,
                  onRefresh: refreshPage,
                  child: Scaffold(
                    body: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(children: [
                        orderInfo(orderDetails),
                        SizedBox(
                          height: Spacing.space16,
                        ),
                        if (orderDetails['status'] ==
                                KeyNames['orderDispatched'] &&
                            orderDetails['paymentMethod']['value'] == 'cod')
                          takeCashBanner(orderDetails['amount']),
                        itemDetails(orderDetails),
                      ]),
                    ),
                    bottomNavigationBar: BlocBuilder<OrderDetailsBloc, Map>(
                        builder: (context, state) {
                      var currentState = state['itemState'];
                      if (currentState is ItemFetchedState &&
                          currentState.orderId == widget.orderId) {
                        var orderedItems = currentState.orderItems.map((item) {
                          var itemDetails =
                              item['orderData'].data['itemDetails'];
                          return {
                            'category_id': itemDetails['category_id'],
                            'quantity': itemDetails['cartQuantity'],
                            'itemId': itemDetails['item_id'].toString()
                          };
                        }).toList();

                        return BottomAppBar(
                          child: Container(
                            height: 72,
                            padding: EdgeInsets.symmetric(
                                horizontal: Spacing.space16,
                                vertical: Spacing.space12),
                            child: fetchBottomCta(orderDetails['status'],
                                itemList: orderedItems,
                                pointsDetails: pointsDetails),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                  ),
                );
              }
            }
            return Container();
          },
        ),
      ),
    );
  }
}

void contactCustomer({String phoneNumber, BuildContext context}) {
  ThemeData theme = Theme.of(context);
  try {
    launch("tel://$phoneNumber");
  } catch (e) {
    showCustomDialog(
      context: context,
      heading: '',
      child: Container(
        child: Column(
          children: <Widget>[
            Text(
              L10n().getStr('contactSeller.error.info'),
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: Spacing.space20,
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: phoneNumber),
                ).then((_) {
                  Navigator.pop(context);
                  showCustomSnackbar(
                      type: SnackbarType.success,
                      context: context,
                      content: L10n().getStr('contactSeller.copied'));
                });
              },
              child: InputBox(
                hideShadow: true,
                disabled: true,
                onChanged: (_) {},
                value: phoneNumber,
                suffixIcon: Icon(Icons.content_copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
