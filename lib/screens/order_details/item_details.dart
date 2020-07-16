import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderItemDetails extends StatefulWidget {
  final bool editView;
  final String orderId;
  OrderItemDetails({@required this.orderId, this.editView = false});

  @override
  _OrderItemDetailsState createState() => _OrderItemDetailsState();
}

class _OrderItemDetailsState extends State<OrderItemDetails> {
  ThemeData theme;
  double grandTotal = 0;
  double totalCost = 0;
  double packagingCharges = 0;
  double otherCharges = 0;
  double deliveryCharges = 0;
  List selectedItems;
  bool selected = true;
  var currentUser;
  var address;
  @override
  void initState() {
    // BlocProvider.of<OrderDetailsBloc>(context).add(
    //     FetchOrderItems(orderId: widget.orderId, callback: fetchItemsCallback))s;
    BlocProvider.of<GlobalBloc>(context)
        .add(FetchSellerInfo(callback: fetchSellerCallback));
    super.initState();
  }

  fetchItemsCallback(List items) {
    List allItems = items.map((item) {
      var cartItem = item['orderData'].data['itemDetails'];
      return {
        'id': cartItem['opc'].toString(),
        'price': cartItem['price'],
        'returnQuantity': cartItem['cartQuantity'],
        'item': item
      };
    }).toList();
    setState(() {
      selectedItems = [...allItems];
    });
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

  Widget itemTile(item) {
    var listItem = item['itemData'].data;
    var cartItem = item['orderData'].data['itemDetails'];
    var returnedQuantity;
    if (selectedItems != null && widget.editView) {
      var selectedCartItem = selectedItems.firstWhere(
          (item) => item['id'] == listItem['opc'].toString(),
          orElse: () => {});
      returnedQuantity = selectedCartItem['returnQuantity'] != null
          ? selectedCartItem['returnQuantity']
          : 0;
    } else {
      returnedQuantity = cartItem['cartQuantity'];
    }
    bool outOfStock = listItem['quantity'] == 0;
    var itemTotal = cartItem['price'] * returnedQuantity;
    itemTotal = ((itemTotal * 100).ceil() / 100);
    totalCost += itemTotal;
    grandTotal = totalCost + deliveryCharges + otherCharges + packagingCharges;
    totalCost = ((totalCost * 100).ceil() / 100);
    grandTotal = ((grandTotal * 100).ceil() / 100);

    return Container(
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          // boxShadow: [Shadows.cardLight],
          color: outOfStock ? ColorShades.grey100 : ColorShades.white),
      padding: EdgeInsets.symmetric(
          horizontal: widget.editView ? 0 : Spacing.space16,
          vertical: Spacing.space12),
      margin: EdgeInsets.only(
          bottom: Spacing.space16,
          left: Spacing.space16,
          right: Spacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // Image.network(
          //   listItem['image_url'] != null
          //       ? listItem['image_url']
          //       : 'https://dummyimage.com/600x400/ffffff/000000.png&text=Image+not+available',
          //   height: widget.editView ? 50 : 100,
          //   width: widget.editView ? 50 : 100,
          // ),
          // SizedBox(
          //   width: Spacing.space12,
          // ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  listItem['description'] + ':',
                  style:
                      theme.textTheme.h4.copyWith(color: ColorShades.bastille),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          SizedBox(
            height: Spacing.space12,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        L10n().getStr('orderDetails.quantity'),
                        style: theme.textTheme.body1Bold
                            .copyWith(color: theme.colorScheme.textPrimaryDark),
                      ),
                      SizedBox(
                        height: Spacing.space4,
                      ),
                      Text(
                        widget.editView
                            ? returnedQuantity.toString()
                            : cartItem['cartQuantity'].toString(),
                        style: theme.textTheme.body1Regular
                            .copyWith(color: theme.colorScheme.textPrimaryDark),
                      )
                    ]),
              ),
              Expanded(
                child: Column(children: [
                  Text(L10n().getStr('orderDetails.price'),
                      style: theme.textTheme.body1Bold
                          .copyWith(color: theme.colorScheme.textPrimaryDark)),
                  SizedBox(
                    height: Spacing.space4,
                  ),
                  Text('\$ ${cartItem['price'].toStringAsFixed(2)}',
                      style: theme.textTheme.body1Regular
                          .copyWith(color: theme.colorScheme.textPrimaryDark))
                ]),
              ),
              Expanded(
                child: Column(children: [
                  Text(L10n().getStr('orderDetails.total'),
                      style: theme.textTheme.body1Bold
                          .copyWith(color: theme.colorScheme.textPrimaryDark)),
                  SizedBox(
                    height: Spacing.space4,
                  ),
                  Text('\$ ${itemTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.body1Regular
                          .copyWith(color: theme.colorScheme.textPrimaryDark))
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> totalCalculations() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Divider(
          thickness: 2,
          color: ColorShades.grey100,
        ),
      ),
      SizedBox(
        height: Spacing.space16,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              L10n().getStr('orderDetails.cartTotal') + ' : ',
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
            ),
            Text(
              '\$ ${totalCost.toStringAsFixed(2)}',
              style: theme.textTheme.body1Medium
                  .copyWith(color: ColorShades.bastille),
            ),
          ],
        ),
      ),
      if (deliveryCharges > 0)
        SizedBox(
          height: Spacing.space16,
        ),
      if (deliveryCharges > 0)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('orderDetails.deliveryCharges') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${deliveryCharges.toStringAsFixed(2)}',
                style: theme.textTheme.body1Medium
                    .copyWith(color: ColorShades.bastille),
              ),
            ],
          ),
        ),
      if (packagingCharges > 0)
        SizedBox(
          height: Spacing.space16,
        ),
      if (packagingCharges > 0)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('orderDetails.packagingCharges') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${packagingCharges.toStringAsFixed(2)}',
                style: theme.textTheme.body1Medium
                    .copyWith(color: ColorShades.bastille),
              ),
            ],
          ),
        ),
      if (otherCharges > 0)
        SizedBox(
          height: Spacing.space16,
        ),
      if (otherCharges > 0)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('orderDetails.otherCharges') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${otherCharges.toStringAsFixed(2)}',
                style: theme.textTheme.body1Medium
                    .copyWith(color: ColorShades.bastille),
              ),
            ],
          ),
        ),
      if (grandTotal != totalCost)
        SizedBox(
          height: Spacing.space8,
        ),
      if (grandTotal != totalCost)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Divider(
            color: ColorShades.grey100,
            thickness: 2,
          ),
        ),
      if (grandTotal != totalCost)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                L10n().getStr('cart.total') + ' : ',
                style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
              ),
              Text(
                '\$ ${grandTotal.toStringAsFixed(2)}',
                style: theme.textTheme.body1Medium
                    .copyWith(color: ColorShades.bastille),
              ),
            ],
          ),
        ),
      SizedBox(
        height: Spacing.space16,
      ),
    ];
  }

  List<Widget> returnCalculations() {
    var returnValue;
    if (selectedItems != null) {
      returnValue = selectedItems.fold(0, (value, item) {
        var cartQuantity = item['returnQuantity'];
        var itemCost = item['price'];
        value += (cartQuantity * itemCost);
        return value;
      });
      returnValue = ((returnValue * 100).ceil() / 100);
    } else {
      returnValue = 0;
    }
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.space16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              L10n().getStr('orderDetails.return.value') + ' : ',
              style: theme.textTheme.h4.copyWith(color: ColorShades.bastille),
            ),
            Text(
              '\$ ${returnValue.toStringAsFixed(2)}',
              style: theme.textTheme.body1Medium
                  .copyWith(color: ColorShades.bastille),
            ),
          ],
        ),
      ),
    ];
  }

  confirmExchangeReturn(type) {
    if (type == 'return') {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    grandTotal = 0;
    totalCost = 0;
    theme = Theme.of(context);
    return BlocBuilder<UserDatabaseBloc, Map>(builder: (context, state) {
      return Container();
    });
  }
}

