import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entity/transaction_entity.dart';
import '../../domain/usecase/csv_exporter.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/feedback/feedback_cubit.dart';
import '../blocs/settings/settings_cubit.dart';
import '../blocs/theme/theme_cubit.dart';
import '../widgets/design_system.dart';
import 'feedback_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
    unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = context.read<AuthBloc>().state;
    final ClerkAuthState? clerkState = authState.whenOrNull(
      signedIn: (ClerkAuthState s) => s,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SectionHeader(label: 'Perfil'),
              _ProfileCard(clerkState: clerkState),
              const Gap(24),
              const _SectionHeader(label: 'Aparência'),
              const _AppearanceCard(),
              const Gap(24),
              const _SectionHeader(label: 'Notificações'),
              const _NotificationsCard(),
              const Gap(24),
              const _SectionHeader(label: 'Dados'),
              _DataCard(userId: clerkState?.user?.id ?? ''),
              const Gap(24),
              const _SectionHeader(label: 'Sobre'),
              _AboutCard(appVersion: _appVersion),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: DestructiveButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEvent.signOut());
                    context.go('/');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(AppIcons.logout, size: 18),
                      Gap(8),
                      Text('Sair da conta'),
                    ],
                  ),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: AppTextStyles.sectionTitle),
  );
}

