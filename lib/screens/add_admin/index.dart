import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

class AddAdmin extends StatefulWidget {
  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  ThemeData theme;
  String countryCode = '', enteredCountryCode = '';
  final _formKey = GlobalKey<FormState>();
  bool disableButton = false;
  TextEditingController _controller = TextEditingController(),
      _nameController = TextEditingController();
  String selectedUserMode = 'admin';
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

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('drawer.addUser'),
        ),
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
                    L10n().getStr('addUser.name'),
                    style: theme.textTheme.h4.copyWith(
                      color: ColorShades.greenBg,
                    ),
                  ),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  InputBox(
                    controller: _nameController,
                    onChanged: (_) {},
                    hideShadow: true,
                    keyboardType: TextInputType.text,
                    hintText: L10n().getStr('addUser.name.hint'),
                    validator: (value) {
                      if (value.length > 0)
                        return null;
                      else
                        return L10n().getStr('onboarding.name.error');
                    },
                  ),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  Text(
                    L10n().getStr('addUser.phoneNumber'),
                    style: theme.textTheme.h4.copyWith(
                      color: ColorShades.greenBg,
                    ),
                  ),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  InputBox(
                    controller: _controller,
                    onChanged: (_) {},
                    hideShadow: true,
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    hintText: countryCode != null && countryCode.length > 0
                        ? L10n().getStr('home.search')
                        : L10n().getStr('home.searchWithCountryCode'),
                    validator: (value) {
                      if (value.length > 0 && int.parse(value) is int) {
                        return null;
                      } else
                        return L10n().getStr('error.invalidPhoneNumber');
                    },
                    prefixIcon: countryCode != null && countryCode.length > 0
                        ? Container(
                            width: 50,
                            margin: EdgeInsets.only(right: Spacing.space12),
                            child: InputBox(
                              hideShadow: true,
                              validator: (value) {
                                if (value.length == 0) {
                                  return '';
                                } else
                                  return null;
                              },
                              value: countryCode,
                              hintText: '',
                              hideErrorText: true,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16)),
                              onChanged: (value) {
                                enteredCountryCode = value;
                              },
                            ),
                          )
                        : null,
                  ),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  Text(
                    L10n().getStr('addUser.mode'),
                    style: theme.textTheme.h4.copyWith(
                      color: ColorShades.greenBg,
                    ),
                  ),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  UserModes(
                      userModes: [
                        {'id': "admin", "name": L10n().getStr('addUser.admin')},
                        {
                          'id': "super_admin",
                          "name": L10n().getStr('addUser.superAdmin')
                        }
                      ],
                      selectedUserMode: selectedUserMode,
                      onGameModeChange: (value) {
                        setState(() {
                          selectedUserMode = value;
                        });
                      }),
                  SizedBox(
                    height: Spacing.space16,
                  ),
                  RichText(
                    text: TextSpan(
                      text: L10n().getStr('addUser.note') + ": ",
                      style: theme.textTheme.body1Medium
                          .copyWith(color: ColorShades.red),
                      children: [
                        TextSpan(
                          text: L10n().getStr('addUser.note.$selectedUserMode'),
                          style: theme.textTheme.body1Regular.copyWith(
                            color: ColorShades.bastille,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Spacing.space16, vertical: Spacing.space12),
            child: PrimaryButton(
              disabled: disableButton,
              text: L10n().getStr('addUser.add'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var userName = _nameController.text;
                  var phone = enteredCountryCode.length == 0
                      ? (countryCode.length == 0
                          ? _controller.text
                          : (countryCode + _controller.text))
                      : (enteredCountryCode + _controller.text);
                  bool isSuperAdmin = selectedUserMode == "super_admin";
                  setState(() {
                    disableButton = true;
                  });
                  BlocProvider.of<UserDatabaseBloc>(context).add(AddNewAdmin(
                      username: userName,
                      phoneNumber: phone,
                      isSuperAdmin: isSuperAdmin,
                      callback: (result) {
                        setState(() {
                          disableButton = false;
                        });
                        if (result) {
                          showCustomSnackbar(
                            type: SnackbarType.success,
                            context: context,
                            content: L10n().getStr('addUser.success'),
                          );
                          _nameController.text = '';
                          _controller.text = '';
                          selectedUserMode = 'admin';
                        } else {
                          showCustomSnackbar(
                            type: SnackbarType.error,
                            context: context,
                            content: L10n().getStr('profile.address.error'),
                          );
                        }
                      }));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class UserModes extends StatelessWidget {
  const UserModes({
    Key key,
    @required this.userModes,
    this.selectedUserMode,
    this.onGameModeChange,
  }) : super(key: key);

  final userModes;
  final onGameModeChange;
  final selectedUserMode;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    if (userModes == null || userModes.length == 0) return SizedBox();

    List<Widget> list = new List<Widget>();

    for (var i = 0; i < userModes.length; i++) {
      var mode = userModes[i];
      list.add(
        GameMode(
          mode: mode,
          selectedType: selectedUserMode,
          onChanged: (value) => onGameModeChange(value),
          isFirst: i == 0,
          isLast: i == userModes.length - 1,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadowLight,
              offset: Offset(0, 2),
              blurRadius: 12),
        ],
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: list,
      ),
    );
  }
}

class GameMode extends StatelessWidget {
  const GameMode({
    Key key,
    @required this.selectedType,
    @required this.onChanged,
    this.mode,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  final selectedType;
  final mode;
  final onChanged;
  final bool isFirst, isLast;
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLast ? 0 : 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        child: FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(20) : Radius.zero,
            bottomLeft: isFirst ? Radius.circular(20) : Radius.zero,
            topRight: isLast ? Radius.circular(20) : Radius.zero,
            bottomRight: isLast ? Radius.circular(20) : Radius.zero,
          )),
          padding: EdgeInsets.all(16),
          color: selectedType == mode["id"]
              ? ColorShades.greenBg
              : colorScheme.textPrimaryLight,
          child: Text(
            mode["name"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.body1Medium.copyWith(
              color: selectedType == mode["id"]
                  ? ColorShades.white
                  : colorScheme.textPrimaryDark,
            ),
          ),
          onPressed: () => onChanged(mode["id"]),
        ),
      ),
    );
  }
}