class ExchangeReturnDialog extends StatefulWidget {
  final Function onSelect;
  ExchangeReturnDialog({@required this.onSelect});
  @override
  _ExchangeReturnDialogState createState() => _ExchangeReturnDialogState();
}

class _ExchangeReturnDialogState extends State<ExchangeReturnDialog> {
  var selectedVal;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(
          L10n().getStr('orderDetails.choose'),
          style: theme.textTheme.h3.copyWith(color: ColorShades.greenBg),
        ),
        SizedBox(
          height: Spacing.space20,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedVal = 'exchange';
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                boxShadow: selectedVal == 'exchange'
                    ? [
                        BoxShadow(
                          color: ColorShades.darkGreenBg,
                          offset: Offset(-3, 5),
                          blurRadius: 6,
                        )
                      ]
                    : null,
                border: Border.all(color: ColorShades.greenBg),
                borderRadius: BorderRadius.circular(20),
                color: selectedVal == 'exchange'
                    ? ColorShades.greenBg
                    : ColorShades.white),
            child: Center(
                child: Text(L10n().getStr('orderDetails.exchange'),
                    style: theme.textTheme.body1Bold.copyWith(
                      color: selectedVal == 'exchange'
                          ? ColorShades.white
                          : ColorShades.greenBg,
                    ))),
          ),
        ),
        SizedBox(
          height: Spacing.space20,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedVal = 'return';
            });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                boxShadow: selectedVal == 'return'
                    ? [
                        BoxShadow(
                          color: ColorShades.darkGreenBg,
                          offset: Offset(-3, 5),
                          blurRadius: 6,
                        )
                      ]
                    : null,
                border: Border.all(color: ColorShades.greenBg),
                borderRadius: BorderRadius.circular(20),
                color: selectedVal == 'return'
                    ? ColorShades.greenBg
                    : ColorShades.white),
            child: Center(
                child: Text(L10n().getStr('orderDetails.return'),
                    style: theme.textTheme.body1Bold.copyWith(
                      color: selectedVal == 'return'
                          ? ColorShades.white
                          : ColorShades.greenBg,
                    ))),
          ),
        ),
        SizedBox(
          height: Spacing.space24,
        ),
        PrimaryButton(
            disabled: selectedVal == null,
            onPressed: () {
              widget.onSelect(selectedVal);
            },
            text: L10n().getStr('app.confirm')),
      ],
    );
  }
}
