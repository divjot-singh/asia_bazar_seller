import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/secondary_button.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/utilities.dart';
import 'package:flutter/material.dart';

class NotAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(Spacing.space16),
          decoration: BoxDecoration(gradient: Gradients.greenGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Colors.yellow,
                size: 150,
              ),
              SizedBox(
                height: Spacing.space32,
              ),
              Text(
                L10n().getStr('redirector.userNotAdmin'),
                textAlign: TextAlign.center,
                style: theme.textTheme.h2
                    .copyWith(color: theme.colorScheme.textPrimaryLight),
              ),
              SizedBox(
                height: Spacing.space16,
              ),
              Text(
                L10n().getStr('redirector.userNotAdmin.info'),
                textAlign: TextAlign.center,
                style: theme.textTheme.body1Medium
                    .copyWith(color: theme.colorScheme.textPrimaryLight),
              ),
              SizedBox(
                height: Spacing.space32,
              ),
              SecondaryButton(
                text: L10n().getStr('redirector.goBack'),
                onPressed: () {
                  Utilities.logout(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
