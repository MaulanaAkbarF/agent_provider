import 'package:agent/core/services/http_services/endpoints/all_services/all_list_service_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/all_services_model/list_services.dart';

class ListServicesListProvider extends ChangeNotifier {
  List<ListServicesData> _allServicesData = [];

  List<ListServicesData> get allServicesData => _allServicesData;
  
  Future<void> getListServicesData(BuildContext context, bool refresh) async {
    if (_allServicesData.isEmpty || refresh){
      if (refresh) {
        _allServicesData = [];
        notifyListeners();
      }
      final resp = await ListServicesHttp(context).getListServices();
      if (resp.isEmpty) return;
      _allServicesData = resp;
      notifyListeners();
    }
  }

  static ListServicesListProvider read(BuildContext context) => context.read();
  static ListServicesListProvider watch(BuildContext context) => context.watch();
}