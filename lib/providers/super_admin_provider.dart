import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../domain/entities/organization.dart';
import '../domain/entities/user.dart';

class SuperAdminProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  SuperAdminProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<Organization> _organizations = [];
  bool _isLoading = false;
  String? _error;

  // System analytics
  int _totalOrganizations = 0;
  int _totalUsers = 0;
  int _totalCompanies = 0;
  int _totalDepartments = 0;
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  double _diskUsage = 0;
  String _uptime = '';
  double _mrr = 0;
  double _arr = 0;
  double _growth = 0;

  // Getters
  List<Organization> get organizations => _organizations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrganizations => _totalOrganizations;
  int get totalUsers => _totalUsers;
  int get totalCompanies => _totalCompanies;
  int get totalDepartments => _totalDepartments;
  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  double get diskUsage => _diskUsage;
  String get uptime => _uptime;
  double get mrr => _mrr;
  double get arr => _arr;
  double get growth => _growth;

  Future<void> loadOrganizations() async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.get('/super-admin/organizations');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _organizations = (data['organizations'] as List)
            .map((json) => Organization.fromJson(json))
            .toList();
      } else {
        _error = response.data['error'] ?? 'Failed to load organizations';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load organizations error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createOrganization({
    required String name,
    String? description,
    String? website,
    String? industry,
    required String size,
    required String subscriptionPlan,
    required int maxUsers,
    required int maxCompanies,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/super-admin/organizations', data: {
        'name': name,
        'description': description,
        'website': website,
        'industry': industry,
        'size': size,
        'subscriptionPlan': subscriptionPlan,
        'subscriptionStatus': 'active',
        'maxUsers': maxUsers,
        'maxCompanies': maxCompanies,
      });

      if (response.data['success'] == true) {
        await loadOrganizations();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to create organization';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Create organization error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateOrganization(String organizationId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put(
        '/super-admin/organizations/$organizationId',
        data: updates,
      );

      if (response.data['success'] == true) {
        await loadOrganizations();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update organization';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Update organization error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteOrganization(String organizationId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.delete('/super-admin/organizations/$organizationId');

      if (response.data['success'] == true) {
        await loadOrganizations();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to delete organization';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Delete organization error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSystemAnalytics() async {
    try {
      final response = await _apiClient.get('/super-admin/analytics');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _totalOrganizations = data['totalOrganizations'] ?? 0;
        _totalUsers = data['totalUsers'] ?? 0;
        _totalCompanies = data['totalCompanies'] ?? 0;
        _totalDepartments = data['totalDepartments'] ?? 0;

        final health = data['systemHealth'] ?? {};
        _cpuUsage = (health['cpuUsage'] ?? 0).toDouble();
        _memoryUsage = (health['memoryUsage'] ?? 0).toDouble();
        _diskUsage = (health['diskUsage'] ?? 0).toDouble();
        _uptime = health['uptime'] ?? '';

        final revenue = data['revenueMetrics'] ?? {};
        _mrr = (revenue['mrr'] ?? 0).toDouble();
        _arr = (revenue['arr'] ?? 0).toDouble();
        _growth = (revenue['growth'] ?? 0).toDouble();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load system analytics error: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
