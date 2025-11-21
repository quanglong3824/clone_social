import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  
  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({NotificationRepository? notificationRepository}) 
      : _notificationRepository = notificationRepository ?? NotificationRepositoryImpl();

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String userId) {
    _setLoading(true);
    _notificationRepository.getNotifications(userId).listen((notifications) {
      _notifications = notifications;
      _setLoading(false);
    }, onError: (e) {
      _setError(e.toString());
    });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationRepository.markAsRead(userId, notificationId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationRepository.markAllAsRead(userId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(userId, notificationId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _error = error;
    notifyListeners();
  }
}
