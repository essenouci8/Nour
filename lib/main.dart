import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_state.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.instance.load();
  await NotificationService.instance.init();
  runApp(const NourApp());
}
