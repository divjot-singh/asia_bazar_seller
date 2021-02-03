import 'package:asia_bazar_seller/utils/network_manager.dart';

class PaymentRepository {
  static Future<dynamic> voidTransaction({transactionId}) async {
    String url = 'apis/voidTransaction';
    Map<String, String> paymentData = {};
    paymentData['transactionId'] = transactionId;
    dynamic response = await NetworkManager.post(
        url: url, data: paymentData, sendCredentials: false);
    return response;
  }

  static Future<dynamic> sendRefundStatusNotification({refundData}) async {
    String url =
        'https://us-central1-asia-bazar-app.cloudfunctions.net/newApis/sendOrderRefundStatus';
    dynamic response = await NetworkManager.post(
        url: url,
        data: refundData,
        sendCredentials: false,
        isAbsoluteUrl: true);
    return response;
  }
}
