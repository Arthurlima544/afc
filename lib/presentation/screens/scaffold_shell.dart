import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Transações',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: 'Categorias',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune),
          label: 'Limites',
        ),
        NavigationDestination(
          icon: Icon(Icons.repeat_outlined),
          selectedIcon: Icon(Icons.repeat),
          label: 'Recorrências',
        ),
      ],
    ),
  );
}
