import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'ampoule-uses-left': 'Ampoule uses left:',
      'ampoule-uses': 'Ampoule uses',
      'last-use': 'Last use',
      'settings': 'Settings',
      'launch-timer': 'Launch timer',
      'start-timer': 'Start timer',
      'stop-timer': 'Stop timer',
      'restart': 'Restart',
      'save': 'Save',
      'loading': 'Loading',
      'timer-duration': 'Timer duration',
      'reminder-notification-timer': 'Reminder notification time (Not implemented)',
    },
    'pl': {
      'ampoule-uses-left': 'Pozostałe użycia ampułki:',
      'ampoule-uses': 'Użycia ampułki',
      'last-use': 'Ostatnie użycie',
      'settings': 'Ustawienia',
      'launch-timer': 'Uruchom timer',
      'start-timer': 'Rozpocznij timer',
      'stop-timer': 'Zatrzymaj timer',
      'restart': 'Restartuj',
      'save': 'Zapisz',
      'loading': 'Wczytywanie',
      'timer-duration': 'Czas trwania timera',
      'reminder-notification-timer': 'Czas przypomnienia (Nie zaimplementowane)',
    },
  };

  static Map<String, Map<String, Function>> _localizedDynamicValues = {
    'en': {
      'timer-duration-value': (value) {
        if (value == 1) {
          return '$value second';
        } else {
          return '$value seconds';
        }
      },
      'ampoule-uses-value': (value) {
        if (value == 1) {
          return '$value use';
        } else {
          return '$value uses';
        }
      },
    },
    'pl': {
      'timer-duration-value': (value) {
        if (value == 1) {
          return '$value sekunda';
        } else if (value % 10 >= 2 && value % 10 <= 4) {
          return '$value sekundy';
        } else {
          return '$value sekund';
        }
      },
      'ampoule-uses-value': (value) {
        if (value == 1) {
          return '$value użycie';
        } else if (value % 10 >= 2 && value % 10 <= 4) {
          return '$value użycia';
        } else {
          return '$value użyć';
        }
      },
    },
  };

  String get ampouleUsesLeft {
    return _localizedValues[locale.languageCode]['ampoule-uses-left'];
  }

  String get ampouleUses {
    return _localizedValues[locale.languageCode]['ampoule-uses'];
  }

  String get lastUse {
    return _localizedValues[locale.languageCode]['last-use'];
  }

  String get settings {
    return _localizedValues[locale.languageCode]['settings'];
  }

  String get launchTimer {
    return _localizedValues[locale.languageCode]['launch-timer'];
  }

  String get startTimer {
    return _localizedValues[locale.languageCode]['start-timer'];
  }

  String get stopTimer {
    return _localizedValues[locale.languageCode]['stop-timer'];
  }

  String get restart {
    return _localizedValues[locale.languageCode]['restart'];
  }

  String get save {
    return _localizedValues[locale.languageCode]['save'];
  }

  String get loading {
    return _localizedValues[locale.languageCode]['loading'];
  }

  String get timerDuration {
    return _localizedValues[locale.languageCode]['timer-duration'];
  }

  String get reminderNotificationTime {
    return _localizedValues[locale.languageCode]['reminder-notification-timer'];
  }

  String timerDurationValue(value) {
    return _localizedDynamicValues[locale.languageCode]['timer-duration-value'](value);
  }

  String ampouleUsesValue(value) {
    return _localizedDynamicValues[locale.languageCode]['ampoule-uses-value'](value);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
