import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/services/local_notification_service.dart';
import 'features/notifications/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Warm cream background + dark status icons for readability.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await LocalNotificationService.instance.initialize(
    onTap: () {
      AmaanoBookVerseApp.navigatorKey.currentState?.pushNamed(
        NotificationsScreen.routeName,
      );
    },
  );

  runApp(const AmaanoBookVerseApp());
}
