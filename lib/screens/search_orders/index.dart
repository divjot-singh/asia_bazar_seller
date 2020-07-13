import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class SearchOrders extends StatefulWidget {
  @override
  _SearchOrdersState createState() => _SearchOrdersState();
}

class _SearchOrdersState extends State<SearchOrders> {
  ThemeData theme;
  TextEditingController _controller = TextEditingController(text: '');
  String selectedFilter = KeyNames['orderPlaced'], countryCode = '';

  @override
  void initState() {
    fetchCountryCode();
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

  searchOrders() {
    //if(_controller.text.length > 0)
  }
  var orderFilterList = [
    KeyNames['allOrders'],
    KeyNames['orderPlaced'],
    KeyNames['orderApproved'],
    KeyNames['orderDispatched'],
    KeyNames['orderDelivered'],
    KeyNames['orderRejected'],
  ];
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('home.searchOrder'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.space16, vertical: Spacing.space12),
                child: Row(
                  children: <Widget>[
                    if (countryCode.length > 0)
                      Padding(
                        padding: EdgeInsets.only(right: Spacing.space8),
                        child: Text(
                          countryCode.toString() + ' - ',
                          style: theme.textTheme.body1Bold
                              .copyWith(color: ColorShades.greenBg),
                        ),
                      ),
                    Flexible(
                      child: InputBox(
                        controller: _controller,
                        hideShadow: true,
                        hintText: countryCode.length > 0
                            ? L10n().getStr('search.enterPhoneNumber')
                            : L10n().getStr('search.phoneWithCountryCode'),
                        onChanged: (_) {},
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.length > 0) {
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: Spacing.space16,
                    ),
                    PopupMenuButton(
                      child: Icon(
                        Icons.filter_list,
                        color: ColorShades.greenBg,
                      ),
                      onSelected: (value) {
                        setState(() {
                          selectedFilter = value;
                        });
                      },
                      itemBuilder: (context) {
                        return orderFilterList.map((item) {
                          bool selected = item == selectedFilter;
                          return PopupMenuItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  item.toUpperCase(),
                                  style: theme.textTheme.body1Regular.copyWith(
                                      color: selected
                                          ? ColorShades.darkOrange
                                          : ColorShades.greenBg),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check,
                                    color: ColorShades.darkOrange,
                                    size: 20,
                                  )
                              ],
                            ),
                            value: item,
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                onPressed: () {
                  searchOrders();
                },
                text: L10n().getStr('searchOrders.search'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
