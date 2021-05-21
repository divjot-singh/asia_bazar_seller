import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/bloc.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/l10n/l10n.dart';
import 'package:asia_bazar_seller/repository/user_database.dart';
import 'package:asia_bazar_seller/shared_widgets/app_bar.dart';
import 'package:asia_bazar_seller/shared_widgets/circular_list.dart';
import 'package:asia_bazar_seller/shared_widgets/customLoader.dart';
import 'package:asia_bazar_seller/shared_widgets/input_box.dart';
import 'package:asia_bazar_seller/shared_widgets/page_views.dart';
import 'package:asia_bazar_seller/shared_widgets/primary_button.dart';
import 'package:asia_bazar_seller/shared_widgets/snackbar.dart';
import 'package:asia_bazar_seller/theme/style.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/deboucer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_picker/flutter_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';

class CategoryListing extends StatefulWidget {
  final String categoryId, categoryName;
  CategoryListing({@required this.categoryId, @required this.categoryName});
  @override
  _CategoryListingState createState() => _CategoryListingState();
}

class _CategoryListingState extends State<CategoryListing> {
  ThemeData theme;
  ScrollController _scrollController = ScrollController();
  bool isFetching = false, showOverlay = false;
  Debouncer _debouncer = Debouncer();
  var searchQuery = '';
  var scrollHeight = 0;
  TextEditingController _textController = TextEditingController();
  bool showScrollUp = false;
  bool showOutOfStockItems = true;
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  @override
  void initState() {
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchOutOfStockItems(categoryId: widget.categoryId));

    _scrollController.addListener(scrollListener);

