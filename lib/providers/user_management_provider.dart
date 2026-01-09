import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../domain/entities/user.dart';

class UserManagementProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  UserManagementProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _roleFilter;
  String? _departmentFilter;
  String? _companyFilter;
  String? _statusFilter;
  String _searchQuery = '';

  // Getters
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get roleFilter => _roleFilter;
  String? get departmentFilter => _departmentFilter;
  String? get companyFilter => _companyFilter;
  String? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;

  // Filtered users
  List<User> get filteredUsers {
    var filtered = _users;

    // Apply role filter
    if (_roleFilter != null) {
      filtered = filtered.where((u) => u.role.toString().split('.').last == _roleFilter).toList();
    }

    // Apply department filter
    if (_departmentFilter != null) {
      filtered = filtered.where((u) => u.departmentId == _departmentFilter).toList();
    }

    // Apply company filter
    if (_companyFilter != null) {
      filtered = filtered.where((u) => u.companyId == _companyFilter).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((u) => u.status.toString().split('.').last == _statusFilter).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((u) {
        return u.firstName.toLowerCase().contains(query) ||
            u.lastName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Set filters
  void setRoleFilter(String? role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setDepartmentFilter(String? departmentId) {
    _departmentFilter = departmentId;
    notifyListeners();
  }

  void setCompanyFilter(String? companyId) {
    _companyFilter = companyId;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _roleFilter = null;
    _departmentFilter = null;
    _companyFilter = null;
    _statusFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadUsers({
    String? organizationId,
    String? companyId,
    String? departmentId,
    String? role,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final queryParams = <String>[];
      if (organizationId != null) queryParams.add('organizationId=$organizationId');
      if (companyId != null) queryParams.add('companyId=$companyId');
      if (departmentId != null) queryParams.add('departmentId=$departmentId');
      if (role != null) queryParams.add('role=$role');
      
      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiClient.get('/admin/users$query');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _users = (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        _error = response.data['error'] ?? 'Failed to load users';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Load users error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    required String organizationId,
    String? companyId,
    String? departmentId,
    String? managerId,
    String? jobTitle,
    String? employmentType,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.post('/admin/users', data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'organizationId': organizationId,
        'companyId': companyId,
        'departmentId': departmentId,
        'managerId': managerId,
        'jobTitle': jobTitle,
        'employmentType': employmentType,
        'password': 'TempPassword123!', // Temporary password
      });

      if (response.data['success'] == true) {
        await loadUsers(organizationId: organizationId);
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to create user';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Create user error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put('/admin/users/$userId', data: updates);

      if (response.data['success'] == true) {
        // Update local user
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          final updatedUser = User.fromJson(response.data['data']['user']);
          _users[index] = updatedUser;
          notifyListeners();
        }
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update user';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Update user error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put('/admin/users/$userId/role', data: {
        'role': newRole,
      });

      if (response.data['success'] == true) {
        // Update local user
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          final updatedUser = User.fromJson(response.data['data']['user']);
          _users[index] = updatedUser;
          notifyListeners();
        }
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update user role';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Update user role error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleUserStatus(String userId, bool activate) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.put('/admin/users/$userId', data: {
        'status': activate ? 'active' : 'inactive',
      });

      if (response.data['success'] == true) {
        // Update local user
        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          final updatedUser = User.fromJson(response.data['data']['user']);
          _users[index] = updatedUser;
          notifyListeners();
        }
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to update user status';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Toggle user status error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _apiClient.delete('/admin/users/$userId');

      if (response.data['success'] == true) {
        _users.removeWhere((u) => u.id == userId);
        notifyListeners();
        return true;
      } else {
        _error = response.data['error'] ?? 'Failed to delete user';
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Delete user error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
