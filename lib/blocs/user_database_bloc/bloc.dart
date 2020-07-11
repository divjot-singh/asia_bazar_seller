import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/user_database_bloc/state.dart';
import 'package:asia_bazar_seller/repository/item_database.dart';
import 'package:asia_bazar_seller/repository/user_database.dart';
import 'package:asia_bazar_seller/utils/constants.dart';
import 'package:asia_bazar_seller/utils/storage_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDatabaseBloc extends Bloc<UserDatabaseEvents, Map> {
  @override
  Map get initialState => UserDatabaseState.userstate;
  UserDatabase userDatabaseRepo = UserDatabase();
  ItemDatabase itemDatabaseRepo = ItemDatabase();
  @override
  Stream<Map> mapEventToState(UserDatabaseEvents event) async* {
    if (event is CheckIfAdminOrUser) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          UserDatabaseState currentState =
              await userDatabaseRepo.checkIfAdminOrUser(userId: userId);
          if (currentState == null) {
            state['userstate'] = ErrorState();
            yield {...state};
          } else {
            state['userstate'] = currentState;
            yield {...state};
          }
        } catch (e) {
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is AddUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.addAddress(
              userId: userId, address: event.address);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);

          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is OnboardUser) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.onboardUser(
              userId: userId, address: event.address, username: event.username);

          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is UpdateUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.updateAddress(
              userId: userId,
              address: event.address,
              timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is DeleteUserAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.deleteAddress(
              userId: userId, timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is SetDefaultAddress) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.setDefault(
              userId: userId, timestamp: event.timestamp);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is UpdateUsername) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.updateUsername(
              userId: userId, username: event.username);
          if (event.callback != null) {
            event.callback(true);
          }
          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is AddItemToCart) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          var status = await userDatabaseRepo.addItemToCart(
              userId: userId, item: event.item);
          if (status == true) {
            var user = await userDatabaseRepo.getUser(userId: userId);
            state['userstate'] = UserIsUser(user: user);
            yield {...state};
            if (event.callback != null) {
              event.callback(true);
            }
          } else {
            event.callback(status);
          }
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is RemoveCartItem) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.removeCartItem(
              userId: userId, itemId: event.itemId);

          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
          if (event.callback != null) {
            event.callback(true);
          }
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is EmptyCart) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (userId == null || userId.length == 0) {
        state['userstate'] = ErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.emptyCart(userId: userId);

          var user = await userDatabaseRepo.getUser(userId: userId);
          state['userstate'] = UserIsUser(user: user);
          yield {...state};
          if (event.callback != null) {
            event.callback(true);
          }
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = ErrorState();
          yield {...state};
        }
      }
    } else if (event is FetchCartItems) {
      var currentUser =
          state['userstate'] is UserIsUser ? state['userstate'].user : null;
      state['userstate'] = GlobalFetchingState();
      yield {...state};
      if (currentUser == null) {
        var userId = await StorageManager.getItem(KeyNames['userId']);
        currentUser = await userDatabaseRepo.getUser(userId: userId);
      }
      var cart = currentUser['cart'] != null ? currentUser['cart'] : {};
      var items = await itemDatabaseRepo.fetchCartItems(cartKeys: cart);
      if (items != null && event.callback != null) {
        event.callback(items);
        state['userstate'] = UserIsUser(user: currentUser);
        yield {...state};
      } else {
        state['userstate'] = GlobalErrorState();
        yield {...state};
      }
    } else if (event is FetchMyOrders) {
      var userId = await StorageManager.getItem(KeyNames['userId']);
      if (event.startAt == null) {
        state['ordersstate'] = GlobalFetchingState();
        yield {...state};
      }
      var orderItems;
      try {
        orderItems = await itemDatabaseRepo.fetchMyOrders(
            userId: userId, startAt: event.startAt);
        if (orderItems is List) {
          var ordersListing = [];
          if (event.startAt != null &&
              state['ordersstate'] is OrdersFetchedState) {
            var listing = state['ordersstate'].orders;
            ordersListing.addAll(listing);
          }
          ordersListing.addAll(orderItems);
          state['ordersstate'] = OrdersFetchedState(orders: ordersListing);

          yield {...state};
          if (event.callback != null) {
            event.callback(orderItems);
          }
        } else {
          state['ordersstate'] = GlobalErrorState();
          yield {...state};
        }
      } catch (e) {
        print(e);
        state['ordersstate'] = GlobalErrorState();
        yield {...state};
      }
      if (event.callback != null) {
        event.callback(orderItems);
      }
    }
  }
}
