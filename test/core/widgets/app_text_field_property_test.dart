import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clone_social/core/widgets/app_text_field.dart';
import 'package:clone_social/core/themes/app_theme.dart';

/// **Feature: social-app-complete-redesign, Property 18: Input Field State Styling**
/// **Validates: Requirements 11.3**
///
/// Property: For any AppTextField with a given state, the rendered field SHALL
/// have the correct border color, background, and icon for that state.

/// Enum representing the possible states of AppTextField
enum TextFieldState { normal, focused, error, disabled }

void main() {
  group('Property 18: Input Field State Styling', () {
    /// **Feature: social-app-complete-redesign, Property 18: Input Field State Styling**
    /// **Validates: Requirements 11.3**
    ///
    /// For any AppTextField with a given state, the rendered field SHALL have
    /// the correct border color, background, and icon for that state.

    // Test all states in light mode
    for (final state in TextFieldState.values) {
      testWidgets(
        'state ${state.name} has correct styling in light mode',
        (tester) async {
          await _buildTextFieldWithState(tester, state, isDark: false);
          await _verifyStateStyling(tester, state, isDark: false);
        },
      );
    }

    // Test all states in dark mode
    for (final state in TextFieldState.values) {
      testWidgets(
        'state ${state.name} has correct styling in dark mode',
        (tester) async {
          await _buildTextFieldWithState(tester, state, isDark: true);
          await _verifyStateStyling(tester, state, isDark: true);
        },
      );
    }

    // Test label color changes based on state
    for (final state in TextFieldState.values) {
      testWidgets(
        'label color is correct for state ${state.name}',
        (tester) async {
          await _buildTextFieldWithState(tester, state, isDark: false, withLabel: true);
          await _verifyLabelColor(tester, state, isDark: false);
        },
      );
    }

    // Test that prefix/suffix icons render correctly in all states
    for (final state in TextFieldState.values) {
      testWidgets(
        'prefix and suffix icons render in state ${state.name}',
        (tester) async {
          await _buildTextFieldWithState(
            tester, 
            state, 
            isDark: false, 
            withPrefixIcon: true,
            withSuffixIcon: true,
          );
          
          // Verify icons are present
          expect(find.byIcon(Icons.email), findsOneWidget,
              reason: 'Prefix icon should be present in ${state.name} state');
          expect(find.byIcon(Icons.visibility), findsOneWidget,
              reason: 'Suffix icon should be present in ${state.name} state');
        },
      );
    }

    // Test text input is disabled when in disabled state
    testWidgets(
      'text input is disabled when state is disabled',
      (tester) async {
        await _buildTextFieldWithState(tester, TextFieldState.disabled, isDark: false);
        
        final textFormField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textFormField.enabled, isFalse,
            reason: 'TextFormField should be disabled in disabled state');
      },
    );

    // Test text input is enabled in other states
    for (final state in [TextFieldState.normal, TextFieldState.focused, TextFieldState.error]) {
      testWidgets(
        'text input is enabled when state is ${state.name}',
        (tester) async {
          await _buildTextFieldWithState(tester, state, isDark: false);
          
          final textFormField = tester.widget<TextFormField>(find.byType(TextFormField));
          expect(textFormField.enabled, isTrue,
              reason: 'TextFormField should be enabled in ${state.name} state');
        },
      );
    }

    // Test error text is displayed in error state
    testWidgets(
      'error text is displayed in error state',
      (tester) async {
        const errorMessage = 'This field has an error';
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(
                child: AppTextField(
                  hint: 'Enter text',
                  errorText: errorMessage,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(errorMessage), findsOneWidget,
            reason: 'Error message should be displayed in error state');
      },
    );

    // Test focus state transition
    testWidgets(
      'field transitions to focused state when tapped',
      (tester) async {
        await _buildTextFieldWithState(tester, TextFieldState.normal, isDark: false);
        
        // Tap to focus
        await tester.tap(find.byType(TextFormField));
        await tester.pump();
        
        // Now verify focused styling
        await _verifyStateStyling(tester, TextFieldState.focused, isDark: false);
      },
    );
  });
}

