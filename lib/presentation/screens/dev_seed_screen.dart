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
  _OpStatus _seedStatus = _OpStatus.idle;
  _OpStatus _clearStatus = _OpStatus.idle;
  _OpStatus _resetStatus = _OpStatus.idle;

  String? get _userId => context
      .read<AuthBloc>()
      .state
      .whenOrNull(signedIn: (ClerkAuthState s) => s.user?.id);

  Future<void> _seed() async {
    final String? userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _seedStatus = _OpStatus.error);
      return;
    }
    setState(() => _seedStatus = _OpStatus.loading);
    try {
      await DevSeeder.seed(userId);
      if (mounted) {
        setState(() => _seedStatus = _OpStatus.done);
      }
    } on Exception {
      if (mounted) {
        setState(() => _seedStatus = _OpStatus.error);
      }
    }
  }

  Future<void> _clear() async {
    final String? userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _clearStatus = _OpStatus.error);
      return;
    }
    setState(() => _clearStatus = _OpStatus.loading);
    try {
      await DevSeeder.clear(userId);
      if (mounted) {
        setState(() => _clearStatus = _OpStatus.done);
      }
    } on Exception {
      if (mounted) {
        setState(() => _clearStatus = _OpStatus.error);
      }
    }
  }

  Future<void> _reset() async {
    final String? userId = _userId;
    if (userId == null || userId.isEmpty) {
      setState(() => _resetStatus = _OpStatus.error);
      return;
    }
    setState(() => _resetStatus = _OpStatus.loading);
    try {
      await DevSeeder.clear(userId);
      await DevSeeder.seed(userId);
      if (mounted) {
        setState(() => _resetStatus = _OpStatus.done);
      }
    } on Exception {
      if (mounted) {
        setState(() => _resetStatus = _OpStatus.error);
      }
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
            // ── Header ──────────────────────────────────────────────────────
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            const Text(
              'Coleções cobertas: categorias, transações, limites, metas, '
              'investimentos, contas a pagar, recorrentes, templates, '
              'renda passiva, snapshots de patrimônio e watchlist.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const Gap(32),

            // ── Reset (clear + seed) ─────────────────────────────────────────
            const Text(
              'Reiniciar dados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Remove todos os dados do usuário atual e repopula com dados '
              'de exemplo realistas. Equivale a "Limpar" + "Popular" em sequência.',
            ),
            const Gap(16),
            _ActionRow(
              status: _resetStatus,
              loadingLabel: 'Reiniciando...',
              button: PrimaryButton(
                onPressed: _resetStatus == _OpStatus.loading ? null : _reset,
                child: const Text('Limpar e popular'),
              ),
              doneMessage: 'Dados reiniciados com sucesso!',
              errorMessage: 'Erro ao reiniciar dados. Verifique autenticação.',
            ),

            const Gap(32),
            const Divider(),
            const Gap(32),

            // ── Seed only ───────────────────────────────────────────────────
            const Text(
              'Popular dados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Insere dados de exemplo sem apagar o existente. '
              'Use "Reiniciar" se quiser começar do zero.',
            ),
            const Gap(16),
            _ActionRow(
              status: _seedStatus,
              loadingLabel: 'Populando...',
              button: SecondaryButton(
                onPressed: _seedStatus == _OpStatus.loading ? null : _seed,
                child: const Text('Apenas popular'),
              ),
              doneMessage: 'Dados inseridos com sucesso!',
              errorMessage: 'Erro ao inserir dados. Verifique autenticação.',
            ),

            const Gap(32),
            const Divider(),
            const Gap(32),

            // ── Clear only ──────────────────────────────────────────────────
            const Text(
              'Limpar dados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Remove todos os dados do usuário atual em todas as coleções, '
              'incluindo categorias compartilhadas.',
            ),
            const Gap(16),
            _ActionRow(
              status: _clearStatus,
              loadingLabel: 'Limpando...',
              button: DestructiveButton(
                onPressed: _clearStatus == _OpStatus.loading ? null : _clear,
                child: const Text('Apenas limpar'),
              ),
              doneMessage: 'Dados removidos com sucesso!',
              errorMessage: 'Erro ao remover dados. Verifique autenticação.',
            ),

            const Gap(32),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Action row widget
// ---------------------------------------------------------------------------

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.status,
    required this.loadingLabel,
    required this.button,
    required this.doneMessage,
    required this.errorMessage,
  });

  final _OpStatus status;
  final String loadingLabel;
  final Widget button;
  final String doneMessage;
  final String errorMessage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (status == _OpStatus.loading)
        Row(
          children: <Widget>[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const Gap(12),
            Text(loadingLabel, style: const TextStyle(color: AppColors.muted)),
          ],
        )
      else
        SizedBox(width: double.infinity, child: button),
      if (status == _OpStatus.done) ...<Widget>[
        const Gap(8),
        Text(doneMessage, style: const TextStyle(color: Colors.green)),
      ] else if (status == _OpStatus.error) ...<Widget>[
        const Gap(8),
        Text(errorMessage, style: const TextStyle(color: Colors.red)),
      ],
    ],
  );
}

enum _OpStatus { idle, loading, done, error }
