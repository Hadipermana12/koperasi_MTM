import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _api;

  NotificationProvider(this._api);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // GET /api/notifications
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/notifications');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      _notifications = data
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PATCH /api/notifications/:id/read
  Future<void> markAsRead(String id) async {
    try {
      await _api.patch('/notifications/$id/read');

      // Optimistic update — update local state immediately
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  // Mark all as read (local only — no bulk endpoint yet)
  void markAllAsReadLocally() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}
