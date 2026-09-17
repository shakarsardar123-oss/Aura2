import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ku')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ku, this message translates to:
  /// **'AURA'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In ku, this message translates to:
  /// **'بەخێربێیت بۆ AURA'**
  String get welcomeMessage;

  /// No description provided for @settings.
  ///
  /// In ku, this message translates to:
  /// **'ڕێکخستنەکان'**
  String get settings;

  /// No description provided for @chat.
  ///
  /// In ku, this message translates to:
  /// **'چات'**
  String get chat;

  /// No description provided for @voiceInput.
  ///
  /// In ku, this message translates to:
  /// **'دەنگی تۆمارکردن'**
  String get voiceInput;

  /// No description provided for @typingPlaceholder.
  ///
  /// In ku, this message translates to:
  /// **'پەیامەکەت بنووسە...'**
  String get typingPlaceholder;

  /// No description provided for @send.
  ///
  /// In ku, this message translates to:
  /// **'ناردن'**
  String get send;

  /// No description provided for @themeDark.
  ///
  /// In ku, this message translates to:
  /// **'تاریک'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ku, this message translates to:
  /// **'ڕوناک'**
  String get themeLight;

  /// No description provided for @themeNatural.
  ///
  /// In ku, this message translates to:
  /// **'سروشتی'**
  String get themeNatural;

  /// No description provided for @themeSystem.
  ///
  /// In ku, this message translates to:
  /// **'سیستەم'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In ku, this message translates to:
  /// **'زمان'**
  String get language;

  /// No description provided for @about.
  ///
  /// In ku, this message translates to:
  /// **'دەربارە'**
  String get about;

  /// No description provided for @retry.
  ///
  /// In ku, this message translates to:
  /// **'هەوڵدانەوە'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ku, this message translates to:
  /// **'پاشگەزبوونەوە'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In ku, this message translates to:
  /// **'باشە'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In ku, this message translates to:
  /// **'هەڵە'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ku, this message translates to:
  /// **'سەرکەوتوو'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In ku, this message translates to:
  /// **'چاوەڕوان بە...'**
  String get loading;

  /// No description provided for @noInternet.
  ///
  /// In ku, this message translates to:
  /// **'پەیوەندی ئینتەرنێت نییە'**
  String get noInternet;

  /// No description provided for @agentNameAura.
  ///
  /// In ku, this message translates to:
  /// **'AURA'**
  String get agentNameAura;

  /// No description provided for @agentDescriptionAura.
  ///
  /// In ku, this message translates to:
  /// **'یاریدەدەری زیرەکی تایبەت بە تۆ'**
  String get agentDescriptionAura;

  /// No description provided for @home.
  ///
  /// In ku, this message translates to:
  /// **'سەرەکی'**
  String get home;

  /// No description provided for @voice.
  ///
  /// In ku, this message translates to:
  /// **'دەنگ'**
  String get voice;

  /// No description provided for @settingsTab.
  ///
  /// In ku, this message translates to:
  /// **'ڕێکخستنەکان'**
  String get settingsTab;

  /// No description provided for @greeting.
  ///
  /// In ku, this message translates to:
  /// **'سڵاو'**
  String get greeting;

  /// No description provided for @greetingSub.
  ///
  /// In ku, this message translates to:
  /// **'چۆن دەتوانم یارمەتیت بدەم؟'**
  String get greetingSub;

  /// No description provided for @statusOnline.
  ///
  /// In ku, this message translates to:
  /// **'سەرهێڵ'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In ku, this message translates to:
  /// **'دەرهێڵ'**
  String get statusOffline;

  /// No description provided for @statusReady.
  ///
  /// In ku, this message translates to:
  /// **'ئامادەیە'**
  String get statusReady;

  /// No description provided for @voiceIdle.
  ///
  /// In ku, this message translates to:
  /// **'دەست بخە بۆ قسەکردن'**
  String get voiceIdle;

  /// No description provided for @voiceListening.
  ///
  /// In ku, this message translates to:
  /// **'گوێ دەگرێت...'**
  String get voiceListening;

  /// No description provided for @voiceProcessing.
  ///
  /// In ku, this message translates to:
  /// **'چاوەڕوان بە...'**
  String get voiceProcessing;

  /// No description provided for @voiceSpeaking.
  ///
  /// In ku, this message translates to:
  /// **'قسە دەکات'**
  String get voiceSpeaking;

  /// No description provided for @voiceError.
  ///
  /// In ku, this message translates to:
  /// **'هەڵە'**
  String get voiceError;

  /// No description provided for @quickActions.
  ///
  /// In ku, this message translates to:
  /// **'کردارە خێراکان'**
  String get quickActions;

  /// No description provided for @recentConversations.
  ///
  /// In ku, this message translates to:
  /// **'وانەکنووسی تازە'**
  String get recentConversations;

  /// No description provided for @noConversations.
  ///
  /// In ku, this message translates to:
  /// **'هیچ وانەکنووسێک نییە'**
  String get noConversations;

  /// No description provided for @noConversationsSub.
  ///
  /// In ku, this message translates to:
  /// **'دەست پە بکە بە قسەکردن لەگەڵ AURA'**
  String get noConversationsSub;

  /// No description provided for @theme.
  ///
  /// In ku, this message translates to:
  /// **'ڕووکار'**
  String get theme;

  /// No description provided for @themeSelection.
  ///
  /// In ku, this message translates to:
  /// **'هەڵبژاردنی ڕووکار'**
  String get themeSelection;

  /// No description provided for @languageSelection.
  ///
  /// In ku, this message translates to:
  /// **'هەڵبژاردنی زمان'**
  String get languageSelection;

  /// No description provided for @kurdish.
  ///
  /// In ku, this message translates to:
  /// **'کوردی'**
  String get kurdish;

  /// No description provided for @english.
  ///
  /// In ku, this message translates to:
  /// **'ئینگلیزی'**
  String get english;

  /// No description provided for @directionRtl.
  ///
  /// In ku, this message translates to:
  /// **'ڕاست بۆ چەپ'**
  String get directionRtl;

  /// No description provided for @directionLtr.
  ///
  /// In ku, this message translates to:
  /// **'چەپ بۆ ڕاست'**
  String get directionLtr;

  /// No description provided for @agentNameLabel.
  ///
  /// In ku, this message translates to:
  /// **'ناوی یاریدەدەر'**
  String get agentNameLabel;

  /// No description provided for @changeName.
  ///
  /// In ku, this message translates to:
  /// **'گۆڕینی ناو'**
  String get changeName;

  /// No description provided for @saveChanges.
  ///
  /// In ku, this message translates to:
  /// **'پاشەکەوتکردن'**
  String get saveChanges;

  /// No description provided for @aboutApp.
  ///
  /// In ku, this message translates to:
  /// **'دەربارەی ئەپ'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In ku, this message translates to:
  /// **'وەشان'**
  String get version;

  /// No description provided for @builtWith.
  ///
  /// In ku, this message translates to:
  /// **'دروستکراوە بە خۆشەویستی'**
  String get builtWith;

  /// No description provided for @textDirection.
  ///
  /// In ku, this message translates to:
  /// **'ئاراستەی نووسین'**
  String get textDirection;

  /// No description provided for @visualPreferences.
  ///
  /// In ku, this message translates to:
  /// **'هەڵبژاردنە بینراوەکان'**
  String get visualPreferences;

  /// No description provided for @general.
  ///
  /// In ku, this message translates to:
  /// **'گشتی'**
  String get general;

  /// No description provided for @appearance.
  ///
  /// In ku, this message translates to:
  /// **'دەرکەوتن'**
  String get appearance;

  /// No description provided for @assistantIdentity.
  ///
  /// In ku, this message translates to:
  /// **'ناسنامەی یاریدەدەر'**
  String get assistantIdentity;

  /// No description provided for @phaseNotice.
  ///
  /// In ku, this message translates to:
  /// **'AURA یاریدەدەری زیرەکیت — تایبەتمەندییەکانی دەنگ و زیرەکی دەستکرد چالاکە'**
  String get phaseNotice;

  /// No description provided for @tapToStart.
  ///
  /// In ku, this message translates to:
  /// **'لێرەدا بدە بۆ دەستپێکردن'**
  String get tapToStart;

  /// No description provided for @visionTab.
  ///
  /// In ku, this message translates to:
  /// **'بینین'**
  String get visionTab;

  /// No description provided for @visionTitle.
  ///
  /// In ku, this message translates to:
  /// **'بینین'**
  String get visionTitle;

  /// No description provided for @visionQuickAction.
  ///
  /// In ku, this message translates to:
  /// **'بینین'**
  String get visionQuickAction;

  /// No description provided for @visionCameraPermission.
  ///
  /// In ku, this message translates to:
  /// **'مۆڵەتی کامێرا پێویستە'**
  String get visionCameraPermission;

  /// No description provided for @visionCameraError.
  ///
  /// In ku, this message translates to:
  /// **'هەڵەی کامێرا'**
  String get visionCameraError;

  /// No description provided for @visionInitializing.
  ///
  /// In ku, this message translates to:
  /// **'دەستپێکردن...'**
  String get visionInitializing;

  /// No description provided for @visionAnalyzing.
  ///
  /// In ku, this message translates to:
  /// **'شیکردنەوە...'**
  String get visionAnalyzing;

  /// No description provided for @visionModeAnalyze.
  ///
  /// In ku, this message translates to:
  /// **'شیکردنەوە'**
  String get visionModeAnalyze;

  /// No description provided for @visionModeFind.
  ///
  /// In ku, this message translates to:
  /// **'گەڕان'**
  String get visionModeFind;

  /// No description provided for @visionModeRead.
  ///
  /// In ku, this message translates to:
  /// **'خوێندنەوە'**
  String get visionModeRead;

  /// No description provided for @visionModeScene.
  ///
  /// In ku, this message translates to:
  /// **'دیمەن'**
  String get visionModeScene;

  /// No description provided for @visionModeLocate.
  ///
  /// In ku, this message translates to:
  /// **'شوێنپێکردن'**
  String get visionModeLocate;

  /// No description provided for @visionOcrResult.
  ///
  /// In ku, this message translates to:
  /// **'ئەنجامی خوێندنەوە'**
  String get visionOcrResult;

  /// No description provided for @visionCaptureError.
  ///
  /// In ku, this message translates to:
  /// **'هەڵەی وێنەگرتن'**
  String get visionCaptureError;

  /// No description provided for @visionSwitchCamera.
  ///
  /// In ku, this message translates to:
  /// **'گۆڕینی کامێرا'**
  String get visionSwitchCamera;

  /// No description provided for @visionFlash.
  ///
  /// In ku, this message translates to:
  /// **'فلاش'**
  String get visionFlash;

  /// No description provided for @visionZoom.
  ///
  /// In ku, this message translates to:
  /// **'نێزیککردنەوە'**
  String get visionZoom;

  /// No description provided for @visionVoice.
  ///
  /// In ku, this message translates to:
  /// **'دەنگ'**
  String get visionVoice;

  /// No description provided for @visionTargetsFound.
  ///
  /// In ku, this message translates to:
  /// **'{count} ئامانج دۆزرایەوە'**
  String visionTargetsFound(int count);

  /// No description provided for @alarmTab.
  ///
  /// In ku, this message translates to:
  /// **'ئاژەڵ'**
  String get alarmTab;

  /// No description provided for @alarmRinging.
  ///
  /// In ku, this message translates to:
  /// **'ئاژەڵ دەلێت!'**
  String get alarmRinging;

  /// No description provided for @alarmCheckingFace.
  ///
  /// In ku, this message translates to:
  /// **'پشکنینی ڕووخسار...'**
  String get alarmCheckingFace;

  /// No description provided for @alarmFaceDetected.
  ///
  /// In ku, this message translates to:
  /// **'ڕووخسار ناسێندرا'**
  String get alarmFaceDetected;

  /// No description provided for @alarmAwaitingVoice.
  ///
  /// In ku, this message translates to:
  /// **'چاوەڕوانی دەنگ...'**
  String get alarmAwaitingVoice;

  /// No description provided for @alarmVerified.
  ///
  /// In ku, this message translates to:
  /// **'پشتڕاستکرایەوە'**
  String get alarmVerified;

  /// No description provided for @alarmSnoozed.
  ///
  /// In ku, this message translates to:
  /// **'دواخرا'**
  String get alarmSnoozed;

  /// No description provided for @alarmTimeout.
  ///
  /// In ku, this message translates to:
  /// **'کات تەواو بوو'**
  String get alarmTimeout;

  /// No description provided for @alarmError.
  ///
  /// In ku, this message translates to:
  /// **'هەڵە'**
  String get alarmError;

  /// No description provided for @alarmScheduled.
  ///
  /// In ku, this message translates to:
  /// **'ڕێکخراوە'**
  String get alarmScheduled;

  /// No description provided for @alarmPrivacyMode.
  ///
  /// In ku, this message translates to:
  /// **'دۆخی تایبەتمەندی'**
  String get alarmPrivacyMode;

  /// No description provided for @alarmSnooze.
  ///
  /// In ku, this message translates to:
  /// **'دواخستن'**
  String get alarmSnooze;

  /// No description provided for @alarmStop.
  ///
  /// In ku, this message translates to:
  /// **'وەستاندن'**
  String get alarmStop;

  /// No description provided for @alarmImAwake.
  ///
  /// In ku, this message translates to:
  /// **'هۆشم'**
  String get alarmImAwake;

  /// No description provided for @alarmDone.
  ///
  /// In ku, this message translates to:
  /// **'تەواو'**
  String get alarmDone;

  /// No description provided for @alarmNoAlarms.
  ///
  /// In ku, this message translates to:
  /// **'هیچ ئاژەڵێک نییە'**
  String get alarmNoAlarms;

  /// No description provided for @alarmSnoozeDuration.
  ///
  /// In ku, this message translates to:
  /// **'ماوەی دواخستن'**
  String get alarmSnoozeDuration;

  /// No description provided for @alarmDeleteAlarm.
  ///
  /// In ku, this message translates to:
  /// **'سڕینەوەی ئاژەڵ'**
  String get alarmDeleteAlarm;

  /// No description provided for @alarmDaysMonday.
  ///
  /// In ku, this message translates to:
  /// **'دووشەممە'**
  String get alarmDaysMonday;

  /// No description provided for @alarmDaysTuesday.
  ///
  /// In ku, this message translates to:
  /// **'سێشەممە'**
  String get alarmDaysTuesday;

  /// No description provided for @alarmDaysWednesday.
  ///
  /// In ku, this message translates to:
  /// **'چوارشەممە'**
  String get alarmDaysWednesday;

  /// No description provided for @alarmDaysThursday.
  ///
  /// In ku, this message translates to:
  /// **'پێنجشەممە'**
  String get alarmDaysThursday;

  /// No description provided for @alarmDaysFriday.
  ///
  /// In ku, this message translates to:
  /// **'هەینی'**
  String get alarmDaysFriday;

  /// No description provided for @alarmDaysSaturday.
  ///
  /// In ku, this message translates to:
  /// **'شەممە'**
  String get alarmDaysSaturday;

  /// No description provided for @alarmDaysSunday.
  ///
  /// In ku, this message translates to:
  /// **'یەکشەممە'**
  String get alarmDaysSunday;

  /// No description provided for @deviceInfoTitle.
  ///
  /// In ku, this message translates to:
  /// **'زانیاری ئامێر'**
  String get deviceInfoTitle;

  /// No description provided for @deviceInfoBrand.
  ///
  /// In ku, this message translates to:
  /// **'بڕاند'**
  String get deviceInfoBrand;

  /// No description provided for @deviceInfoModel.
  ///
  /// In ku, this message translates to:
  /// **'مۆدێل'**
  String get deviceInfoModel;

  /// No description provided for @deviceInfoManufacturer.
  ///
  /// In ku, this message translates to:
  /// **'بەرهەمهێنەر'**
  String get deviceInfoManufacturer;

  /// No description provided for @deviceInfoAndroidVersion.
  ///
  /// In ku, this message translates to:
  /// **'وەشانی ئەندرۆید'**
  String get deviceInfoAndroidVersion;

  /// No description provided for @deviceInfoSdkInt.
  ///
  /// In ku, this message translates to:
  /// **'ئاستی SDK'**
  String get deviceInfoSdkInt;

  /// No description provided for @deviceInfoIsPhysical.
  ///
  /// In ku, this message translates to:
  /// **'ئامێری فیزیکی'**
  String get deviceInfoIsPhysical;

  /// No description provided for @deviceInfoHardware.
  ///
  /// In ku, this message translates to:
  /// **'هاردوێر'**
  String get deviceInfoHardware;

  /// No description provided for @deviceInfoBoard.
  ///
  /// In ku, this message translates to:
  /// **'بۆرد'**
  String get deviceInfoBoard;

  /// No description provided for @deviceInfoDevice.
  ///
  /// In ku, this message translates to:
  /// **'ئامێر'**
  String get deviceInfoDevice;

  /// No description provided for @deviceToolPermissionDenied.
  ///
  /// In ku, this message translates to:
  /// **'مۆڵەتی ئامێر ڕەتکرایەوە'**
  String get deviceToolPermissionDenied;

  /// No description provided for @deviceToolPlatformUnsupported.
  ///
  /// In ku, this message translates to:
  /// **'ئەم تایبەتمەندییە لەسەر ئەم پلاتفۆرمە بەردەست نییە'**
  String get deviceToolPlatformUnsupported;

  /// No description provided for @deviceToolError.
  ///
  /// In ku, this message translates to:
  /// **'هەڵەی ئامێر'**
  String get deviceToolError;

  /// No description provided for @deviceToolSuccess.
  ///
  /// In ku, this message translates to:
  /// **'سەرکەوتوو'**
  String get deviceToolSuccess;

  /// No description provided for @aiConnectionTitle.
  ///
  /// In ku, this message translates to:
  /// **'پەیوەندی AI'**
  String get aiConnectionTitle;

  /// No description provided for @aiModel.
  ///
  /// In ku, this message translates to:
  /// **'مۆدێل'**
  String get aiModel;

  /// No description provided for @aiModelHint.
  ///
  /// In ku, this message translates to:
  /// **'بۆ نموونە gpt-4o-mini'**
  String get aiModelHint;

  /// No description provided for @aiBaseUrl.
  ///
  /// In ku, this message translates to:
  /// **'URLی بنەڕەتی API'**
  String get aiBaseUrl;

  /// No description provided for @aiApiKey.
  ///
  /// In ku, this message translates to:
  /// **'کلیلی API'**
  String get aiApiKey;

  /// No description provided for @aiNoKeyStored.
  ///
  /// In ku, this message translates to:
  /// **'هیچ کلیلی API یەک پاشەکەوت نەکراوە'**
  String get aiNoKeyStored;

  /// No description provided for @aiReplaceKey.
  ///
  /// In ku, this message translates to:
  /// **'گۆڕینی کلیلی API'**
  String get aiReplaceKey;

  /// No description provided for @aiSaveSecurely.
  ///
  /// In ku, this message translates to:
  /// **'پاشەکەوتکردنی پارێزراو'**
  String get aiSaveSecurely;

  /// No description provided for @aiDeleteKey.
  ///
  /// In ku, this message translates to:
  /// **'سڕینەوەی کلیل'**
  String get aiDeleteKey;

  /// No description provided for @aiKeyStorageNote.
  ///
  /// In ku, this message translates to:
  /// **'لە کۆگای پارێزراوی ئامێرەوە پاشەکەوت کراوە. کلیلی تەواو دوای پاشەکەوتکردن هەرگیز نیشان نادرێتەوە و هەرگیز بۆ لۆگەکان نانووسرێت.'**
  String get aiKeyStorageNote;

  /// No description provided for @aiModelValidationEmpty.
  ///
  /// In ku, this message translates to:
  /// **'ناوی مۆدێل ناتوانێت بەتاڵ بێت'**
  String get aiModelValidationEmpty;
  String get feature_assistant_integration;
  String get feature_device_integration;
  String get feature_file_storage;
  String get feature_floating_overlay;
  String get feature_foreground_service;
  String get feature_location_services;
  String get feature_notifications;
  String get feature_screen_capture;
  String get feature_unknown;
  String get feature_vision;
  String get feature_voice_screen;
  String get perm_accessibility_body;
  String get perm_accessibility_title;
  String get perm_all_granted;
  String get perm_assistant_body;
  String get perm_assistant_title;
  String get perm_battery_body;
  String get perm_battery_title;
  String get perm_camera_body;
  String get perm_camera_title;
  String get perm_check_all;
  String get perm_continue;
  String get perm_critical;
  String get perm_dashboard_subtitle;
  String get perm_dashboard_title;
  String get perm_denied;
  String get perm_error_occurred;
  String get perm_granted;
  String get perm_loading;
  String get perm_location_body;
  String get perm_location_title;
  String get perm_microphone_body;
  String get perm_microphone_title;
  String get perm_not_now;
  String get perm_notification_body;
  String get perm_notification_title;
  String get perm_open_settings;
  String get perm_overlay_body;
  String get perm_overlay_title;
  String get perm_permanently_denied;
  String get perm_request;
  String get perm_request_all;
  String get perm_screen_capture_body;
  String get perm_screen_capture_title;
  String get perm_some_denied;
  String get perm_storage_body;
  String get perm_storage_title;
  String get perm_unknown;
  String get perm_used_by;

  /// Maps a string key to its localized value.
  /// Used by features that construct keys dynamically.
  /// Falls back to the key itself if no match is found.
  String translate(String key) {
    final Map<String, String> _keyMap = {
      'feature_assistant_integration': feature_assistant_integration,
      'feature_device_integration': feature_device_integration,
      'feature_file_storage': feature_file_storage,
      'feature_floating_overlay': feature_floating_overlay,
      'feature_foreground_service': feature_foreground_service,
      'feature_location_services': feature_location_services,
      'feature_notifications': feature_notifications,
      'feature_screen_capture': feature_screen_capture,
      'feature_unknown': feature_unknown,
      'feature_vision': feature_vision,
      'feature_voice_screen': feature_voice_screen,
      'perm_accessibility_body': perm_accessibility_body,
      'perm_accessibility_title': perm_accessibility_title,
      'perm_all_granted': perm_all_granted,
      'perm_assistant_body': perm_assistant_body,
      'perm_assistant_title': perm_assistant_title,
      'perm_battery_body': perm_battery_body,
      'perm_battery_title': perm_battery_title,
      'perm_camera_body': perm_camera_body,
      'perm_camera_title': perm_camera_title,
      'perm_check_all': perm_check_all,
      'perm_continue': perm_continue,
      'perm_critical': perm_critical,
      'perm_dashboard_subtitle': perm_dashboard_subtitle,
      'perm_dashboard_title': perm_dashboard_title,
      'perm_denied': perm_denied,
      'perm_error_occurred': perm_error_occurred,
      'perm_granted': perm_granted,
      'perm_loading': perm_loading,
      'perm_location_body': perm_location_body,
      'perm_location_title': perm_location_title,
      'perm_microphone_body': perm_microphone_body,
      'perm_microphone_title': perm_microphone_title,
      'perm_not_now': perm_not_now,
      'perm_notification_body': perm_notification_body,
      'perm_notification_title': perm_notification_title,
      'perm_open_settings': perm_open_settings,
      'perm_overlay_body': perm_overlay_body,
      'perm_overlay_title': perm_overlay_title,
      'perm_permanently_denied': perm_permanently_denied,
      'perm_request': perm_request,
      'perm_request_all': perm_request_all,
      'perm_screen_capture_body': perm_screen_capture_body,
      'perm_screen_capture_title': perm_screen_capture_title,
      'perm_some_denied': perm_some_denied,
      'perm_storage_body': perm_storage_body,
      'perm_storage_title': perm_storage_title,
      'perm_unknown': perm_unknown,
      'perm_used_by': perm_used_by,
    };
    return _keyMap[key] ?? key;
  }
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'ku': return SKu();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
