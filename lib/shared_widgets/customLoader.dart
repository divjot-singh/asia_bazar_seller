import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:flutter/material.dart';

Future<void> showCustomLoader(BuildContext context, {String text}) {
  ThemeData theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext currentContext) {
      return Container(
        color: Colors.transparent.withOpacity(0.6),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TinyLoader(),
            if (text != null) SizedBox(height: Spacing.space12),
            if (text != null)
              Text(
                text,
                style: theme.textTheme.h3.copyWith(
                    color: ColorShades.white, decoration: TextDecoration.none),
              )
          ],
        ),
      );
    },
  );
}
