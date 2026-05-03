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
      routes: {
        '/':         (context) => const SplashScreen(),
        '/auth':     (context) => const AuthChoiceScreen(),
        '/login':    (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home':     (context) => const HomeScreen(),
        '/cart':     (context) => const CartScreen(),
        '/checkout':      (context) => const CheckoutScreen(),
        '/order-success': (context) => const OrderSuccessScreen(),
        '/orders':        (context) => const OrdersScreen(),
        '/profile':       (context) => const ProfileScreen(),
        '/wishlist':      (context) => const WishlistScreen(),
        '/chatbot':       (context) => const ChatbotScreen(),
        '/search':        (context) => const SearchScreen(),
      },
    );
  }
}