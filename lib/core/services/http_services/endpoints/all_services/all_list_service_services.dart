import 'package:agent/core/constant_values/_utlities_values.dart';
import 'package:agent/core/services/http_services/_global_url.dart';
import 'package:agent/core/services/http_services/http_connection.dart';

import '../../../../models/all_services_model/list_services.dart';

class ListServicesHttp extends HttpConnection {
  ListServicesHttp(super.context);

  Future<List<ListServicesData>> getListServices() async {
    ApiResponse? resp = await dioRequest(DioMethod.get, "${ApiService.getEndpoint()}/services");
    if ((resp != null) && resp.success) return resp.data.map<ListServicesData>((item) => ListServicesData.fromJson(item)).toList();
    return [];
  }

  Future<bool> activateServices(int serviceId) async {
    ApiResponse? resp = await dioRequest(DioMethod.post, "${ApiService.getEndpoint()}/services/registration/$serviceId");
    if ((resp != null) && resp.success) return true;
    return false;
  }
}