    super.initState();
  }

  Future<void> reloadAllItems() async {
    BlocProvider.of<ItemDatabaseBloc>(context)
        .add(FetchCategoryListing(categoryId: widget.categoryId));
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    _textController.dispose();
    _debouncer = null;
    super.dispose();
  }

  scrollListener() {
    setState(() {
      showScrollUp = _scrollController.position.pixels >
          MediaQuery.of(context).size.height;
    });

    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        isFetching != true) {
      _fetchMoreItems();
    }
  }

  searchItems(String query) {
    setState(() {
      showScrollUp = false;
    });
    query = query.toLowerCase();
    _debouncer.run(() {
      BlocProvider.of<ItemDatabaseBloc>(context)
          .add(SearchCategoryItem(query: query, categoryId: widget.categoryId));
    });
  }

  _fetchMoreItems() {
    var state =
        BlocProvider.of<ItemDatabaseBloc>(context).state['categoryListing'];
    if (state is CategoryListingFetchedState &&
        state.categoryId == widget.categoryId) {
      var listing = state.categoryItems;
      DocumentSnapshot lastItem = listing[listing.length - 1];
      if (_textController.text.length == 0) {
        BlocProvider.of<ItemDatabaseBloc>(context).add(FetchCategoryListing(
            callback: (listing) {
              setState(() {
                isFetching = false;
              });
              if (listing is List && listing.length == 0) {
                _scrollController.removeListener(scrollListener);
              }
            },
            categoryId: widget.categoryId,
            startAt: lastItem));
        setState(() {
          isFetching = true;
        });
      }
    }
  }

  Future<void> reloadPage() async {
    var route = Constants.CATEGORY_LISTING
        .replaceAll(':categoryId', widget.categoryId)
        .replaceAll(':categoryName', widget.categoryName);
    Navigator.popAndPushNamed(context, route);
  }

  Widget outOfStockItems(state) {
    var currentState = state['outOfStockListing'];
    if (currentState is GlobalFetchingState) {
      return PageFetchingViewWithLightBg();
    } else if (currentState is GlobalErrorState) {
      return PageErrorView();
    } else if (currentState is OutOfStockItemsFetched &&
        currentState.categoryId == widget.categoryId) {
      var items = currentState.items;
      return Scaffold(
        backgroundColor: ColorShades.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: Spacing.space20,
            ),
            Text(
              L10n().getStr('categoryListing.categoryType.outOfStock'),
              style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space20,
            ),
            items.length == 0
                ? emptyListing()
                : Expanded(
                    child: RefreshIndicator(
                      color: ColorShades.greenBg,
                      backgroundColor: ColorShades.smokeWhite,
                      onRefresh: reloadPage,
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index].data;
                          return listItem(
                              context: context,
                              item: item,
                              deleteHandler: () {
                                items.removeAt(index);
                                setState(() {});
                              });
                        },
                      ),
                    ),
                  ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: showScrollUp
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(0,
                      duration: Duration(
                        seconds: 1,
                      ),
                      curve: Curves.bounceOut);
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 24,
                  color: ColorShades.greenBg,
                ),
              )
            : null,
      );
    }
    return Container();
  }

  Widget emptyListing() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_list.png'),
          SizedBox(
            height: Spacing.space16,
          ),
          Text(
            L10n().getStr('list.empty'),
            textAlign: TextAlign.center,
            style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
          )
        ]);
  }

  Widget allItems(state) {
    var currentState = state['categoryListing'];
    if (currentState is GlobalFetchingState) {
      return PageFetchingViewWithLightBg();
    } else if (currentState is GlobalErrorState) {
      return PageErrorView();
    } else if (currentState is CategoryListingFetchedState &&
        currentState.categoryId == widget.categoryId) {
      var items = currentState.categoryItems;
      return Scaffold(
        backgroundColor: ColorShades.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: Spacing.space20,
            ),
            Text(
              L10n().getStr('categoryListing.categoryType.others'),
              style: theme.textTheme.h4.copyWith(color: ColorShades.greenBg),
            ),
            SizedBox(
              height: Spacing.space20,
            ),
            items.length == 0 && !currentState.showInputBox
                ? emptyListing()
                : Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: Spacing.space16),
                          child: InputBox(
                            controller: _textController,
                            onChanged: (query) {
                              searchQuery = query;
                              if (query.length > 2 || query.length == 0) {
                                searchItems(query);
                              }
                            },
                            suffixIcon: _textController.text.length > 0
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: ColorShades.greenBg,
                                    ),
                                    onPressed: () {
                                      searchItems('');
                                      _textController.text = '';
                                    },
                                  )
                                : null,
                            hideShadow: true,
                            hintText: L10n().getStr('category.search',
                                {'category': widget.categoryName}),
                            prefixIcon: Icon(
                              Icons.search,
                              color: ColorShades.greenBg,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Spacing.space16,
                        ),
                        items.length == 0
                            ? emptyListing()
                            : Expanded(
                                child: RefreshIndicator(
                                  color: ColorShades.greenBg,
                                  backgroundColor: ColorShades.smokeWhite,
                                  onRefresh: reloadAllItems,
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      var item = items[index].data();
                                      return listItem(
                                          context: context,
                                          item: item,
                                          deleteHandler: () {
                                            items.removeAt(index);
                                            setState(() {});
                                          });
                                    },
                                  ),
                                ),
                              ),
                        if (isFetching)
                          Padding(
                            padding: EdgeInsets.only(bottom: Spacing.space12),
                            child: ScalingText(L10n().getStr('app.loading'),
                                style: theme.textTheme.h3
                                    .copyWith(color: ColorShades.greenBg)),
                          ),
                      ],
                    ),
                  ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: showScrollUp
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(0,
                      duration: Duration(
                        seconds: 1,
                      ),
                      curve: Curves.bounceOut);
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 24,
                  color: ColorShades.greenBg,
                ),
              )
            : null,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorShades.white,
        appBar: MyAppBar(
          backGroundColor: Colors.black.withOpacity(0.3),
          hasTransparentBackground: !showOverlay,
          title: widget.categoryName,
        ),
        floatingActionButton: Builder(
          builder: (context) => FabCircularMenu(
              key: fabKey,
              // Cannot be `Alignment.center`
              alignment: Alignment.centerRight,
              fabSize: 64.0,
              startAngle: -45,
              range: 90,
              ringColor: ColorShades.greenBg.withOpacity(0.7),
              fabElevation: 8.0,
              fabColor: ColorShades.greenBg,
              fabOpenColor: ColorShades.white,
              fabOpenIcon: Icon(Icons.filter_list, color: ColorShades.white),
              fabCloseIcon: Icon(Icons.close, color: ColorShades.greenBg),
              animationCurve: Curves.easeInOutCirc,
              onDisplayChange: (isOpen) {
                setState(() {
                  showOverlay = isOpen;
                });
              },
              children: [
                GestureDetector(
                  onTap: () {
                    if (!showOutOfStockItems) {
                      setState(() {
                        showOutOfStockItems = true;
                        showOverlay = false;
                      });
                      _textController.text = '';
                    }
                    fabKey.currentState.close();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: Spacing.space16,
                          horizontal: Spacing.space12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: showOutOfStockItems
                              ? ColorShades.greenBg
                              : ColorShades.white,
                          border: Border.all(color: ColorShades.greenBg)),
                      child: Text(
                        L10n()
                            .getStr('categoryListing.categoryType.outOfStock'),
                        style: showOutOfStockItems
                            ? theme.textTheme.body1Bold
                                .copyWith(color: ColorShades.white)
                            : theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.greenBg),
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    if (showOutOfStockItems) {
                      setState(() {
                        showOutOfStockItems = false;
                        showOverlay = false;
                      });
                      reloadAllItems();
                    }
                    fabKey.currentState.close();
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: Spacing.space16,
                          horizontal: Spacing.space12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: !showOutOfStockItems
                              ? ColorShades.greenBg
                              : ColorShades.white,
                          border: Border.all(color: ColorShades.greenBg)),
                      child: Text(
                        L10n().getStr('categoryListing.categoryType.others'),
                        style: !showOutOfStockItems
                            ? theme.textTheme.body1Bold
                                .copyWith(color: ColorShades.white)
                            : theme.textTheme.body1Regular
                                .copyWith(color: ColorShades.greenBg),
                      )),
                ),
              ]),
        ),
        body: BlocBuilder<ItemDatabaseBloc, Map>(
          builder: (context, state) {
            return Stack(
              children: <Widget>[
                if (showOutOfStockItems)
                  outOfStockItems(state)
                else
                  allItems(state),
                showOverlay
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black.withOpacity(0.3),
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget listItem({
  @required BuildContext context,
  @required Map item,
  Function deleteHandler,
}) {
  ThemeData theme = Theme.of(context);
  var state = BlocProvider.of<UserDatabaseBloc>(context).state;
  bool isSuperAdmin = state['userstate'] is UserIsAdmin &&
      state['userstate'].user['isSuperAdmin'];
  bool outOfStock = item['quantity'] < 1;
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: Spacing.space16, vertical: Spacing.space4),
    child: Container(
      margin: EdgeInsets.only(
        bottom: Spacing.space8,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: Spacing.space16, vertical: Spacing.space12),
      decoration: BoxDecoration(
        color: ColorShades.white,
        boxShadow: [Shadows.cardLight],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          item['image_url'] != null
              ? FadeInImage.assetNetwork(
                  height: 100,
                  width: 100,
                  fit: BoxFit.fill,
                  placeholder: 'assets/images/loader.gif',
                  image: item['image_url'].replaceAll('http', 'https'),
                )
              : Image.asset(
                  'assets/images/image_unavailable.jpeg',
                  height: 100,
                  width: 100,
                ),
          // Image.network(
          //   item['image_url'] != null
          //       ? item['image_url']
          //       : 'https://dummyimage.com/600x400/ffffff/000000.png&text=Image+not+available',
          //   height: 100,
          //   width: 100,
          // ),
          SizedBox(
            width: Spacing.space12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item['description'],
                        style: theme.textTheme.h4
                            .copyWith(color: ColorShades.bastille),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSuperAdmin)
                      GestureDetector(
                        onTap: () {
                          showCustomLoader(context);
                          BlocProvider.of<ItemDatabaseBloc>(context)
                              .add(RemoveItem(
                                  categoryId: item['category_id'].toString(),
                                  itemId: item['item_id'].toString(),
                                  callback: (result) {
                                    Navigator.pop(context);
                                    if (result == false) {
                                      showCustomSnackbar(
                                        context: context,
                                        type: SnackbarType.error,
                                        content: L10n()
                                            .getStr('profile.address.error'),
                                      );
                                    } else {
                                      if (deleteHandler != null)
                                        deleteHandler();
                                    }
                                  }));
                        },
                        child: Icon(
                          Icons.delete,
                          color: ColorShades.redOrange,
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: Spacing.space4,
                ),
                Text(
                  item['dept_name'],
                  style: theme.textTheme.body1Regular
                      .copyWith(color: ColorShades.grey300),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: Spacing.space4,
                ),
                if (outOfStock)
                  Padding(
                    padding: EdgeInsets.only(top: Spacing.space8),
                    child: Text(
                      L10n().getStr('item.outOfStock'),
                      style: theme.textTheme.body1Regular.copyWith(
                          color: ColorShades.red, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        L10n().getStr('categoryListing.quantityAvailable') +
                            ": ",
                        style: theme.textTheme.body1Medium.copyWith(
                          color: ColorShades.bastille,
                        ),
                      ),
                      Text(
                        item['quantity'].toString(),
                        style: theme.textTheme.body1Regular.copyWith(
                          color: ColorShades.bastille,
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
