import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/base_card.dart';
import 'package:asia_bazar_seller/shared_widgets/customLoader.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';

class ManageAdmins extends StatefulWidget {
  @override
  _ManageAdminsState createState() => _ManageAdminsState();
}

class _ManageAdminsState extends State<ManageAdmins> {
  ThemeData theme;
  String myPhoneNumber = '';
  @override
  void initState() {
    BlocProvider.of<UserDatabaseBloc>(context).add(FetchAllAdmins());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          title: L10n().getStr('manageUser.heading'),
          hasTransparentBackground: true,
        ),
        body: BlocBuilder<UserDatabaseBloc, Map>(
          builder: (context, state) {
            var currentState = state['allAdmins'];
            var userState = state['userstate'];
            if (userState is UserIsAdmin) {
              myPhoneNumber = userState.user[KeyNames['phone']];
            }
            if (currentState is GlobalFetchingState) {
              return PageFetchingViewWithLightBg();
            } else if (currentState is GlobalErrorState) {
              return PageErrorView();
            } else if (currentState is AllAdminsFetchedState) {
              List admins = currentState.admins;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: Spacing.space24),
                child: ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    var admin = admins[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: Spacing.space16),
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.space16,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Spacing.space16,
                            vertical: Spacing.space12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ColorShades.greenBg,
                            ColorShades.lightGreenBg50,
                          ]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            admin['isSuperAdmin']
                                ? SvgPicture.asset(
                                    'assets/images/administrator.svg',
                                    height: 30,
                                    width: 30,
                                    color: ColorShades.white,
                                  )
                                : Icon(
                                    Icons.person,
                                    color: ColorShades.white,
                                    size: 32,
                                  ),
                            SizedBox(
                              width: Spacing.space24,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    admin[KeyNames['userName']],
                                    style: theme.textTheme.h3
                                        .copyWith(color: ColorShades.white),
                                  ),
                                  SizedBox(
                                    width: Spacing.space8,
                                  ),
                                  SizedBox(
                                    height: Spacing.space8,
                                  ),
                                  Text(
                                    "(${admin[KeyNames['phone']]})",
                                    style: theme.textTheme.body1Bold
                                        .copyWith(color: ColorShades.white),
                                  ),
                                  SizedBox(
                                    height: Spacing.space8,
                                  ),
                                  Text(
                                    L10n().getStr(admin[KeyNames['superAdmin']]
                                        ? "addUser.superAdmin"
                                        : "addUser.admin"),
                                    style: theme.textTheme.body1Regular
                                        .copyWith(color: ColorShades.white),
                                  ),
                                ],
                              ),
                            ),
                            if (myPhoneNumber != admin[KeyNames['phone']])
                              PopupMenuTheme(
                                data: PopupMenuThemeData(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    textStyle: theme.textTheme.body1Regular
                                        .copyWith(color: ColorShades.white)),
                                child: PopupMenuButton(
                                  onSelected: (value) {
                                    var bloc =
                                        BlocProvider.of<UserDatabaseBloc>(
                                            context);
                                    var callback = (result) {
                                      Navigator.pop(context);
                                      if (result == false) {
                                        var error = 'profile.address.error';
                                        showCustomSnackbar(
                                          type: SnackbarType.error,
                                          context: context,
                                          content: L10n().getStr(error),
                                        );
                                      }
                                    };
                                    showCustomLoader(context);
                                    if (value == 'make_admin') {
                                      bloc.add(UpdatePrivilege(
                                          documentId: admin.documentID,
                                          callback: callback));
                                    } else if (value == 'make_super_admin') {
                                      bloc.add(UpdatePrivilege(
                                          documentId: admin.documentID,
                                          isSuperAdmin: true,
                                          callback: callback));
                                    } else if (value == 'delete') {
                                      bloc.add(DeleteAdmin(
                                          documentId: admin.documentID,
                                          callback: callback));
                                    }
                                  },
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: ColorShades.white,
                                    size: 32,
                                  ),
                                  itemBuilder: (context) {
                                    var list = List<PopupMenuEntry<Object>>();

                                    list.add(
                                      PopupMenuItem(
                                        value: admin[KeyNames['superAdmin']]
                                            ? 'make_admin'
                                            : 'make_super_admin',
                                        child: FlatButton.icon(
                                            onPressed: null,
                                            icon: Icon(
                                              Icons.settings,
                                              color: ColorShades.greenBg,
                                              size: 16,
                                            ),
                                            label: Text(
                                              L10n().getStr(admin[
                                                      KeyNames['superAdmin']]
                                                  ? 'manageUser.makeAdmin'
                                                  : 'manageUser.makeSuperAdmin'),
                                              style: theme
                                                  .textTheme.body2Regular
                                                  .copyWith(
                                                      color:
                                                          ColorShades.greenBg),
                                            )),
                                      ),
                                    );
                                    list.add(
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: FlatButton.icon(
                                            onPressed: null,
                                            icon: Icon(
                                              Icons.delete,
                                              color: ColorShades.greenBg,
                                              size: 16,
                                            ),
                                            label: Text(
                                              L10n()
                                                  .getStr('manageUser.delete'),
                                              style: theme
                                                  .textTheme.body2Regular
                                                  .copyWith(
                                                      color:
                                                          ColorShades.greenBg),
                                            )),
                                      ),
                                    );
                                    return list;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return Container();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, Constants.ADD_ADMIN).then((_) {
              BlocProvider.of<UserDatabaseBloc>(context).add(FetchAllAdmins());
            });
          },
          child: Icon(
            Icons.add,
            color: ColorShades.white,
          ),
          backgroundColor: ColorShades.greenBg,
        ),
      ),
    );
  }
}
