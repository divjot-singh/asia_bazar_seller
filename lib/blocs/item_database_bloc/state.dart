import 'package:flutter/material.dart';

abstract class ItemDatabaseState {
  static Map itemState = {
    'categoryListing': ItemUninitialisedState(),
    'outOfStockListing': ItemUninitialisedState(),
    'allCategories': ItemUninitialisedState(),
    'itemDetails': ItemUninitialisedState(),
  };
}

class ItemUninitialisedState extends ItemDatabaseState {}

class AllCategoriesFetchedState {
  List categories;
  AllCategoriesFetchedState({@required this.categories});
}

class OutOfStockItemsFetched {
  List items;
  String categoryId;
  OutOfStockItemsFetched({@required this.items, @required this.categoryId});
}

class CategoryListingFetchedState {
  List categoryItems;
  String categoryId;
  bool showInputBox;
  CategoryListingFetchedState(
      {@required this.categoryItems, @required this.categoryId, this.showInputBox = false});
}

class SearchListingFetched {
  List searchItems;
  SearchListingFetched({@required this.searchItems});
}

class ItemDetailsFetchedState {
  Map itemDetails;
  String itemId;
  ItemDetailsFetchedState({@required this.itemId, @required this.itemDetails});
}

class PartialFetchingState {
  List categoryItems;
  String categoryId;
  PartialFetchingState({@required this.categoryItems, this.categoryId});
}

class OrdersListFetchedState extends ItemDatabaseState {
  List orderItems;
  String orderFilter;
  OrdersListFetchedState({this.orderFilter, @required this.orderItems});
}

class PartialOrderFetchingState {
  List orderItems;
  String orderFilter;
  PartialOrderFetchingState(
      {@required this.orderItems, @required this.orderFilter});
}
