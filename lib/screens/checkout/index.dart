import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/checkbox_list.dart';
import 'package:asia_bazar_seller/shared_widgets/customLoader.dart';
import 'package:asia_bazar_seller/shared_widgets/custom_dialog.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/network_manager.dart';
import 'package:asia_bazar_seller/utils/storage_manager.dart';
import 'package:asia_bazar_seller/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Checkout extends StatefulWidget {
  final double amount;
  Checkout({@required this.amount});
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Map address;
  var rzpPaymentId;
  String paymentMethod;
  var currentUser;
  ThemeData theme;
  bool itemsOutOfStock = false;
  Razorpay _razorpay;
  List paymentMethodOptions;
  var orderId;
  @override
  void initState() {
    paymentMethodOptions = paymentOptions;
    paymentMethod = paymentMethodOptions[0]['value'];
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    rzpPaymentId = response.paymentId;
    placeOrder();
    // showCustomSnackbar(
    //     context: context, type: SnackbarType.success, content: 'Success');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showCustomSnackbar(
        context: context, type: SnackbarType.error, content: 'Error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showCustomSnackbar(
        context: context, type: SnackbarType.error, content: 'Wallet');
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void paymentChangeHandler(value) {
    setState(() {
      paymentMethod = value;
    });
  }

  Widget getAddressBox() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.location_on, color: ColorShades.greenBg),
                SizedBox(
                  width: Spacing.space8,
                ),
                Text(
                  L10n().getStr('checkout.deliverTo') + ' : ',
                  style: theme.textTheme.body1Bold
                      .copyWith(color: ColorShades.greenBg),
                ),
                Text(
                  L10n().getStr('profile.address.type.' + address['type']),
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.greenBg),
                ),
                SizedBox(
                  width: Spacing.space4,
                ),
                if (address['is_default'] == true)
                  Text(
                    '(' + L10n().getStr('address.default') + ')',
                    style: theme.textTheme.body1Regular.copyWith(
                        fontStyle: FontStyle.italic,
                        color: ColorShades.greenBg),
                  ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                dynamic result = await Navigator.pushNamed(
                    context, Constants.ADDRESS_LIST,
                    arguments: {'selectView': true});
                if (result != null && result is Map) {
                  setState(() {
                    address = result;
                  });
                }
              },
              child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: Spacing.space8, horizontal: Spacing.space12),
                  decoration: BoxDecoration(
                    border: Border.all(color: ColorShades.greenBg),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    L10n().getStr('checkout.change'),
                    style: theme.textTheme.body2Regular
                        .copyWith(color: ColorShades.greenBg),
                  )),
            ),
          ],
        ),
        SizedBox(
          height: Spacing.space8,
        ),
        Text(
          address['address_text'],
          style:
              theme.textTheme.body1Regular.copyWith(color: ColorShades.greenBg),
        )
      ],
    );
  }

  Widget getPaymentOptions() {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              L10n().getStr('checkout.paymentOption'),
              style: theme.textTheme.pageTitle
                  .copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space16,
            ),
            Expanded(
              child: CheckboxList(
                items: paymentMethodOptions,
                selectedValue: paymentMethod,
                changeHandler: paymentChangeHandler,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void placeOrder() async {
    var phoneNumber = currentUser[KeyNames['phone']];
    var userName = currentUser[KeyNames['userName']];
    var orderAddress = address;
    var amount = widget.amount;
    var orderPaymentMethod = paymentMethodOptions
        .firstWhere((item) => item['value'] == paymentMethod);
    Map cartItems = {...currentUser[KeyNames['cart']]};

    ///cartItems.removeWhere((key, item) => item['quantity'] < 1);
    orderId = Utilities.getOrderId(userName);
    var userId = await StorageManager.getItem(KeyNames['userId']);
    var orderDetails = {
      'phoneNumber': phoneNumber,
      'address': orderAddress,
      'amount': amount,
      'paymentMethod': orderPaymentMethod,
      'cart': cartItems,
      'orderId': orderId,
      'status': KeyNames['orderPlaced'],
      'userId': userId,
    };
    BlocProvider.of<ItemDatabaseBloc>(context).add(
        PlaceOrder(orderDetails: orderDetails, callback: placeOrderCallback));
    showCustomLoader(context, text: L10n().getStr('checkout.placingOrder'));
  }

  void placeOrderCallback(result) {
    Navigator.pop(context);
    if (result == true) {
      BlocProvider.of<UserDatabaseBloc>(context).add(EmptyCart());
      if (orderId != null) {
        Navigator.popAndPushNamed(
            context, Constants.ORDER_DETAILS.replaceAll(':orderId', orderId));
      } else
        showCustomSnackbar(
            context: context, content: 'Success', type: SnackbarType.success);

      //todo order placed, take to order details page
    } else if (result is Map) {
      setState(() {
        itemsOutOfStock = true;
      });
      processRefund();
      showCustomDialog(
        context: context,
        heading: '',
        child: Container(
          child: Column(
            children: <Widget>[
              Text(
                L10n().getStr('checkout.itemOutOfStock'),
                style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Spacing.space20,
              ),
              PrimaryButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {'refresh': true});
                },
                text: L10n().getStr('redirector.goBack'),
              ),
            ],
          ),
        ),
      );
    } else {
      processRefund();
      showCustomSnackbar(
          context: context,
          content: L10n().getStr('profile.address.error') +
              '.' +
              L10n().getStr('cart.refundProcessing'),
          type: SnackbarType.error);
    }
  }

  void processRefund() async {
    if (paymentMethod == 'razorpay' && rzpPaymentId != null) {
      var refundUrl = URLS['refund_url'].replaceAll(':paymentId', rzpPaymentId);
      await NetworkManager.post(url: refundUrl, sendCredentials: false);
    }
  }

  void makePaymentAndPlaceOrder() {
    if (paymentMethod == 'cod') {
      placeOrder();
    } else if (paymentMethod == 'razorpay') {
      _razorpay.open(razorpayOptions);
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {

      return Container();
    });
  }
}
