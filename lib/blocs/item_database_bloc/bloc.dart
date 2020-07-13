import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/item_database_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/repository/item_database.dart';
import 'package:asia_bazar_seller/repository/order_database.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemDatabaseBloc extends Bloc<ItemDatabaseEvents, Map> {
  @override
  Map get initialState => UserDatabaseState.userstate;
  ItemDatabase itemDatabase = ItemDatabase();
  OrderDatabaseRepo orderRepo = OrderDatabaseRepo();
  @override
  Stream<Map> mapEventToState(ItemDatabaseEvents event) async* {
    if (event is FetchAllCategories) {
      state['allCategories'] = GlobalFetchingState();
      yield {...state};
      try {
        var listing = await itemDatabase.fetchAllCategories();
        if (listing != null) {
          var allCategoryState = AllCategoriesFetchedState(categories: listing);
          state['allCategories'] = allCategoryState;
          yield {...state};
        } else {
          state['allCategories'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        state['allCategories'] = GlobalErrorState();
        yield {...state};
      }
    }
    if (event is FetchCategoryListing) {
      if (event.startAt == null) {
        state['categoryListing'] = GlobalFetchingState();
        yield {...state};
      }
      try {
        var listing = await itemDatabase.fetchCategoryListing(
            categoryId: event.categoryId, startAt: event.startAt);

        if (listing != null) {
          if (event.callback != null) {
            event.callback(listing);
          }
          var categoryListingState;
          var currentCategoryId = event.categoryId;
          if (event.startAt != null &&
              state['categoryListing'] is CategoryListingFetchedState &&
              state['categoryListing'].categoryId == currentCategoryId) {
            var newList = [];
            var oldListing = state['categoryListing'].categoryItems;
            newList.addAll(oldListing);
            newList.addAll(listing);
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: newList);
          } else {
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: listing);
          }
          state['categoryListing'] = categoryListingState;
          yield {...state};
        } else {
          state['categoryListing'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['categoryListing'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is SearchCategoryItem) {
      if (event.startAt == null) {
        var currentState = state['categoryListing'];
        if (currentState is CategoryListingFetchedState)
          state['categoryListing'] = PartialFetchingState(
              categoryId: currentState.categoryId,
              categoryItems: currentState.categoryItems);
        else
          state['categoryListing'] = GlobalFetchingState();
        yield {...state};
      }
      try {
        var listing = await itemDatabase.searchCategoryListing(
            categoryId: event.categoryId,
            startAt: event.startAt,
            query: event.query);

        if (listing != null) {
          if (event.callback != null) {
            event.callback(listing);
          }
          var categoryListingState;
          var currentCategoryId = event.categoryId;
          if (event.startAt != null &&
              state['categoryListing'] is CategoryListingFetchedState &&
              state['categoryListing'].categoryId == currentCategoryId) {
            var newList = [];
            var oldListing = state['categoryListing'].categoryItems;
            newList.addAll(oldListing);
            newList.addAll(listing);
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: newList);
          } else {
            categoryListingState = CategoryListingFetchedState(
                categoryId: event.categoryId, categoryItems: listing);
          }
          state['categoryListing'] = categoryListingState;
          yield {...state};
        } else {
          state['categoryListing'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['categoryListing'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is PlaceOrder) {
      var details = event.orderDetails;
      var userId = await StorageManager.getItem(KeyNames['userId']);

      itemDatabase.placeOrder(
          details: details, userId: userId, callback: event.callback);
    } else if (event is SearchAllItems) {
      if (event.startAt == null) {
        var currentState = state['searchListing'];
        if (currentState is CategoryListingFetchedState)
          state['searchListing'] =
              PartialFetchingState(categoryItems: currentState.categoryItems);
        else
          state['searchListing'] = GlobalFetchingState();
        yield {...state};
      }
      try {
        var listing = await itemDatabase.searchAllListing(
            startAt: event.startAt, query: event.query);

        if (listing != null) {
          if (event.callback != null) {
            event.callback(listing);
          }
          var searchListingState;
          if (event.startAt != null &&
              state['searchListing'] is SearchListingFetched) {
            var newList = [];
            var oldListing = state['searchListing'].searchItems;
            newList.addAll(oldListing);
            newList.addAll(listing);
            searchListingState = SearchListingFetched(searchItems: newList);
          } else {
            searchListingState = SearchListingFetched(searchItems: listing);
          }
          state['searchListing'] = searchListingState;
          yield {...state};
        } else {
          state['searchListing'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['categoryListing'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is FetchOrdersFiltered) {
      if (event.startAt == null &&
          (event.searchQuery == null ||
          event.searchQuery.length == 0)) {
        state['ordersListState'] = GlobalFetchingState();
        yield {...state};
      } else if (event.searchQuery != null &&
          event.searchQuery.length > 0 &&
          state['ordersListState'] is OrdersListFetchedState) {
        state['ordersListState'] = PartialOrderFetchingState(
            orderItems: state['ordersListState'].orderItems,
            orderFilter: state['ordersListState'].orderFilter);
        yield {...state};
      }
      try {
        var orderList = await orderRepo.fetchOrders(
            filter: event.filter,
            startAt: event.startAt,
            searchQuery: event.searchQuery);
        if (orderList != null) {
          if (event.callback != null) {
            event.callback(orderList);
          }
          var newList = [];
          if (event.startAt != null &&
              state['ordersListState'] is OrdersListFetchedState &&
              state['ordersListState'].orderFilter == event.filter) {
            var oldListing = state['ordersListState'].orderItems;
            newList.addAll(oldListing);
          }
          newList.addAll(orderList);
          state['ordersListState'] = OrdersListFetchedState(
              orderItems: newList, orderFilter: event.filter);
        } else {
          state['ordersListState'] = GlobalErrorState();
        }
      } catch (e) {
        state['ordersListState'] = GlobalErrorState();
      }
      yield {...state};
    }
  }
}
