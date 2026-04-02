import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'comprehensive_demo.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('FormStack'),
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader('Demos', theme),
                const SizedBox(height: 8),
                _DemoCard(
                  icon: Icons.all_inclusive,
                  color: const Color(0xFF6750A4),
                  title: 'All Input Types',
                  subtitle:
                      'All 20 input types: text, email, password, date, choices, OTP, smile, file, map, and more',
                  onTap: () => _navigate(context, const AllInputTypesDemo()),
                ),
                _DemoCard(
                  icon: Icons.palette_outlined,
                  color: const Color(0xFF006D3B),
                  title: 'Styles & Display Sizes',
                  subtitle:
                      'Input styles (basic, outline, underline), component styles, and 5 display sizes',
                  onTap: () =>
                      _navigate(context, const StylesAndDisplayDemo()),
                ),
                _DemoCard(
                  icon: Icons.checklist_rtl,
                  color: const Color(0xFF006493),
                  title: 'Selection Types',
                  subtitle:
                      'Arrow, tick, toggle, and dropdown selection styles for choice inputs',
                  onTap: () =>
                      _navigate(context, const SelectionTypesDemo()),
                ),
                _DemoCard(
                  icon: Icons.verified_user_outlined,
                  color: const Color(0xFFBA1A1A),
                  title: 'Validation & Custom Formats',
                  subtitle:
                      'Built-in validators: email, phone, URL, credit card, SSN, zip, age, percentage, custom',
                  onTap: () => _navigate(context, const ValidationDemo()),
                ),
                _DemoCard(
                  icon: Icons.account_tree_outlined,
                  color: const Color(0xFF7D5260),
                  title: 'Conditional Navigation',
                  subtitle:
                      'Dynamic form routing based on user selections using relevant conditions',
                  onTap: () =>
                      _navigate(context, const ConditionalNavDemo()),
                ),
                _DemoCard(
                  icon: Icons.view_agenda_outlined,
                  color: const Color(0xFF4E6356),
                  title: 'Nested Steps',
                  subtitle:
                      'Multiple input fields on a single screen with cross-field validation',
                  onTap: () => _navigate(context, const NestedStepsDemo()),
                ),
                _DemoCard(
                  icon: Icons.tune_outlined,
                  color: const Color(0xFF006874),
                  title: 'Pre-fill, Errors & Callbacks',
                  subtitle:
                      'setResult, setError, addCompletionCallback, onBeforeFinish, progress tracking',
                  onTap: () => _navigate(context, const APIFeaturesDemo()),
                ),
                _DemoCard(
                  icon: Icons.poll_outlined,
                  color: const Color(0xFF8B5000),
                  title: 'Survey Components',
                  subtitle:
                      'Slider, star rating, NPS, consent, signature, ranking, phone, currency',
                  onTap: () =>
                      _navigate(context, const SurveyComponentsDemo()),
                ),
                _DemoCard(
                  icon: Icons.data_object,
                  color: const Color(0xFF5C5D72),
                  title: 'Load from JSON',
                  subtitle:
                      'Build forms dynamically from JSON asset files with multi-form support',
                  onTap: () => _navigate(context, const JSONLoadDemo()),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader(this.title, this.theme);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
      child: Text(title,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DemoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
