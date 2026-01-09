import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../domain/entities/organization.dart';
import '../domain/entities/company.dart';
import '../domain/entities/department.dart';

class OrganizationProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  OrganizationProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  Organization? _currentOrganization;
  List<Company> _companies = [];
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Organization? get currentOrganization => _currentOrganization;
  List<Company> get companies => _companies;
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCompanies({String? organizationId}) async {
    _setLoading(true);
    _error = null;

    try {
      final queryParams = organizationId != null ? '?organizationId=$organizationId' : '';
      final response = await _apiClient.get('/admin/companies$queryParams');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _companies = (data['companies'] as List)
            .map((json) => Company.fromJson(json))
            .toList();
      } else {
        _error = response.data['error'] ?? 'Failed to load companies';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load companies error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCompany({
    required String organizationId,
    required String name,
    String? description,
    String? location,
    String? industry,
    String? size,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/admin/companies', data: {
        'organizationId': organizationId,
        'name': name,
        'description': description,
        'location': location,
        'industry': industry,
        'size': size,
      });

      if (response.data['success'] == true) {
        await loadCompanies(organizationId: organizationId);
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to create company';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Create company error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCompany(String companyId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put('/admin/companies/$companyId', data: updates);

      if (response.data['success'] == true) {
        await loadCompanies();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update company';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Update company error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCompany(String companyId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.delete('/admin/companies/$companyId');

      if (response.data['success'] == true) {
        await loadCompanies();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to delete company';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Delete company error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDepartments({String? companyId, String? organizationId}) async {
    _setLoading(true);
    _error = null;

    try {
      final queryParams = <String>[];
      if (companyId != null) queryParams.add('companyId=$companyId');
      if (organizationId != null) queryParams.add('organizationId=$organizationId');
      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      
      final response = await _apiClient.get('/admin/departments$query');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _departments = (data['departments'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
      } else {
        _error = response.data['error'] ?? 'Failed to load departments';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load departments error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createDepartment({
    required String companyId,
    required String organizationId,
    required String name,
    String? description,
    String? managerId,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/admin/departments', data: {
        'companyId': companyId,
        'organizationId': organizationId,
        'name': name,
        'description': description,
        'managerId': managerId,
      });

      if (response.data['success'] == true) {
        await loadDepartments(companyId: companyId);
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to create department';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Create department error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDepartment(String departmentId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put('/admin/departments/$departmentId', data: updates);

      if (response.data['success'] == true) {
        await loadDepartments();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update department';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Update department error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDepartment(String departmentId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.delete('/admin/departments/$departmentId');

      if (response.data['success'] == true) {
        await loadDepartments();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to delete department';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Delete department error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
