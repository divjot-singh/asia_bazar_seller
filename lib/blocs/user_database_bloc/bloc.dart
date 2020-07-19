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
    if (event is CheckIfAdmin) {
      var phoneNumber = await StorageManager.getItem(KeyNames['phone']);
      if (phoneNumber == null || phoneNumber.length == 0) {
        state['userstate'] = GlobalErrorState();
        yield {...state};
      } else {
        try {
          UserDatabaseState currentState =
              await userDatabaseRepo.checkIfAdmin(phoneNumber: phoneNumber);
          if (currentState == null) {
            state['userstate'] = GlobalErrorState();
            yield {...state};
          } else {
            state['userstate'] = currentState;
            yield {...state};
          }
        } catch (e) {
          state['userstate'] = GlobalErrorState();
          yield {...state};
        }
      }
    } else if (event is UpdateUsername) {
      var phone = await StorageManager.getItem(KeyNames['phone']);
      if (phone == null || phone.length == 0) {
        state['userstate'] = GlobalErrorState();
        yield {...state};
      } else {
        try {
          await userDatabaseRepo.updateUsername(
              phone: phone, username: event.username);

          var user = await userDatabaseRepo.getUser(phone: phone);
          state['userstate'] = UserIsAdmin(user: user);
          yield {...state};
          if (event.callback != null) {
            event.callback(true);
          }
        } catch (e) {
          if (event.callback != null) {
            event.callback(false);
          }
          state['userstate'] = GlobalErrorState();
          yield {...state};
        }
      }
    } else if (event is AddNewAdmin) {
      try {
        Map userData = {};
        userData[KeyNames['userName']] = event.username;
        userData[KeyNames['phone']] = event.phoneNumber;
        userData[KeyNames['superAdmin']] = event.isSuperAdmin;

        var value = await userDatabaseRepo.addNewAdmin(userData: userData);
        if (event.callback != null) event.callback(value);
      } catch (e) {
        print(e);
        if (event.callback != null) event.callback(false);
      }
    }
  }
}
