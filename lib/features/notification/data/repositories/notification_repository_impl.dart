import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/services/firebase_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseService _firebaseService;

  NotificationRepositoryImpl({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) {
    return _firebaseService.userNotificationsRef(userId).onValue.map((event) {
      final notifications = <NotificationEntity>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          notifications.add(_mapToNotificationEntity(key, Map<String, dynamic>.from(value), userId));
        });
      }
      // Sort by newest first
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firebaseService.userNotificationsRef(userId).child(notificationId).update({
      'read': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firebaseService.userNotificationsRef(userId).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final updates = <String, dynamic>{};
      data.forEach((key, value) {
        if (value['read'] == false) {
          updates['$key/read'] = true;
        }
      });
      if (updates.isNotEmpty) {
        await _firebaseService.userNotificationsRef(userId).update(updates);
      }
    }
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firebaseService.userNotificationsRef(userId).child(notificationId).remove();
  }

  NotificationEntity _mapToNotificationEntity(String id, Map<String, dynamic> data, String userId) {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: data['type'] ?? 'unknown',
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? 'Someone', // Note: Ideally fetch user name
      fromUserProfileImage: data['fromUserProfileImage'],
      postId: data['postId'],
      message: data['message'],
      read: data['read'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
    );
  }
}
