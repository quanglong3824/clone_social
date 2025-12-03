import 'package:go_router/go_router.dart';
import '../widgets/main_layout.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/post/presentation/pages/home_page.dart';
import '../../features/post/presentation/pages/create_post_page.dart';
import '../../features/post/presentation/pages/post_detail_page.dart';
import '../../features/friend/presentation/pages/friends_page.dart';
import '../../features/friend/presentation/pages/search_users_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/watch/presentation/pages/watch_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/marketplace/presentation/pages/create_product_page.dart';
import '../../features/marketplace/presentation/pages/product_detail_page.dart';
import '../../features/marketplace/presentation/pages/my_products_page.dart';
import '../../features/marketplace/presentation/pages/saved_products_page.dart';
import '../../features/marketplace/presentation/pages/search_products_page.dart';
import '../../features/menu/presentation/pages/menu_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isOnSplash = state.matchedLocation == '/splash';
        final isOnAuth = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register' ||
                        state.matchedLocation == '/forgot-password';

        // If on splash, redirect based on auth status
        if (isOnSplash) {
          return isAuthenticated ? '/' : '/login';
        }

        // If authenticated and on auth pages, redirect to home
        if (isAuthenticated && isOnAuth) {
          return '/';
        }

        // If not authenticated and trying to access protected pages
        if (!isAuthenticated && !isOnAuth && !isOnSplash) {
          return '/login';
        }

        return null; // No redirect needed
      },
      routes: [
      // Splash & Auth Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Main App Routes with Bottom Navigation
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainLayout(
          currentIndex: 0,
          child: HomePage(),
        ),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/profile/:userId',
        name: 'profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfilePage(userId: userId);
        },
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const MainLayout(
          currentIndex: 1,
          child: FriendsPage(),
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat-list',
        builder: (context, state) => const MainLayout(
          currentIndex: 2,
          child: ChatListPage(),
        ),
      ),
      GoRoute(
        path: '/watch',
        name: 'watch',
        builder: (context, state) => const MainLayout(
          currentIndex: 3,
          child: WatchPage(),
        ),
      ),
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        builder: (context, state) => const MainLayout(
          currentIndex: 4,
          child: MarketplacePage(),
        ),
      ),
      GoRoute(
        path: '/marketplace/create',
        name: 'create-product',
        builder: (context, state) => const CreateProductPage(),
      ),
      GoRoute(
        path: '/marketplace/product/:productId',
        name: 'product-detail',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/marketplace/my-products',
        name: 'my-products',
        builder: (context, state) => const MyProductsPage(),
      ),
      GoRoute(
        path: '/marketplace/saved',
        name: 'saved-products',
        builder: (context, state) => const SavedProductsPage(),
      ),
      GoRoute(
        path: '/marketplace/search',
        name: 'search-products',
        builder: (context, state) => const SearchProductsPage(),
      ),
      GoRoute(
        path: '/search-users',
        name: 'search-users',
        builder: (context, state) => const SearchUsersPage(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat-detail',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ChatDetailPage(
            chatId: chatId,
            otherUserName: extra?['otherUserName'],
            otherUserImage: extra?['otherUserImage'],
            otherUserId: extra?['otherUserId'],
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const MainLayout(
          currentIndex: 5,
          child: NotificationPage(),
        ),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) => const MainLayout(
          currentIndex: 6,
          child: MenuPage(),
        ),
      ),
      GoRoute(
        path: '/post/:postId',
        name: 'post-detail',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailPage(postId: postId);
        },
      ),
    ],
    );
  }
}
