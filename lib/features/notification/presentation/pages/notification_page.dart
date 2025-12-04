import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/notification_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/features/auth/domain/entities/user_entity.dart';
import 'package:clone_social/features/friend/presentation/providers/friend_provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/notification/domain/entities/notification_entity.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/animations/app_animations.dart';

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
          ? Center(
              child: SlideIn.fromBottom(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleIn(
                      child: Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: const Text(
                        'Chưa có thông báo nào',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return AnimatedListItem(
                  index: index,
                  child: Dismissible(
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
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      color: notification.read ? null : AppTheme.primaryBlue.withOpacity(0.1),
                      child: _buildNotificationTile(context, notification, currentUser),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


extension _NotificationPageHelpers on _NotificationPageState {
  Widget _buildNotificationTile(
    BuildContext context,
    NotificationEntity notification,
    UserEntity currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        color: notification.read ? null : AppTheme.primaryBlue.withOpacity(0.05),
        child: InkWell(
          onTap: () => _handleNotificationTap(context, notification, currentUser),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with icon overlay
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: notification.fromUserProfileImage != null
                          ? NetworkImage(notification.fromUserProfileImage!)
                          : null,
                      child: notification.fromUserProfileImage == null
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getNotificationColor(notification.type),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getNotificationIcon(notification.type),
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: notification.fromUserName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' ${notification.actionText}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),

                      // Action buttons for friend request
                      if (notification.type == 'friend_request' && !notification.read)
                        _buildFriendRequestActions(context, notification, currentUser),
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.read)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendRequestActions(
    BuildContext context,
    NotificationEntity notification,
    UserEntity currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _acceptFriendRequest(context, notification, currentUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Chấp nhận'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _rejectFriendRequest(context, notification, currentUser),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Từ chối'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptFriendRequest(
    BuildContext context,
    NotificationEntity notification,
    UserEntity currentUser,
  ) async {
    try {
      final friendProvider = context.read<FriendProvider>();
      
      // Use the new method that finds request by fromUserId
      await friendProvider.acceptFriendRequestByUserId(
        currentUser.id,
        notification.fromUserId,
      );

      // Mark notification as read
      if (context.mounted) {
        context.read<NotificationProvider>().markAsRead(currentUser.id, notification.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chấp nhận lời mời kết bạn từ ${notification.fromUserName}'),
            backgroundColor: AppTheme.success,
            action: SnackBarAction(
              label: 'Nhắn tin',
              textColor: Colors.white,
              onPressed: () async {
                final chatProvider = context.read<ChatProvider>();
                final chatId = await chatProvider.createChat(
                  currentUser.id,
                  notification.fromUserId,
                );
                if (chatId != null && context.mounted) {
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'otherUserName': notification.fromUserName,
                      'otherUserImage': notification.fromUserProfileImage,
                      'otherUserId': notification.fromUserId,
                    },
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Đi đến Lời mời',
              textColor: Colors.white,
              onPressed: () => context.push('/friends'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(
    BuildContext context,
    NotificationEntity notification,
    UserEntity currentUser,
  ) async {
    try {
      final friendProvider = context.read<FriendProvider>();
      
      // Use the new method that finds request by fromUserId
      await friendProvider.rejectFriendRequestByUserId(
        currentUser.id,
        notification.fromUserId,
      );

      if (context.mounted) {
        context.read<NotificationProvider>().deleteNotification(currentUser.id, notification.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã từ chối lời mời kết bạn'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Đi đến Lời mời',
              textColor: Colors.white,
              onPressed: () => context.push('/friends'),
            ),
          ),
        );
      }
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationEntity notification,
    UserEntity currentUser,
  ) {
    if (!notification.read) {
      context.read<NotificationProvider>().markAsRead(currentUser.id, notification.id);
    }

    switch (notification.type) {
      case 'friend_request':
        context.push('/friends');
        break;
      case 'friend_accept':
        context.push('/profile/${notification.fromUserId}');
        break;
      case 'like':
      case 'reaction':
      case 'comment':
      case 'share':
        if (notification.postId != null) {
          context.push('/post/${notification.postId}');
        }
        break;
      case 'message':
        // Navigate to chat - would need chatId
        break;
      default:
        if (notification.fromUserId.isNotEmpty) {
          context.push('/profile/${notification.fromUserId}');
        }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.thumb_up;
      case 'reaction':
        return Icons.emoji_emotions;
      case 'comment':
        return Icons.comment;
      case 'share':
        return Icons.share;
      case 'friend_request':
        return Icons.person_add;
      case 'friend_accept':
        return Icons.people;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'like':
        return AppTheme.primaryBlue;
      case 'reaction':
        return Colors.orange;
      case 'comment':
        return Colors.green;
      case 'share':
        return Colors.purple;
      case 'friend_request':
        return AppTheme.primaryBlue;
      case 'friend_accept':
        return AppTheme.success;
      case 'message':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
