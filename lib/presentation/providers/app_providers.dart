
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/locale_provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/agent/agent_engine.dart';
import '../../core/agent/agent_context.dart';
import '../../core/ai/agent_engine_adapter.dart';
import '../../core/tools/tool_registry.dart';
import '../../core/memory/memory_database.dart';
import '../../core/memory/memory_repository_impl.dart';
import '../../data/datasources/local_storage_data_source.dart';
import '../../data/repositories/agent_config_repository_impl.dart';
import '../../data/repositories/app_config_repository_impl.dart';
import '../../domain/entities/agent_config.dart';
import '../../domain/repositories/agent_config_repository.dart';
import '../../domain/repositories/app_config_repository.dart';
import '../../services/ai/ai_provider.dart';
import 'dart:io' show Platform;
import '../../core/device/device_service_impl.dart';
import '../../core/device/device_channel.dart';
import '../../core/device/android_device_channel.dart';
import '../../core/device/stub_device_channel.dart';
import '../../core/tools/device/device_tools.dart';
import '../../core/tools/alarms/create_alarm_tool.dart';
import '../../core/tools/alarms/list_alarms_tool.dart';
import '../../core/tools/alarms/update_alarm_tool.dart';
import '../../core/tools/alarms/delete_alarm_tool.dart';
import '../../core/tools/alarms/set_alarm_tool.dart';
import '../../core/tools/vision/vision_tools.dart';
// ── Security providers ───────────────────────────────────────────
// core/security: ToolSecurityGate, confirmation guard (used by AgentEngine)
import '../../core/security/security_providers.dart';
// features/security: Secret scanner, redactor, logger, audit (R4 wiring)
import '../../features/security/presentation/security_providers.dart'
    show
        securitySecretScannerProvider,
        securitySensitiveDataRedactorProvider,
        securitySecureLoggerProvider,
        securityAuditServiceProvider;
import 'security_confirmation_provider.dart';
import 'alarm_tool_gateway_impl.dart' show alarmToolGatewayProvider;
import '../../services/camera/vision_camera_service.dart'
    show visionCameraServiceProvider;
import '../../presentation/providers/vision_providers.dart' show openaiVisionServiceProvider;
import '../../core/screen_capture/screen_capture_provider.dart'
    show
        screenCaptureServiceProvider,
        screenCaptureStateProvider,
        screenCaptureFrameStreamProvider,
        screenCaptureSupportedProvider;
import '../../core/floating_aura/floating_aura_provider.dart'
    show
        floatingAuraServiceProvider,
        floatingAuraSupportedProvider,
        floatingAuraStateProvider;
import '../../core/screen_understanding/screen_understanding_provider.dart'
    show
        screenUnderstandingServiceProvider,
        screenUnderstandingStateProvider;
import '../../core/ai/ai_connection_storage.dart';
import '../../core/screen_search/search_provider.dart'
    show screenSearchServiceProvider, screenSearchStateProvider;

// ─── Phase 1+2 Providers ────────────────────────────────────────────

/// Provider for [SharedPreferences]. Must be overridden in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

/// Provider for [LocalStorageDataSource].
final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource(ref.watch(sharedPreferencesProvider));
});

/// Provider for [AppConfigRepository].
final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
  return AppConfigRepositoryImpl(ref.watch(localStorageDataSourceProvider));
});

/// Provider for [AgentConfigRepository].
final agentConfigRepositoryProvider = Provider<AgentConfigRepository>((ref) {
  return AgentConfigRepositoryImpl();
});

/// Overridden theme provider wired to [SharedPreferences].
final overriddenThemeProvider = StateNotifierProvider<ThemeNotifier, AuraThemeMode>((ref) {
  return ThemeNotifier(ref.watch(sharedPreferencesProvider));
});

/// Overridden locale provider wired to [SharedPreferences].
final overriddenLocaleProvider = StateNotifierProvider<LocaleNotifier, AuraLocale>((ref) {
  return LocaleNotifier(ref.watch(sharedPreferencesProvider));
});

/// Resolves the [ThemeData] from the current [AuraThemeMode].
final themeDataProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(overriddenThemeProvider);
  switch (mode) {
    case AuraThemeMode.dark:
      return AppTheme.dark();
    case AuraThemeMode.light:
      return AppTheme.light();
    case AuraThemeMode.natural:
      return AppTheme.natural();
    case AuraThemeMode.system:
      return AppTheme.dark();
  }
});

// ─── Phase 3 Providers ──────────────────────────────────────────────

/// Provider for [FlutterSecureStorage]. Must be overridden in main.dart.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  throw UnimplementedError(
    'flutterSecureStorageProvider must be overridden in main.dart',
  );
});

/// Provider for [AIConnectionStorage]. Depends on
/// [flutterSecureStorageProvider] + [sharedPreferencesProvider].
/// Must be overridden in main.dart.
final aiConnectionStorageProvider = Provider<AIConnectionStorage>((ref) {
  throw UnimplementedError(
    'aiConnectionStorageProvider must be overridden in main.dart',
  );
});

/// Provider for [AIProvider] (OpenAI-compatible). Must be overridden in main.dart.
final openaiProviderProvider = Provider<AIProvider>((ref) {
  throw UnimplementedError(
    'openaiProviderProvider must be overridden in main.dart',
  );
});

