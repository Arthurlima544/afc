import 'dart:async';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecase/category_seeder.dart';
import '../../utils/connectivity_service.dart';
import '../../utils/sync_queue.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/feedback/feedback_cubit.dart';
import '../blocs/recurring/recurring_cubit.dart';
import '../widgets/design_system.dart';
import 'feedback_sheet.dart';
import 'quick_add_sheet.dart';

class ScaffoldShell extends StatefulWidget {
  const ScaffoldShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldShell> createState() => _ScaffoldShellState();
}

class _ScaffoldShellState extends State<ScaffoldShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;
  StreamSubscription<bool>? _connectivitySub;

  @override
  void initState() {
    super.initState();

    // FAB pop-in animation on first load.
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();

    // Auto-flush SyncQueue when connectivity is restored.
    _connectivitySub = ConnectivityService.instance.onlineStream.listen(
      (bool isOnline) {
        if (isOnline && SyncQueue.instance.count > 0) {
          unawaited(SyncQueue.instance.flush());
        }
      },
    );

    Future<void>.microtask(() async {
      if (!mounted) {
        return;
      }
      final String userId =
          context.read<AuthBloc>().state.whenOrNull(
                signedIn: (ClerkAuthState s) => s.user?.id,
              ) ??
          '';
      if (userId.isNotEmpty) {
        unawaited(context.read<RecurringCubit>().checkAndMaterialise(userId));
        unawaited(CategorySeeder().seedIfNeeded(userId));
      }

      // NPS prompt: shown once after 7 days since first launch.
      final FeedbackCubit npcCubit = FeedbackCubit();
      await npcCubit.recordFirstLaunch();
      final bool showNps = await npcCubit.shouldShowNpsPrompt();
      if (!mounted) {
        return;
      }
      if (showNps) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => const NpsFeedbackPrompt(),
        );
      }
      unawaited(npcCubit.close());
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _showQuickAdd(BuildContext context) {
    final String userId =
        context.read<AuthBloc>().state.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
        '';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext sheetContext) => QuickAddSheet(
        userId: userId,
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }

  void _onTabSelected(int index) {
    unawaited(HapticFeedback.lightImpact());
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      body: OfflineBanner(child: widget.navigationShell),
      floatingActionButton: Semantics(
        label: 'Adicionar transação',
        child: ScaleTransition(
          scale: disableAnimations
              ? const AlwaysStoppedAnimation<double>(1.0)
              : _fabScale,
          child: FloatingActionButton(
            onPressed: () => _showQuickAdd(context),
            tooltip: 'Adicionar transação',
            child: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(AppIcons.home),
            selectedIcon: Icon(AppIcons.homeSelected),
            label: 'Início',
            tooltip: 'Início',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.transactions),
            selectedIcon: Icon(AppIcons.transactionsSelected),
            label: 'Transações',
            tooltip: 'Transações',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.limits),
            selectedIcon: Icon(AppIcons.limitsSelected),
            label: 'Limites',
            tooltip: 'Limites',
          ),
          NavigationDestination(
            icon: Icon(AppIcons.goals),
            selectedIcon: Icon(AppIcons.goalsSelected),
            label: 'Metas',
            tooltip: 'Metas',
          ),
        ],
      ),
    );
  }
}
