import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/seed_data.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        children: [
          // User profile section
          if (currentUser != null)
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: currentUser.profileImage != null
                    ? NetworkImage(currentUser.profileImage!)
                    : null,
                child: currentUser.profileImage == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              title: Text(
                currentUser.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Xem trang cá nhân'),
              onTap: () {
                context.push('/profile/${currentUser.id}');
              },
            ),
          
          const Divider(height: 1),
          
          // Main menu items
          _buildMenuSection(
            'Tiện ích',
            [
              _MenuItem(
                icon: Icons.bookmark,
                title: 'Đã lưu',
                subtitle: 'Các bài viết đã lưu',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.group,
                title: 'Nhóm',
                subtitle: 'Các nhóm bạn tham gia',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.event,
                title: 'Sự kiện',
                subtitle: 'Sự kiện bạn quan tâm',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.photo_album,
                title: 'Kỷ niệm',
                subtitle: 'Xem lại những khoảnh khắc',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.pages,
                title: 'Trang',
                subtitle: 'Quản lý trang của bạn',
                onTap: () {},
              ),
            ],
          ),
          
          const Divider(height: 1),
          
          _buildMenuSection(
            'Developer Tools',
            [
              _MenuItem(
                icon: Icons.add_circle,
                title: 'Seed Sample Data',
                subtitle: 'Add 10+ sample users & posts',
                onTap: () => SeedData.seedAllData(context),
              ),
              _MenuItem(
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Delete all posts & chats',
                onTap: () => SeedData.clearAllData(context),
              ),
            ],
          ),
          
          const Divider(height: 1),
          
          _buildMenuSection(
            'Cài đặt & hỗ trợ',
            [
              _MenuItem(
                icon: Icons.settings,
                title: 'Cài đặt',
                subtitle: 'Cài đặt tài khoản',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.help,
                title: 'Trợ giúp & hỗ trợ',
                subtitle: 'Trung tâm trợ giúp',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.privacy_tip,
                title: 'Quyền riêng tư',
                subtitle: 'Kiểm tra quyền riêng tư',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.info,
                title: 'Giới thiệu',
                subtitle: 'Về ứng dụng',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
          
          const Divider(height: 1),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final shouldLogout = await _showLogoutDialog(context);
                if (shouldLogout == true) {
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            )),
      ],
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Facebook Clone',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.facebook, size: 48, color: Colors.blue),
      children: [
        const Text('Ứng dụng mạng xã hội clone Facebook'),
        const Text('Phát triển bởi Flutter & Firebase'),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
