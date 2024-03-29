import 'package:asia_bazar_seller/blocs/global_bloc/events.dart';
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/repository/global_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalBloc extends Bloc<GlobalEvents, Map> {
  @override
  Map get initialState => GlobalState.globalState;
  GlobalRepo _globalRepo = GlobalRepo();
  @override
  Stream<Map> mapEventToState(GlobalEvents event) async* {
    if (event is FetchSellerInfo) {
      if (state['sellerInfo'] is! InfoFetchedState) {
        state['sellerInfo'] = GlobalFetchingState();
        yield {...state};
        var info = await _globalRepo.fetchSellerInfo();
        if (event.callback != null) {
          event.callback(info);
        }
        state['sellerInfo'] = InfoFetchedState(sellerInfo: info);
        yield {...state};
      } else {
        if (event.callback != null)
          event.callback(state['sellerInfo'].sellerInfo);
      }
    }
    if (event is UpdateSellerInfo) {
      var updated = await _globalRepo.updateSellerInfo(data: event.data);
      if (state['sellerInfo'] is InfoFetchedState) {
        var info = state['sellerInfo'].sellerInfo;
        info = {...info, ...event.data};
        state['sellerInfo'] = InfoFetchedState(sellerInfo: info);
        yield {...state};
      }
      if (event.callback != null) {
        event.callback(updated);
      }
    }
  }
}
