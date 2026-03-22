import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_spacing.dart';

/// First-run onboarding experience shown before the main app shell.
///
/// Displays a 4-page paged scroll view with brand illustrations and feature
/// highlights. On completion (or skip) it writes the done flag to
/// SharedPreferences so subsequent launches go straight to `/home`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String keyDone = 'onboarding_done';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Bem-vindo ao AFC',
      body:
          'Gerencie suas finanças pessoais de forma simples, segura e inteligente.',
    ),
    _OnboardingPage(
      icon: Icons.receipt_long_outlined,
      title: 'Controle seus gastos',
      body:
          'Registre transações, defina categorias e acompanhe tudo em tempo real.',
    ),
    _OnboardingPage(
      icon: Icons.savings_outlined,
      title: 'Alcance suas metas',
      body:
          'Crie metas financeiras e veja seu progresso crescer a cada contribuição.',
    ),
    _OnboardingPage(
      icon: Icons.favorite_outline,
      title: 'Saúde financeira',
      body:
          'Monitore seu score de saúde financeira e tome decisões mais conscientes.',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _complete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.keyDone, true);
    if (mounted) {
      context.go('/home');
    }
  }

  void _next() {
    if (_isLastPage) {
      unawaited(_complete());
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: _complete,
              child: const Text(
                'Pular',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (int page) =>
                  setState(() => _currentPage = page),
              itemBuilder: (BuildContext ctx, int index) =>
                  _pages[index].build(ctx),
            ),
          ),
          _DotIndicator(count: _pages.length, current: _currentPage),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isLastPage ? 'Começar' : 'Próximo',
                  style: const TextStyle(
                    fontSize: AppTextStyle.sizeLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Page data
// ---------------------------------------------------------------------------

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(0x1A),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 60, color: AppColors.primary),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppTextStyle.sizeXxl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppTextStyle.sizeMd,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Dot indicator
// ---------------------------------------------------------------------------

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      for (int i = 0; i < count; i++) ...<Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: i == current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.mutedLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (i < count - 1) const SizedBox(width: 6),
      ],
    ],
  );
}
