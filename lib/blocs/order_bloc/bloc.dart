import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/event.dart';
import 'package:asia_bazar_seller/blocs/order_bloc/state.dart';
import 'package:asia_bazar_seller/repository/order_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsBloc extends Bloc<OrderEvent, Map> {
  @override
  Map get initialState => OrderState.orderState;

  OrderDatabaseRepo orderRepo = OrderDatabaseRepo();

  @override
  Stream<Map> mapEventToState(OrderEvent event) async* {
    if (event is FetchOrderDetails) {
      state['orderState'] = GlobalFetchingState();
      yield {...state};
      try {
        var order = await orderRepo.fetchOrderDetails(orderId: event.orderId);
        if (order == null) {
          state['orderState'] = GlobalErrorState();
        } else {
          state['orderState'] = OrderFetchedState(
              orderDetails: order.data, documentId: order.documentID);
        }
      } catch (e) {
        state['orderState'] = GlobalErrorState();
      }
      yield {...state};
    } else if (event is FetchOrderItems) {
      state['itemState'] = GlobalFetchingState();
      yield {...state};
      try {
        var items = await orderRepo.fetchOrderItems(orderId: event.orderId);
        if (items == null) {
          state['itemState'] = GlobalErrorState();
        } else {
          state['itemState'] =
              ItemFetchedState(orderId: event.orderId, orderItems: items);
        }
        if (event.callback != null) {
          event.callback(items);
        }
      } catch (e) {
        state['itemState'] = GlobalErrorState();
      }
      yield {...state};
    } else if (event is UpdateOrderStatus) {
      try {
        await orderRepo.updateStatus(
            orderId: event.orderId,
            newStatus: event.newStatus,
            itemList: event.itemList,
            pointsDetails: event.pointsDetails);
        if (event.callback != null) event.callback(true);
      } catch (e) {
        if (event.callback != null) event.callback(false);
        print(e);
      }
    }
  }
}
