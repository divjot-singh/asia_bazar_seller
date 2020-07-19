import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Drawer(
      child: BlocBuilder<UserDatabaseBloc, Map>(
        builder: (context, currentState) {
          Map user;
          if (currentState['userstate'] is UserIsAdmin) {
            user = currentState['userstate'].user;
          }
          String username = user != null ? user[KeyNames['userName']] : '';
          return Container(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: ColorShades.greenBg, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/home_logo.png',
                        height: 70,
                        width: 70,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, Constants.EDIT_PROFILE);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                L10n().getStr(
                                  'drawer.hi',
                                  {'name': username},
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.h3
                                    .copyWith(color: ColorShades.greenBg),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: ColorShades.greenBg,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Spacing.space12,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Constants.HOME, (route) => false);
                  },
                  leading: Icon(Icons.home, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'home.title',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                ListTile(
                  onTap: () {
                    Navigator.popAndPushNamed(context, Constants.INVENTORY);
                  },
                  leading: Icon(Icons.list, color: ColorShades.greenBg),
                  title: Text(
                      L10n().getStr(
                        'drawer.inventory',
                      ),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg)),
                ),
                if (user['isSuperAdmin'])
                  ListTile(
                    onTap: () {
                      Navigator.popAndPushNamed(context, Constants.ADD_ADMIN);
                    },
                    leading: Icon(Icons.person_add, color: ColorShades.greenBg),
                    title: Text(
                        L10n().getStr(
                          'drawer.addUser',
                        ),
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.greenBg)),
                  ),
                Divider(
                  color: ColorShades.greenBg,
                  thickness: 1,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.only(bottom: Spacing.space24),
                      child: ListTile(
                        onTap: () {
                          Utilities.logout(context);
                        },
                        leading: Padding(
                          padding:
                              EdgeInsets.only(left: Spacing.space8, top: 6),
                          child: SvgPicture.asset(
                            'assets/images/logout.svg',
                            color: ColorShades.greenBg,
                            height: 16,
                          ),
                        ),
                        title: Text(
                            L10n().getStr(
                              'drawer.logout',
                            ),
                            style: theme.textTheme.h3
                                .copyWith(color: ColorShades.greenBg)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