// ---------------------------------------------------------------------------
// Profile
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.clerkState});

  final ClerkAuthState? clerkState;

  @override
  Widget build(BuildContext context) {
    final String firstName = clerkState?.user?.firstName ?? '';
    final String lastName = clerkState?.user?.lastName ?? '';
    final String fullName = <String>[
      firstName,
      lastName,
    ].where((String s) => s.isNotEmpty).join(' ');
    final String displayName = fullName.isNotEmpty ? fullName : 'Usuário';
    final String? email = clerkState?.user?.email;
    final String? imageUrl = clerkState?.user?.imageUrl;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          _Avatar(imageUrl: imageUrl, name: displayName),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(displayName, style: AppTextStyles.title),
                if (email != null && email.isNotEmpty) ...<Widget>[
                  const Gap(4),
                  Text(
                    email,
                    style: AppTextStyles.label.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _InitialsAvatar(name: name),
        ),
      );
    }
    return _InitialsAvatar(name: name);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  String get _initials {
    final List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      _initials,
      style: const TextStyle(
        color: AppColors.onPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Appearance
// ---------------------------------------------------------------------------

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<ThemeCubit, ThemePreference>(
    builder: (BuildContext context, ThemePreference preference) => AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Tema', style: AppTextStyles.bodyBold),
          const Gap(12),
          Row(
            children: <Widget>[
              _ThemeChip(
                label: 'Sistema',
                selected: preference == ThemePreference.system,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemePreference.system),
              ),
              const Gap(8),
              _ThemeChip(
                label: 'Claro',
                selected: preference == ThemePreference.light,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemePreference.light),
              ),
              const Gap(8),
              _ThemeChip(
                label: 'Escuro',
                selected: preference == ThemePreference.dark,
                onTap: () =>
                    context.read<ThemeCubit>().setTheme(ThemePreference.dark),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.mutedLight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTextStyle.sizeSm,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.onPrimary : AppColors.muted,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) => AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _ToggleRow(
                label: 'Lembretes de contas',
                subtitle: 'Aviso 3 dias antes do vencimento',
                value: state.billReminders,
                onChanged: (bool v) =>
                    context.read<SettingsCubit>().setBillReminders(value: v),
              ),
              const Divider(),
              _ToggleRow(
                label: 'Alertas de overspend',
                subtitle: 'Quando ultrapassar um limite de categoria',
                value: state.overspendAlerts,
                onChanged: (bool v) =>
                    context.read<SettingsCubit>().setOverspendAlerts(value: v),
              ),
              const Divider(),
              _ToggleRow(
                label: 'Resumo semanal',
                subtitle: 'Score de saúde financeira todo domingo',
                value: state.weeklyDigest,
                onChanged: (bool v) =>
                    context.read<SettingsCubit>().setWeeklyDigest(value: v),
              ),
            ],
          ),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTextStyles.bodyBold),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _DataCard extends StatelessWidget {
  const _DataCard({required this.userId});

  final String userId;

  Future<void> _exportCsv(BuildContext context) async {
    if (userId.isEmpty) {
      return;
    }
    try {
      final QuerySnapshot<Map<String, dynamic>> txSnap = await FirebaseFirestore
          .instance
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .get();
      final List<TransactionEntity> transactions = txSnap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                TransactionEntity.fromJson(d.data()),
          )
          .toList();

      final QuerySnapshot<Map<String, dynamic>> catSnap =
          await FirebaseFirestore.instance.collection('category').get();
      final Map<String, String> categoryNames = <String, String>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> d
            in catSnap.docs)
          (d.data()['uuid'] as String? ?? ''): (d.data()['name'] as String? ?? ''),
      };

      final List<int> bytes = CsvExporter.export(transactions, categoryNames);
      final Directory dir = await getTemporaryDirectory();
      final String ts = DateTime.now().millisecondsSinceEpoch.toString();
      final File file = File('${dir.path}/afc_transacoes_$ts.csv');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'text/csv')],
        subject: 'Transações AFC',
      );
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e')),
        );
      }
    }
  }

  Future<void> _exportJson(BuildContext context) async {
    if (userId.isEmpty) {
      return;
    }
    try {
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures =
          <Future<QuerySnapshot<Map<String, dynamic>>>>[
        FirebaseFirestore.instance
            .collection('transaction')
            .where('userId', isEqualTo: userId)
            .get(),
        FirebaseFirestore.instance.collection('category').get(),
        FirebaseFirestore.instance
            .collection('limit')
            .where('userId', isEqualTo: userId)
            .get(),
        FirebaseFirestore.instance
            .collection('goal')
            .where('userId', isEqualTo: userId)
            .get(),
      ];

      final List<QuerySnapshot<Map<String, dynamic>>> results =
          await Future.wait(futures);

      final Map<String, dynamic> backup = <String, dynamic>{
        'exported_at': DateTime.now().toIso8601String(),
        'transactions': results[0]
            .docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
            .toList(),
        'categories': results[1]
            .docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
            .toList(),
        'limits': results[2]
            .docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
            .toList(),
        'goals': results[3]
            .docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.data())
            .toList(),
      };

      final String json = const JsonEncoder.withIndent('  ').convert(backup);
      final Directory dir = await getTemporaryDirectory();
      final String ts = DateTime.now().millisecondsSinceEpoch.toString();
      final File file = File('${dir.path}/afc_backup_$ts.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'application/json')],
        subject: 'Backup AFC',
      );
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar backup: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: <Widget>[
        _ActionRow(
          icon: AppIcons.export,
          label: 'Exportar transações (CSV)',
          onTap: () => unawaited(_exportCsv(context)),
        ),
        const Divider(),
        _ActionRow(
          icon: AppIcons.export,
          label: 'Exportar backup (JSON)',
          onTap: () => unawaited(_exportJson(context)),
        ),
        const Divider(),
        _ActionRow(
          icon: Icons.category_outlined,
          label: 'Gerenciar categorias',
          onTap: () => context.push('/lista-categorias'),
        ),
        const Divider(),
        _ActionRow(
          icon: AppIcons.balance,
          label: 'Carteiras de benefícios',
          onTap: () => context.push('/carteiras'),
        ),
        const Divider(),
        _ActionRow(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Sub-contas',
          onTap: () => context.push('/sub-contas'),
        ),
        const Divider(),
        _ActionRow(
          icon: AppIcons.bank,
          label: 'Contas conectadas',
          onTap: () => context.push('/contas-conectadas'),
        ),
        const Divider(),
        _ActionRow(
          icon: AppIcons.syncPending,
          label: 'Operações pendentes',
          onTap: () => context.push('/pendencias'),
        ),
        const Divider(),
        _ActionRow(
          icon: Icons.feedback_outlined,
          label: 'Enviar feedback',
          onTap: () => showFormSheet<void>(
            context,
            builder: (_) => BlocProvider<FeedbackCubit>(
              create: (_) => FeedbackCubit(),
              child: const FeedbackSheet(),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.muted),
          const Gap(12),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// About
// ---------------------------------------------------------------------------

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: <Widget>[
        _InfoRow(label: 'Versão', value: appVersion.isEmpty ? '—' : appVersion),
        const Divider(),
        _ActionRow(
          icon: AppIcons.info,
          label: 'Política de privacidade',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disponível em breve')),
          ),
        ),
        const Divider(),
        _ActionRow(
          icon: AppIcons.info,
          label: 'Termos de uso',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disponível em breve')),
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(value, style: AppTextStyles.body.copyWith(color: AppColors.muted)),
      ],
    ),
  );
}
