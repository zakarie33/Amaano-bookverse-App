import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';import 'core/services/auth_service.dart';
import 'features/auth/screens/complete_profile_interests_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_tokens_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/verify_code_screen.dart';
import 'features/auth/screens/verify_method_screen.dart';
import 'features/audiobooks/screens/audio_player_screen.dart';
import 'features/audiobooks/screens/audiobooks_screen.dart';
import 'features/books/screens/book_details_screen.dart';
import 'features/books/screens/book_reader_screen.dart';
import 'features/books/screens/books_screen.dart';
import 'features/cart/cart_provider.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/cart/screens/checkout_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/library/screens/my_library_screen.dart';
import 'features/library/screens/my_purchases_screen.dart';
import 'core/widgets/notification_auth_bridge.dart';
import 'features/notifications/notification_provider.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/onboarding/screens/app_intro_onboarding_screen.dart';
import 'features/profile/screens/profile_activities_screen.dart';

class AmaanoBookVerseApp extends StatelessWidget {
  const AmaanoBookVerseApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => AuthService(apiService: context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              NotificationProvider(api: context.read<ApiService>()),
        ),
      ],
      child: NotificationAuthBridge(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Amaano BookVerse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            AppIntroOnboardingScreen.routeName: (_) =>
                const AppIntroOnboardingScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),
            CompleteProfileInterestsScreen.routeName: (_) =>
                const CompleteProfileInterestsScreen(),
            VerifyMethodScreen.routeName: (_) => const VerifyMethodScreen(),
            VerifyCodeScreen.routeName: (_) => const VerifyCodeScreen(),
            OnboardingTokensScreen.routeName: (_) =>
                const OnboardingTokensScreen(),
            HomeScreen.routeName: (_) => const HomeScreen(),
            BooksScreen.routeName: (_) => const BooksScreen(),
            AudiobooksScreen.routeName: (_) => const AudiobooksScreen(),
            BookDetailsScreen.routeName: (_) => const BookDetailsScreen(),
            BookReaderScreen.routeName: (_) => const BookReaderScreen(),
            AudioPlayerScreen.routeName: (_) => const AudioPlayerScreen(),
            CartScreen.routeName: (_) => const CartScreen(),
            CheckoutScreen.routeName: (_) => const CheckoutScreen(),
            NotificationsScreen.routeName: (_) => const NotificationsScreen(),
            MyLibraryScreen.routeName: (_) => const MyLibraryScreen(),
            MyPurchasesScreen.routeName: (_) => const MyPurchasesScreen(),
            ProfileActivitiesScreen.routeName: (_) =>
                const ProfileActivitiesScreen(),
          },
        ),
      ),
    );
  }
}
