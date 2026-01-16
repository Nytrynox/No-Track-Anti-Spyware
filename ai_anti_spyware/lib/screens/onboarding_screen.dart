import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modern_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _OnboardPage(
        icon: Icons.shield_outlined,
        title: 'AI-Powered Protection',
        subtitle:
            'Real-time detection of spyware using advanced on-device intelligence.',
      ),
      _OnboardPage(
        icon: Icons.auto_awesome,
        title: 'Material You Design',
        subtitle:
            'Dynamic colors, modern gradients, and smooth animations for a delightful UX.',
      ),
      _OnboardPage(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy First',
        subtitle:
            'Scan permissions, network behavior, and install sources with full transparency.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  TextButton(onPressed: _skip, child: const Text('Skip')),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _index == pages.length - 1 ? _finish : _next,
                    icon: Icon(
                      _index == pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _index == pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ModernDashboardScreen()),
    );
  }

  void _skip() => _finish();
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withValues(alpha: 0.8), cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: cs.onPrimary, size: 72),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: cs.onSurfaceVariant),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
