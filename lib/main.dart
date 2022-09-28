import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';
import 'package:vwa_grading/state-management/preferences.dart';
import 'package:vwa_grading/page_slider.dart';
import 'package:vwa_grading/state-management/vwa_data.dart';
import 'package:vwa_grading/theme/color_schemes.dart';
import 'package:vwa_grading/theme/text_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tomlMap = TomlDocument.parse(
    await rootBundle.loadString("assets/questions.toml"),
  ).toMap();

  questionsProvider.loadMap(tomlMap);

  LicenseRegistry.addLicense(() async* {
    final licenseRoboto = await rootBundle.loadString(
      'assets/google-fonts/roboto-license.txt',
    );
    final licenseShrikhand = await rootBundle.loadString(
      'assets/google-fonts/shrikhand-license.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseRoboto);
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseShrikhand);
  });

  runApp(const VWAApp());
}

class VWAApp extends StatelessWidget {
  const VWAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: themeModePrefNotifier,
        builder: (context, value, _) {
          late final ThemeMode themeMode;

          if (value == null || value == 0) {
            themeMode = ThemeMode.system;
          } else if (value == -1) {
            themeMode = ThemeMode.dark;
          } else if (value == 1) {
            themeMode = ThemeMode.light;
          }

          return MaterialApp(
            themeMode: themeMode,
            title: "VWA Benotung",
            debugShowCheckedModeBanner: false,
            theme: _theme(lightColorScheme),
            darkTheme: _theme(darkColorScheme),
            home: const PageSlider(),
          );
        });
  }

  ThemeData _theme(ColorScheme scheme) {
    const buttonMinSize = Size(96, 48);

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      dialogBackgroundColor: scheme.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        endIndent: 16,
        indent: 16,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: scheme.surface,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(),
        labelStyle: textTheme.bodyLarge,
        floatingLabelStyle: textTheme.bodyMedium,
        filled: false,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: scheme.surface,
        elevation: 3,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStatePropertyAll<Size>(buttonMinSize),
        ),
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStatePropertyAll<Size>(buttonMinSize),
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStatePropertyAll<Size>(buttonMinSize),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        textStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