/// Provider for [DeviceServiceImpl].
final deviceServiceProvider = Provider<DeviceServiceImpl>((ref) {
  return DeviceServiceImpl();
});

/// Stream provider for connectivity status.
final connectionStatusStreamProvider = StreamProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.onConnectivityChanged;
});

/// Provider for [MemoryDatabase].
final memoryDatabaseProvider = Provider<MemoryDatabase>((ref) {
  return MemoryDatabase();
});

/// Provider for [MemoryRepositoryImpl].
final memoryRepositoryProvider = Provider<MemoryRepositoryImpl>((ref) {
  return MemoryRepositoryImpl(database: ref.watch(memoryDatabaseProvider));
});

/// Provider for default [AgentConfig] entity.
final agentConfigEntityProvider = FutureProvider<AgentConfig>((ref) async {
  final repo = ref.watch(agentConfigRepositoryProvider);
  final configs = repo.getAllAgentConfigs();
  if (configs.isNotEmpty) {
    return configs.first;
  }
  // Fallback default agent config.
  return const AgentConfig(
    id: 'default',
    name: 'حەمەومین',
    description: 'یاریدەدەری کوردی',
    systemPrompt: 'تۆ یاریدەدەرێکی کوردی بە ناوی حەمەومینیت. وەڵامی کوردی سۆرانی بدەرەوە.',
    modelId: 'gpt-4o-mini',
    temperature: 0.7,
    maxTokens: 2048,
    isDefault: true,
    isActive: true,
  );
});

/// Provider for [DeviceChannel].
///
/// Returns [AndroidDeviceChannel] on Android and [StubDeviceChannel]
/// on all other platforms (iOS, web, desktop), ensuring graceful
/// fallback with `platformUnsupported` error codes.
final deviceChannelProvider = Provider<DeviceChannel>((ref) {
  if (Platform.isAndroid) {
    return AndroidDeviceChannel();
  }
  return StubDeviceChannel(
    platformLabel: Platform.operatingSystem,
  );
});

/// Provider for [ToolRegistry] with all tools registered.
final toolRegistryProvider = Provider<ToolRegistry>((ref) {
  final registry = ToolRegistry();
  // ── Alarm tools (all backed by the real AlarmSchedulerService) ──
  final alarmGateway = ref.watch(alarmToolGatewayProvider);
  registry.register(CreateAlarmTool(alarmGateway));
  registry.register(ListAlarmsTool(alarmGateway));
  registry.register(UpdateAlarmTool(alarmGateway));
  registry.register(DeleteAlarmTool(alarmGateway));
  registry.register(SetAlarmTool(alarmGateway));
  // ── Vision tools ──
  final visionService = ref.watch(openaiVisionServiceProvider);
  registry.register(AnalyzeVisionTool(visionService));
  registry.register(FindObjectTool(visionService));
  registry.register(ReadTextTool(visionService));
  registry.register(LocateTargetTool(visionService));
  registry.register(OpenCameraTool(ref.watch(visionCameraServiceProvider)));
  // ── Device tools ──
  final deviceChannel = ref.watch(deviceChannelProvider);
  registry.register(DeviceInfoTool(deviceChannel));
  registry.register(BatteryTool(deviceChannel));
  registry.register(NetworkTool(deviceChannel));
  registry.register(AppLaunchTool(deviceChannel));
  registry.register(SystemSettingsTool(deviceChannel));
  registry.register(UrlLaunchTool(deviceChannel));
  return registry;
});

/// Synchronous provider for the current [AgentConfig] entity.
/// Initialized with a default config; can be updated from the repository.
final agentConfigProvider = StateProvider<AgentConfig>((ref) {
  // Start with default config; when agentConfigEntityProvider resolves,
  // update this.
  ref.listen(agentConfigEntityProvider, (_, next) {
    next.whenData((config) {
      // ignore: deprecated_member_use_from_same_package
      ref.controller.state = config;
    });
  });
  return const AgentConfig(
    id: 'default',
    name: 'حەمەومین',
    description: 'یاریدەدەری کوردی',
    systemPrompt:
        'تۆ یاریدەدەرێکی کوردی بە ناوی حەمەومینیت. وەڵامی کوردی سۆرانی بدەرەوە.',
    modelId: 'gpt-4o-mini',
    temperature: 0.7,
    maxTokens: 2048,
    isDefault: true,
    isActive: true,
  );
});

/// Provider for [AgentEngine] wired with the sendToAI adapter.
final agentEngineProvider = Provider<AgentEngine>((ref) {
  final toolRegistry = ref.watch(toolRegistryProvider);
  final aiProvider = ref.watch(openaiProviderProvider);
  final securityGate = ref.watch(toolSecurityGateProvider);

  return AgentEngine(
    toolRegistry: toolRegistry,
    securityGate: securityGate,
    onSecurityConfirmation: (request) =>
        ref.read(securityConfirmationProvider.notifier).request(request),
    sendToAI: ({
      required List<Map<String, dynamic>> messages,
      required List<Map<String, dynamic>> toolDefinitions,
      required AgentContext context,
    }) {
      return sendToAIAdapter(
        messages: messages,
        toolDefinitions: toolDefinitions,
        context: context,
        aiProvider: aiProvider,
      );
    },
  );
});
