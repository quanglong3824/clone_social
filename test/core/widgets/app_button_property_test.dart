import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibe_social/core/widgets/app_button.dart';
import 'package:vibe_social/core/themes/app_theme.dart';

/// **Feature: social-app-complete-redesign, Property 17: Button Variant Styling**
/// **Validates: Requirements 11.2**
///
/// Property: For any AppButton with a given variant, the rendered button SHALL
/// have the correct colors, borders, and text style for that variant.

void main() {
  group('Property 17: Button Variant Styling', () {
    /// **Feature: social-app-complete-redesign, Property 17: Button Variant Styling**
    /// **Validates: Requirements 11.2**
    ///
    /// For any AppButton with a given variant, the rendered button SHALL have
    /// the correct colors, borders, and text style for that variant.

    // Test all variants in light mode
    for (final variant in ButtonVariant.values) {
      testWidgets(
        'variant ${variant.name} has correct styling in light mode',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: AppButton(
                    label: 'Test',
                    variant: variant,
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          );

          await _verifyVariantStyling(tester, variant, isDark: false);
        },
      );
    }

    // Test all variants in dark mode
    for (final variant in ButtonVariant.values) {
      testWidgets(
        'variant ${variant.name} has correct styling in dark mode',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(
                body: Center(
                  child: AppButton(
                    label: 'Test',
                    variant: variant,
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          );

          await _verifyVariantStyling(tester, variant, isDark: true);
        },
      );
    }

    // Test all variants across all sizes (property: consistent styling across sizes)
    for (final variant in ButtonVariant.values) {
      for (final size in ButtonSize.values) {
        testWidgets(
          'variant ${variant.name} with size ${size.name} renders correctly',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.lightTheme,
                home: Scaffold(
                  body: Center(
                    child: AppButton(
                      label: 'Test',
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            );

            // Verify the button renders
            expect(find.text('Test'), findsOneWidget);

            // Verify correct button type based on variant
            _verifyButtonType(tester, variant);

            // Verify height based on size
            final sizedBox =
                tester.widget<SizedBox>(find.byType(SizedBox).first);
            final expectedHeight = switch (size) {
              ButtonSize.small => 32.0,
              ButtonSize.medium => 44.0,
              ButtonSize.large => 52.0,
            };
            expect(sizedBox.height, equals(expectedHeight));
          },
        );
      }
    }

    // Test foreground colors for all variants
    for (final variant in ButtonVariant.values) {
      testWidgets(
        'variant ${variant.name} has correct foreground color',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: AppButton(
                    label: 'Test',
                    variant: variant,
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          );

          await _verifyForegroundColor(tester, variant, isDark: false);
        },
      );
    }
  });
}

Future<void> _verifyVariantStyling(
  WidgetTester tester,
  ButtonVariant variant, {
  required bool isDark,
}) async {
  switch (variant) {
    case ButtonVariant.primary:
      // Primary button should have primaryBlue background
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final style = elevatedButton.style!;
      final bgColor = style.backgroundColor?.resolve({});
      expect(bgColor, equals(AppTheme.primaryBlue),
          reason: 'Primary button should have primaryBlue background');
      break;

    case ButtonVariant.secondary:
      // Secondary button should have lightBlue (light) or surfaceDark (dark) background
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final style = elevatedButton.style!;
      final bgColor = style.backgroundColor?.resolve({});
      final expectedBg = isDark ? AppTheme.surfaceDark : AppTheme.lightBlue;
      expect(bgColor, equals(expectedBg),
          reason:
              'Secondary button should have ${isDark ? "surfaceDark" : "lightBlue"} background');
      break;

    case ButtonVariant.outline:
      // Outline button should have a border
      final outlinedButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      final style = outlinedButton.style!;
      final side = style.side?.resolve({});
      expect(side, isNotNull, reason: 'Outline button should have a border');
      final expectedBorderColor =
          isDark ? AppTheme.dividerDark : AppTheme.dividerLight;
      expect(side!.color, equals(expectedBorderColor),
          reason:
              'Outline button border should be ${isDark ? "dividerDark" : "dividerLight"}');
      break;

    case ButtonVariant.text:
      // Text button should have primaryBlue foreground
      final textButton = tester.widget<TextButton>(
        find.byType(TextButton),
      );
      final style = textButton.style!;
      final fgColor = style.foregroundColor?.resolve({});
      expect(fgColor, equals(AppTheme.primaryBlue),
          reason: 'Text button should have primaryBlue foreground');
      break;
  }
}

void _verifyButtonType(WidgetTester tester, ButtonVariant variant) {
  switch (variant) {
    case ButtonVariant.primary:
    case ButtonVariant.secondary:
      expect(find.byType(ElevatedButton), findsOneWidget,
          reason: '${variant.name} variant should render as ElevatedButton');
      break;
    case ButtonVariant.outline:
      expect(find.byType(OutlinedButton), findsOneWidget,
          reason: 'outline variant should render as OutlinedButton');
      break;
    case ButtonVariant.text:
      expect(find.byType(TextButton), findsOneWidget,
          reason: 'text variant should render as TextButton');
      break;
  }
}

Future<void> _verifyForegroundColor(
  WidgetTester tester,
  ButtonVariant variant, {
  required bool isDark,
}) async {
  switch (variant) {
    case ButtonVariant.primary:
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final style = elevatedButton.style!;
      final fgColor = style.foregroundColor?.resolve({});
      expect(fgColor, equals(Colors.white),
          reason: 'Primary button should have white foreground');
      break;

    case ButtonVariant.secondary:
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final style = elevatedButton.style!;
      final fgColor = style.foregroundColor?.resolve({});
      expect(fgColor, equals(AppTheme.primaryBlue),
          reason: 'Secondary button should have primaryBlue foreground');
      break;

    case ButtonVariant.outline:
      final outlinedButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      final style = outlinedButton.style!;
      final fgColor = style.foregroundColor?.resolve({});
      final expectedFg = isDark ? AppTheme.textDark : AppTheme.textPrimary;
      expect(fgColor, equals(expectedFg),
          reason:
              'Outline button should have ${isDark ? "textDark" : "textPrimary"} foreground');
      break;

    case ButtonVariant.text:
      final textButton = tester.widget<TextButton>(
        find.byType(TextButton),
      );
      final style = textButton.style!;
      final fgColor = style.foregroundColor?.resolve({});
      expect(fgColor, equals(AppTheme.primaryBlue),
          reason: 'Text button should have primaryBlue foreground');
      break;
  }
}
