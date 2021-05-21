import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/customLoader.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateInfo extends StatefulWidget {
  @override
  _UpdateInfoState createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  ThemeData theme;
  bool disableButton = false, dataChanged = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _phone = TextEditingController(),
      _packCharge = TextEditingController(),
      _deliveryCharge = TextEditingController(),
      _otherCharge = TextEditingController(),
      _pointValue = TextEditingController(),
      _minPointValue = TextEditingController();
  @override
  void initState() {
    BlocProvider.of<GlobalBloc>(context).add(FetchSellerInfo());
    super.initState();
  }

  @override
  void dispose() {
    _phone.dispose();
    _pointValue.dispose();
    _packCharge.dispose();
    _otherCharge.dispose();
    _deliveryCharge.dispose();
    _minPointValue.dispose();
    super.dispose();
  }

  String phoneValidator(value) {
    if (value.indexOf('+') > -1) {
      value = value.replaceAll('+', '');
    } else {
      return L10n().getStr(
        "updateInfo.error.includePlus",
      );
    }
    if (value.length > 0 && int.tryParse(value) == null ||
        value.length < 6 ||
        value.length > 14) {
      return L10n().getStr(
        "phoneAuthentication.invalidPhoneNumber",
      );
    }

    return null;
  }

  String doubleValidator(value) {
    if (value.length == 0) {
      return L10n().getStr('onboarding.name.error');
    }
    if (value is int || value is double) {
      return null;
    }
    var val = double.tryParse(value);
    if (val != null)
      return null;
    else
      return L10n().getStr('updateInfo.error.invalidValue');
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('updateInfo.heading'),
        ),
        body: BlocBuilder<GlobalBloc, Map>(builder: (context, state) {
          var currentState = state['sellerInfo'];
          if (currentState is GlobalFetchingState) {
            return PageFetchingViewWithLightBg();
          } else if (currentState is InfoFetchedState) {
            var info = currentState.sellerInfo;
            _phone.text = info['phoneNumber'].toString();
            _deliveryCharge.text = info['deliveryCharges'].toString();
            _minPointValue.text = info['loyalty_point_limit'].toString();
            _pointValue.text = info['loyalty_point_value'].toString();
            _otherCharge.text = info['otherCharges'].toString();
            _packCharge.text = info['packagingCharges'].toString();
            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Spacing.space16, vertical: Spacing.space20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          L10n().getStr('updateInfo.contactInfo'),
                          style: theme.textTheme.h2
                              .copyWith(color: ColorShades.greenBg),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('updateInfo.contactNumber'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: phoneValidator,
                          controller: _phone,
                          hideShadow: true,
                          keyboardType: TextInputType.phone,
                          hintText: L10n().getStr('updateInfo.contactNumber'),
                        ),
                        SizedBox(
                          height: Spacing.space20,
                        ),
                        Text(
                          L10n().getStr('updateInfo.chargeInfo'),
                          style: theme.textTheme.h2
                              .copyWith(color: ColorShades.greenBg),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('orderDetails.deliveryCharges') +
                              " " +
                              L10n().getStr('updateInfo.inDollars'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: doubleValidator,
                          controller: _deliveryCharge,
                          hideShadow: true,
                          keyboardType: TextInputType.numberWithOptions(),
                          hintText:
                              L10n().getStr('orderDetails.deliveryCharges'),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('orderDetails.packagingCharges') +
                              " " +
                              L10n().getStr('updateInfo.inDollars'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: doubleValidator,
                          controller: _packCharge,
                          hideShadow: true,
                          keyboardType: TextInputType.numberWithOptions(),
                          hintText:
                              L10n().getStr('orderDetails.packagingCharges'),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('orderDetails.otherCharges') +
                              " " +
                              L10n().getStr('updateInfo.inDollars'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: doubleValidator,
                          controller: _otherCharge,
                          hideShadow: true,
                          keyboardType: TextInputType.numberWithOptions(),
                          hintText: L10n().getStr('orderDetails.otherCharges'),
                        ),
                        SizedBox(
                          height: Spacing.space20,
                        ),
                        Text(
                          L10n().getStr('updateInfo.pointsInfo'),
                          style: theme.textTheme.h2
                              .copyWith(color: ColorShades.greenBg),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('updateInfo.points.minPointsToUse'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space4,
                        ),
                        RichText(
                          text: TextSpan(
                              text: L10n().getStr('addUser.note') + " ",
                              style: theme.textTheme.body1Bold
                                  .copyWith(color: ColorShades.redOrange),
                              children: [
                                TextSpan(
                                    text: L10n().getStr(
                                      'updateInfo.points.minPointsToUse.info',
                                    ),
                                    style: theme.textTheme.body1Regular
                                        .copyWith(color: ColorShades.bastille))
                              ]),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: doubleValidator,
                          controller: _minPointValue,
                          hideShadow: true,
                          keyboardType: TextInputType.numberWithOptions(),
                          hintText:
                              L10n().getStr('orderDetails.deliveryCharges'),
                        ),
                        SizedBox(
                          height: Spacing.space12,
                        ),
                        Text(
                          L10n().getStr('updateInfo.points.pointsValue'),
                          style: theme.textTheme.h4.copyWith(
                            color: ColorShades.bastille,
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space4,
                        ),
                        RichText(
                          text: TextSpan(
                              text: L10n().getStr('addUser.note') + " ",
                              style: theme.textTheme.body1Bold
                                  .copyWith(color: ColorShades.redOrange),
                              children: [
                                TextSpan(
                                    text: L10n().getStr(
                                      'updateInfo.points.pointsValue.info',
                                    ),
                                    style: theme.textTheme.body1Regular
                                        .copyWith(color: ColorShades.bastille))
                              ]),
                        ),
                        SizedBox(
                          height: Spacing.space8,
                        ),
                        InputBox(
                          onChanged: (value) {},
                          validator: doubleValidator,
                          controller: _pointValue,
                          hideShadow: true,
                          keyboardType: TextInputType.numberWithOptions(),
                          hintText:
                              L10n().getStr('orderDetails.packagingCharges'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                child: Container(
                  height: 66,
                  padding: EdgeInsets.symmetric(
                      horizontal: Spacing.space16, vertical: Spacing.space12),
                  child: PrimaryButton(
                    disabled: disableButton,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          disableButton = true;
                        });
                        showCustomLoader(context);
                        var data = {
                          'phoneNumber': _phone.text,
                          'deliveryCharges':
                              double.tryParse(_deliveryCharge.text),
                          'packagingCharges': double.tryParse(_packCharge.text),
                          'otherCharges': double.tryParse(_otherCharge.text),
                          'loyalty_point_value':
                              double.tryParse(_pointValue.text),
                          'loyalty_point_limit':
                              double.tryParse(_minPointValue.text),
                        };
                        BlocProvider.of<GlobalBloc>(context)
                            .add(UpdateSellerInfo(
                                data: data,
                                callback: (value) {
                                  Navigator.pop(context);
                                  if (value) {
                                    setState(() {
                                      disableButton = false;
                                    });
                                  }
                                  showCustomSnackbar(
                                      type: value
                                          ? SnackbarType.success
                                          : SnackbarType.error,
                                      context: context,
                                      content: L10n().getStr(
                                          'updateInfo.result.${value ? 'success' : 'error'}'));
                                }));
                      } else {
                        showCustomSnackbar(
                            type: SnackbarType.error,
                            context: context,
                            content: L10n().getStr('updateInfo.invalid'));
                      }
                    },
                    text: L10n().getStr('updateInfo.update'),
                  ),
                ),
              ),
            );
          }
          return Container();
        }),
      ),
    );
  }
}
