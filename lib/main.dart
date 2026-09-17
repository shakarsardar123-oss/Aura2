import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'l10n/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/ai/ai_connection_storage.dart';
import 'core/ai/openai_provider.dart' hide openaiProviderProvider;
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/main_shell.dart';
import 'services/notifications/alarm_notification_service.dart';
import 'presentation/providers/alarm_providers.dart';
import 'core/alarm/wake_verification_service.dart';
import 'presentation/screens/wake_alarm_screen.dart';

/// Global navigator key for alarm notification tap navigation.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final secureStorage = const FlutterSecureStorage();
  final connectionStorage = AIConnectionStorage(
    secureStorage: secureStorage,
    sharedPreferences: prefs,
  );
  final openaiProvider = OpenAIProvider(
    secureStorage: secureStorage,
    connectionStorage: connectionStorage,
  );

  // Wire notification tap callback for alarm navigation.
  AlarmNotificationService.onActionCallback = (String payload) {
    if (payload.isNotEmpty) {
      final alarmListNotifier = _globalRef?.read(alarmListProvider.notifier);
      if (alarmListNotifier != null) {
        // Find alarm by ID from payload
        final alarms = _globalRef!.read(alarmListProvider);
        final alarm = alarms.where((a) => a.id == payload).firstOrNull;
        if (alarm != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => WakeAlarmScreen(alarm: alarm),
            ),
          );
        }
      }
    }
  };

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        flutterSecureStorageProvider.overrideWithValue(secureStorage),
        aiConnectionStorageProvider.overrideWithValue(connectionStorage),
        openaiProviderProvider.overrideWithValue(openaiProvider),
      ],
      child: const AuraApp(),
    ),
  );
}

/// Stored WidgetRef for alarm notification callback access.
WidgetRef? _globalRef;

/// AuraApp converted to StatefulWidget + WidgetsBindingObserver
/// to handle isolate bridge (pending_alarm_id) on app resume.
class AuraApp extends ConsumerStatefulWidget {
  const AuraApp({super.key});

  @override
  ConsumerState<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends ConsumerState<AuraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _globalRef = ref;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _globalRef = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Isolate bridge: check if a pending alarm ID was written
      // by the static _alarmCallback running in a separate isolate.
      final prefs = await SharedPreferences.getInstance();
      final pendingId = prefs.getString('pending_alarm_id');
      if (pendingId != null && pendingId.isNotEmpty) {
        // Clear the pending flag immediately.
        await prefs.remove('pending_alarm_id');

        // Find the alarm and trigger verification.
        final alarms = ref.read(alarmListProvider);
        final alarm = alarms.where((a) => a.id == pendingId).firstOrNull;
        if (alarm != null) {
          final wakeService = ref.read(wakeVerificationProvider);
          await wakeService.triggerAlarm(alarm);

          // Navigate to alarm screen.
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => WakeAlarmScreen(alarm: alarm),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(overriddenThemeProvider);
    final locale = ref.watch(overriddenLocaleProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode.toThemeMode(),
      locale: locale.toLocale(),
      supportedLocales: AuraLocale.values.map((l) => l.toLocale()),
      localizationsDelegates: S.localizationsDelegates,
      home: Directionality(
        textDirection: locale.textDirection,
        child: const MainShell(),
      ),
    );
  }
}
