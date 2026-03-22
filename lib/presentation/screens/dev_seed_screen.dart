import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../utils/seeder.dart';
import '../widgets/design_system.dart';

class DevSeedScreen extends StatefulWidget {
  const DevSeedScreen({super.key});

  @override
  State<DevSeedScreen> createState() => _DevSeedScreenState();
}

class _DevSeedScreenState extends State<DevSeedScreen> {
  _SeedStatus _seedStatus = _SeedStatus.idle;
  _ClearStatus _clearStatus = _ClearStatus.idle;

  String? get _userId => context
      .read<AuthBloc>()
      .state
      .whenOrNull(signedIn: (ClerkAuthState s) => s.user?.id);

  Future<void> _seed() async {
    final String? userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _seedStatus = _SeedStatus.error);
      return;
    }
    setState(() => _seedStatus = _SeedStatus.loading);
    try {
      await DevSeeder.seed(userId);
      setState(() => _seedStatus = _SeedStatus.done);
    } on Exception {
      setState(() => _seedStatus = _SeedStatus.error);
    }
  }

  Future<void> _clear() async {
    final String? userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _clearStatus = _ClearStatus.error);
      return;
    }
    setState(() => _clearStatus = _ClearStatus.loading);
    try {
      await DevSeeder.clear(userId);
      setState(() => _clearStatus = _ClearStatus.done);
    } on Exception {
      setState(() => _clearStatus = _ClearStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const Gap(8),
              const Expanded(
                child: Text(
                  '[DEV] Banco de dados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Gap(32),

          // ── Seed ──────────────────────────────────────────────────────────
          const Text(
            'Popular dados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          const Text(
            'Insere categorias, transações e limites de exemplo para o usuário atual.',
          ),
          const Gap(16),
          if (_seedStatus == _SeedStatus.loading)
            const Center(child: CircularProgressIndicator())
          else
            PrimaryButton(
              onPressed: _seed,
              child: const Text('Popular dados de exemplo'),
            ),
          const Gap(8),
          if (_seedStatus == _SeedStatus.done)
            const Text(
              'Dados inseridos com sucesso!',
              style: TextStyle(color: Colors.green),
            )
          else if (_seedStatus == _SeedStatus.error)
            const Text(
              'Erro ao inserir dados. Verifique se você está autenticado.',
              style: TextStyle(color: Colors.red),
            ),

          const Gap(32),
          const Divider(),
          const Gap(32),

          // ── Clear ─────────────────────────────────────────────────────────
          const Text(
            'Limpar dados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          const Text(
            'Remove todas as transações e limites do usuário atual, e todas as categorias.',
          ),
          const Gap(16),
          if (_clearStatus == _ClearStatus.loading)
            const Center(child: CircularProgressIndicator())
          else
            DestructiveButton(
              onPressed: _clear,
              child: const Text('Limpar todos os dados'),
            ),
          const Gap(8),
          if (_clearStatus == _ClearStatus.done)
            const Text(
              'Dados removidos com sucesso!',
              style: TextStyle(color: Colors.green),
            )
          else if (_clearStatus == _ClearStatus.error)
            const Text(
              'Erro ao remover dados. Verifique se você está autenticado.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    ),
  ),
);
}

enum _SeedStatus { idle, loading, done, error }

enum _ClearStatus { idle, loading, done, error }
