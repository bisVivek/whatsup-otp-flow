import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/dashboard.dart';

class DashboardRepository {
  DashboardRepository(this._api);

  final ApiClient _api;

  Future<Dashboard> fetch() async {
    final json = await _api.get('/dashboard');
    return Dashboard.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<bool> setNotifyLaunch(bool value) async {
    final json = value
        ? await _api.post('/launch-notification')
        : await _api.delete('/launch-notification');
    return json['notify_launch'] as bool? ?? value;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);
