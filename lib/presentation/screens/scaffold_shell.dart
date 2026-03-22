import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme/app_icons.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/recurring/recurring_cubit.dart';
import 'quick_add_sheet.dart';

class ScaffoldShell extends StatefulWidget {
  const ScaffoldShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldShell> createState() => _ScaffoldShellState();
}

class _ScaffoldShellState extends State<ScaffoldShell> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      if (!mounted) {
        return;
      }
      final String userId =
          context.read<AuthBloc>().state.whenOrNull(
                signedIn: (ClerkAuthState s) => s.user?.id,
              ) ??
          '';
      if (userId.isNotEmpty) {
        context.read<RecurringCubit>().checkAndMaterialise(userId);
      }
    });
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.navigationShell,
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showQuickAdd(context),
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: widget.navigationShell.currentIndex,
      onDestinationSelected: (int index) => widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      ),
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(AppIcons.home),
          selectedIcon: Icon(AppIcons.homeSelected),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.transactions),
          selectedIcon: Icon(AppIcons.transactionsSelected),
          label: 'Transações',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.categories),
          selectedIcon: Icon(AppIcons.categoriesSelected),
          label: 'Categorias',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.limits),
          selectedIcon: Icon(AppIcons.limitsSelected),
          label: 'Limites',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.recurring),
          selectedIcon: Icon(AppIcons.recurringSelected),
          label: 'Recorrências',
        ),
        NavigationDestination(
          icon: Icon(AppIcons.goals),
          selectedIcon: Icon(AppIcons.goalsSelected),
          label: 'Metas',
        ),
      ],
    ),
  );
}
