import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';

/// Test screen to verify theme switching functionality
class ThemeTestScreen extends StatelessWidget {
  const ThemeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Theme Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Theme',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Mode: ${_getThemeModeName(state.themeMode)}'),
                        Text('Brightness: ${Theme.of(context).brightness}'),
                        Text('Primary Color: ${Theme.of(context).colorScheme.primary}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Theme Switching Buttons
                Text(
                  'Switch Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SettingsBloc>().add(
                      const SetThemeModeEvent(ThemeMode.light),
                    );
                  },
                  icon: const Icon(Icons.light_mode),
                  label: const Text('Light Theme'),
                  style: ElevatedButton.styleFrom(
                    
                    backgroundColor: state.themeMode == ThemeMode.light
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: state.themeMode == ThemeMode.light
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SettingsBloc>().add(
                      const SetThemeModeEvent(ThemeMode.dark),
                    );
                  },
                  icon: const Icon(Icons.dark_mode),
                  label: const Text('Dark Theme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.themeMode == ThemeMode.dark
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: state.themeMode == ThemeMode.dark
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SettingsBloc>().add(
                      const SetThemeModeEvent(ThemeMode.system),
                    );
                  },
                  icon: const Icon(Icons.brightness_auto),
                  label: const Text('System Theme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.themeMode == ThemeMode.system
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: state.themeMode == ThemeMode.system
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Theme Components Demo
                Text(
                  'Theme Components',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is a sample card to demonstrate theme colors and typography.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Primary Button'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Secondary Button'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Color Palette
                Text(
                  'Color Palette',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorSwatch(
                      color: Theme.of(context).colorScheme.primary,
                      label: 'Primary',
                    ),
                    _ColorSwatch(
                      color: Theme.of(context).colorScheme.secondary,
                      label: 'Secondary',
                    ),
                    _ColorSwatch(
                      color: Theme.of(context).colorScheme.tertiary,
                      label: 'Tertiary',
                    ),
                    _ColorSwatch(
                      color: Theme.of(context).colorScheme.error,
                      label: 'Error',
                    ),
                    _ColorSwatch(
                      color: Theme.of(context).colorScheme.surface,
                      label: 'Surface',
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Instructions
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Tap the theme buttons above to switch themes\n'
                          '2. Notice how colors and brightness change\n'
                          '3. Check if theme persists after app restart\n'
                          '4. Test system theme by changing device theme',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSwatch({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
