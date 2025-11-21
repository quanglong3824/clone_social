import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/notification_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/themes/app_theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        context.read<NotificationProvider>().init(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead(currentUser.id);
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    context.read<NotificationProvider>().deleteNotification(
                          currentUser.id,
                          notification.id,
                        );
                  },
                  child: Container(
                    color: notification.read ? null : AppTheme.primaryBlue.withOpacity(0.1),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: notification.fromUserProfileImage != null
                            ? NetworkImage(notification.fromUserProfileImage!)
                            : null,
                        child: notification.fromUserProfileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: notification.fromUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' ${notification.title}'),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      onTap: () {
                        if (!notification.read) {
                          context.read<NotificationProvider>().markAsRead(
                                currentUser.id,
                                notification.id,
                              );
                        }
                        
                        // Navigate based on type
                        if (notification.postId != null) {
                          context.push('/post/${notification.postId}');
                        } else if (notification.type == 'friend_request') {
                          context.push('/friends');
                        } else if (notification.type == 'friend_accept') {
                          context.push('/profile/${notification.fromUserId}');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
