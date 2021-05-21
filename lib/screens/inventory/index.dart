import 'package:asia_bazar_seller/blocs/global_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/app_drawer.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Inventory extends StatefulWidget {
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  ThemeData theme;
  @override
  void initState() {
    BlocProvider.of<ItemDatabaseBloc>(context).add(FetchAllCategories());
    BlocProvider.of<GlobalBloc>(context).add(FetchSellerInfo());
    super.initState();
  }

  Widget categoryGrid({@required List listing}) {
    return Expanded(
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        itemCount: listing.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          var item = listing[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                  context,
                  Constants.CATEGORY_LISTING
                      .replaceAll(':categoryId', item['id'].toString())
                      .replaceAll(':categoryName', item['name']));
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: Spacing.space12, vertical: Spacing.space8),
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.contain,
                    image: NetworkImage(item['thumb_url'].toString())),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: ColorShades.white.withOpacity(0.7),
                child: Center(
                    child: Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.greenBg),
                )),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        drawer: AppDrawer(),
        appBar: MyAppBar(
          hasTransparentBackground: true,
          title: L10n().getStr('drawer.inventory'),
        ),
        body: Container(
          child: BlocBuilder<ItemDatabaseBloc, Map>(builder: (context, state) {
            var currentState = state['allCategories'];
            if (currentState is GlobalFetchingState) {
              return PageFetchingViewWithLightBg();
            } else if (currentState is GlobalErrorState) {
              return PageErrorView();
            } else if (currentState is AllCategoriesFetchedState) {
              var listing = currentState.categories;

              return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Spacing.space16, vertical: Spacing.space20),
                child: Column(
                  children: <Widget>[
                    Text(
                      L10n().getStr('home.shopByCategory'),
                      style: theme.textTheme.h4
                          .copyWith(color: ColorShades.greenBg),
                    ),
                    SizedBox(
                      height: Spacing.space20,
                    ),
                    categoryGrid(listing: listing),
                  ],
                ),
              );
            }
            return Container();
          }),
        ),
      ),
    );
  }
}