/// Builds an AppTextField with the specified state
Future<void> _buildTextFieldWithState(
  WidgetTester tester,
  TextFieldState state, {
  required bool isDark,
  bool withLabel = false,
  bool withPrefixIcon = false,
  bool withSuffixIcon = false,
}) async {
  final focusNode = FocusNode();
  
  Widget textField;
  switch (state) {
    case TextFieldState.normal:
      textField = AppTextField(
        hint: 'Enter text',
        label: withLabel ? 'Label' : null,
        prefixIcon: withPrefixIcon ? const Icon(Icons.email) : null,
        suffixIcon: withSuffixIcon ? const Icon(Icons.visibility) : null,
        focusNode: focusNode,
      );
      break;
    case TextFieldState.focused:
      textField = AppTextField(
        hint: 'Enter text',
        label: withLabel ? 'Label' : null,
        prefixIcon: withPrefixIcon ? const Icon(Icons.email) : null,
        suffixIcon: withSuffixIcon ? const Icon(Icons.visibility) : null,
        focusNode: focusNode,
        autofocus: true,
      );
      break;
    case TextFieldState.error:
      textField = AppTextField(
        hint: 'Enter text',
        label: withLabel ? 'Label' : null,
        errorText: 'Error message',
        prefixIcon: withPrefixIcon ? const Icon(Icons.email) : null,
        suffixIcon: withSuffixIcon ? const Icon(Icons.visibility) : null,
        focusNode: focusNode,
      );
      break;
    case TextFieldState.disabled:
      textField = AppTextField(
        hint: 'Enter text',
        label: withLabel ? 'Label' : null,
        enabled: false,
        prefixIcon: withPrefixIcon ? const Icon(Icons.email) : null,
        suffixIcon: withSuffixIcon ? const Icon(Icons.visibility) : null,
        focusNode: focusNode,
      );
      break;
  }

  await tester.pumpWidget(
    MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: Center(child: textField),
      ),
    ),
  );
  
  // Allow focus to settle for focused state
  if (state == TextFieldState.focused) {
    await tester.pump();
  }
}

/// Verifies the styling is correct for the given state
Future<void> _verifyStateStyling(
  WidgetTester tester,
  TextFieldState state, {
  required bool isDark,
}) async {
  // Find the TextField widget inside TextFormField to access decoration
  final textField = tester.widget<TextField>(find.byType(TextField));
  final decoration = textField.decoration!;

  switch (state) {
    case TextFieldState.normal:
      // Normal state: standard border color
      final enabledBorder = decoration.enabledBorder as OutlineInputBorder;
      final expectedBorderColor = isDark ? AppTheme.dividerDark : AppTheme.dividerLight;
      expect(enabledBorder.borderSide.color, equals(expectedBorderColor),
          reason: 'Normal state should have ${isDark ? "dividerDark" : "dividerLight"} border');
      expect(enabledBorder.borderSide.width, equals(1.0),
          reason: 'Normal state should have 1.0 border width');
      break;

    case TextFieldState.focused:
      // Focused state: primaryBlue border with width 2
      final focusedBorder = decoration.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, equals(AppTheme.primaryBlue),
          reason: 'Focused state should have primaryBlue border');
      expect(focusedBorder.borderSide.width, equals(2.0),
          reason: 'Focused state should have 2.0 border width');
      break;

    case TextFieldState.error:
      // Error state: error color border
      final errorBorder = decoration.errorBorder as OutlineInputBorder;
      expect(errorBorder.borderSide.color, equals(AppTheme.error),
          reason: 'Error state should have error color border');
      expect(errorBorder.borderSide.width, equals(1.5),
          reason: 'Error state should have 1.5 border width');
      // Also verify error text is set
      expect(decoration.errorText, isNotNull,
          reason: 'Error state should have errorText set');
      break;

    case TextFieldState.disabled:
      // Disabled state: muted border and fill color
      final disabledBorder = decoration.disabledBorder as OutlineInputBorder;
      final expectedBorderColor = (isDark ? AppTheme.dividerDark : AppTheme.dividerLight).withOpacity(0.5);
      expect(disabledBorder.borderSide.color, equals(expectedBorderColor),
          reason: 'Disabled state should have muted border color');
      
      // Verify fill color is muted
      final fillColor = decoration.fillColor;
      expect(fillColor, isNotNull, reason: 'Disabled state should have fill color');
      // The fill color should have reduced opacity
      expect(fillColor!.opacity, lessThan(1.0),
          reason: 'Disabled state fill color should have reduced opacity');
      break;
  }
}

/// Verifies the label color is correct for the given state
Future<void> _verifyLabelColor(
  WidgetTester tester,
  TextFieldState state, {
  required bool isDark,
}) async {
  final labelFinder = find.text('Label');
  expect(labelFinder, findsOneWidget, reason: 'Label should be present');
  
  final labelWidget = tester.widget<Text>(labelFinder);
  final labelColor = labelWidget.style?.color;
  
  expect(labelColor, isNotNull, reason: 'Label should have a color');

  switch (state) {
    case TextFieldState.normal:
      final expectedColor = isDark ? AppTheme.textDark : AppTheme.textPrimary;
      expect(labelColor, equals(expectedColor),
          reason: 'Normal state label should have ${isDark ? "textDark" : "textPrimary"} color');
      break;

    case TextFieldState.focused:
      expect(labelColor, equals(AppTheme.primaryBlue),
          reason: 'Focused state label should have primaryBlue color');
      break;

    case TextFieldState.error:
      expect(labelColor, equals(AppTheme.error),
          reason: 'Error state label should have error color');
      break;

    case TextFieldState.disabled:
      final expectedColor = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary;
      expect(labelColor, equals(expectedColor),
          reason: 'Disabled state label should have ${isDark ? "textSecondaryDark" : "textSecondary"} color');
      break;
  }
}
