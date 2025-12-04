import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:clone_social/features/chat/presentation/providers/chat_provider.dart';
import 'package:clone_social/features/notification/presentation/providers/notification_provider.dart';
import 'package:clone_social/features/auth/presentation/providers/auth_provider.dart';
import 'package:clone_social/core/themes/app_theme.dart';
import 'package:clone_social/core/animations/app_animations.dart';

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

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppCurves.smooth,
    );
    _fadeController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviders();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
    if (index == widget.currentIndex) return;
    
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        currentIndex: widget.currentIndex,
        onTap: _onItemTapped,
        unreadChatCount: unreadChatCount,
        unreadNotificationCount: unreadNotificationCount,
        buildBadgeIcon: _buildBadgeIcon,
      ),
    );
  }
}

class _AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadChatCount;
  final int unreadNotificationCount;
  final Widget Function(IconData, int) buildBadgeIcon;

  const _AnimatedBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.unreadChatCount,
    required this.unreadNotificationCount,
    required this.buildBadgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Bạn bè',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Chat',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                badgeCount: unreadChatCount,
              ),
              _NavItem(
                icon: Icons.ondemand_video_outlined,
                activeIcon: Icons.ondemand_video,
                label: 'Watch',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label: 'Marketplace',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Thông báo',
                isSelected: currentIndex == 5,
                onTap: () => onTap(5),
                badgeCount: unreadNotificationCount,
              ),
              _NavItem(
                icon: Icons.menu,
                activeIcon: Icons.menu,
                label: 'Menu',
                isSelected: currentIndex == 6,
                onTap: () => onTap(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = AppTheme.primaryBlue;
    final unselectedColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: AppDurations.fast,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      widget.isSelected ? widget.activeIcon : widget.icon,
                      key: ValueKey(widget.isSelected),
                      color: widget.isSelected ? selectedColor : unselectedColor,
                      size: 24,
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: AppDurations.normal,
                        curve: AppCurves.spring,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? selectedColor : unselectedColor,
                ),
                child: Text(label.length > 8 ? '${label.substring(0, 7)}...' : label),
              ),
              AnimatedContainer(
                duration: AppDurations.fast,
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: widget.isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get label => widget.label;
}
