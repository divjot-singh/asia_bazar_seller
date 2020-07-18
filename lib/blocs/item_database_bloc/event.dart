import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class ItemDatabaseEvents {}

class FetchAllCategories extends ItemDatabaseEvents {}

class FetchCategoryListing extends ItemDatabaseEvents {
  String categoryId;
  DocumentSnapshot startAt;
  Function callback;
  FetchCategoryListing(
      {@required this.categoryId, this.startAt, this.callback});
}

class FetchOutOfStockItems extends ItemDatabaseEvents {
  String categoryId;
  Function callback;
  FetchOutOfStockItems({@required this.categoryId, this.callback});
}

class SearchCategoryItem extends ItemDatabaseEvents {
  String query, categoryId;
  String startAt;
  Function callback;
  SearchCategoryItem(
      {@required this.query,
      @required this.categoryId,
      this.startAt,
      this.callback});
}

class GetItemDetails extends ItemDatabaseEvents {
  String itemId, categoryId;
  GetItemDetails({@required this.itemId, this.categoryId});
}

class RemoveItem extends ItemDatabaseEvents {
  String categoryId, itemId;
  Function callback;
  RemoveItem({@required this.categoryId, @required this.itemId, this.callback});
}

class FetchOrdersFiltered extends ItemDatabaseEvents {
  String filter;
  DocumentSnapshot startAt;
  Function callback;
  String searchQuery;
  FetchOrdersFiltered(
      {this.callback, this.filter, this.startAt, this.searchQuery});
}
