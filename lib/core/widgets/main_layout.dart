import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/notification/presentation/providers/notification_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviders();
    });
  }

  void _initProviders() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      // Initialize chat provider to get unread count
      context.read<ChatProvider>().init(currentUser.id);
      // Initialize notification provider to get unread count
      context.read<NotificationProvider>().init(currentUser.id);
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/friends');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/watch');
        break;
      case 4:
        context.go('/marketplace');
        break;
      case 5:
        context.go('/notifications');
        break;
      case 6:
        context.go('/menu');
        break;
    }
  }

  Widget _buildBadgeIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    
    final unreadChatCount = chatProvider.totalUnreadCount;
    final unreadNotificationCount = notificationProvider.unreadCount;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Bạn bè',
          ),
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(Icons.chat_bubble, unreadChatCount),
            activeIcon: _buildBadgeIcon(Icons.chat_bubble, unreadChatCount),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video),
            label: 'Watch',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(Icons.notifications, unreadNotificationCount),
            activeIcon: _buildBadgeIcon(Icons.notifications, unreadNotificationCount),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
