import 'package:material_ui/material_ui.dart';

class AccentOption {
  const AccentOption(this.name, this.color);
  final String name;
  final Color color;
}

/// Colors the user can pick in Settings.
const accentOptions = <AccentOption>[
  AccentOption('Indigo', Color(0xFF6C7BFF)),
  AccentOption('Emerald', Color(0xFF22C58B)),
  AccentOption('Cyan', Color(0xFF1FB6E0)),
  AccentOption('Amber', Color(0xFFF5A623)),
  AccentOption('Rose', Color(0xFFF2557A)),
  AccentOption('Violet', Color(0xFFA06CF5)),
];

/// Fixed semantic colors (HTTP methods / status).
class Semantic {
  static const ok = Color(0xFF2FBF71);
  static const warn = Color(0xFFF5A623);
  static const bad = Color(0xFFF0616D);
  static const info = Color(0xFF4DA3FF);
  static const purple = Color(0xFFA78BFA);

  static Color method(String m) => switch (m) {
    'GET' => ok,
    'POST' => warn,
    'PUT' => info,
    'PATCH' => purple,
    'DELETE' => bad,
    _ => info,
  };

  static Color status(int? code) {
    if (code == null) return bad;
    if (code < 300) return ok;
    if (code < 400) return warn;
    return bad;
  }
}

class AppTheme {
  static ThemeData build(Brightness b, Color accent) {
    final dark = b == Brightness.dark;

    final bg = dark ? const Color(0xFF0B0F17) : const Color(0xFFF3F5F9);
    final surface = dark ? const Color(0xFF131925) : const Color(0xFFFFFFFF);
    final surfaceHigh = dark
        ? const Color(0xFF1B2332)
        : const Color(0xFFE9EDF4);
    final border = dark ? const Color(0xFF263044) : const Color(0xFFDCE2EC);
    final text = dark ? const Color(0xFFE7EBF3) : const Color(0xFF111827);
    final muted = dark ? const Color(0xFF8C97AB) : const Color(0xFF62708A);
    final onAccent = accent.computeLuminance() > 0.45
        ? const Color(0xFF111827)
        : Colors.white;

    final scheme = ColorScheme(
      brightness: b,
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: accent.withValues(alpha: dark ? 0.20 : 0.14),
      onPrimaryContainer: accent,
      secondary: accent,
      onSecondary: onAccent,
      secondaryContainer: accent.withValues(alpha: dark ? 0.20 : 0.14),
      onSecondaryContainer: text,
      error: Semantic.bad,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: bg,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceHigh,
      surfaceContainerHighest: surfaceHigh,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      inverseSurface: text,
      onInverseSurface: bg,
      inversePrimary: accent,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: surface,
      dividerColor: border,
      splashFactory: InkRipple.splashFactory,
      textTheme: ThemeData(brightness: b).textTheme
          .apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: muted),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.30),
        selectionHandleColor: accent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: muted),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(onAccent),
        side: BorderSide(color: muted, width: 1.5),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? accent.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent : muted,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
    );
  }
}
