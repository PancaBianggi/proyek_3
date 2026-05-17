import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/search_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'utils/page_transition.dart';

void main() {
  runApp(const VHGHApp());
}

class VHGHApp extends StatelessWidget {
  const VHGHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VHGH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0A1F),
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) => const SplashScreen());
          case '/auth':
            page = const AuthChoiceScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/search':
            page = const SearchScreen();
            break;
          case '/cart':
            page = const CartScreen();
            break;
          case '/checkout':
            page = const CheckoutScreen();
            break;
          case '/order-success':
            page = const OrderSuccessScreen();
            break;
          case '/orders':
            page = const OrdersScreen();
            break;
          case '/order-detail':
            page = OrderDetailScreen();
            break;
          case '/profile':
            page = const ProfileScreen();
            break;
          case '/edit-profile':
            page = const EditProfileScreen();
            break;
          case '/wishlist':
            page = const WishlistScreen();
            break;
          case '/chatbot':
            // Chatbot dari bawah (bottom sheet feel)
            return SlideTransitionPage(
              page: const ChatbotScreen(),
              direction: SlideDirection.fromBottom,
            );
          default:
            page = const HomeScreen();
        }

        return SlideTransitionPage(page: page);
      },
    );
  }
}