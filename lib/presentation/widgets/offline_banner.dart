import 'package:flutter/material.dart';

import '../../utils/connectivity_service.dart';
import 'design_system.dart';

/// Amber sticky banner that appears at the top of the scaffold whenever the
/// device has no internet connection.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: ConnectivityService.instance.onlineStream,
    initialData: ConnectivityService.instance.isOnline,
    builder: (BuildContext context, AsyncSnapshot<bool> snap) {
      final bool isOnline = snap.data ?? true;
      return Column(
        children: <Widget>[
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isOnline
                ? const SizedBox.shrink()
                : const _BannerContent(),
          ),
          Expanded(child: child),
        ],
      );
    },
  );
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: AppColors.warningBackground,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Row(
      children: <Widget>[
        Icon(
          Icons.wifi_off_outlined,
          size: 16,
          color: AppColors.warningText,
        ),
        Gap(8),
        Expanded(
          child: Text(
            'Sem conexão — dados serão sincronizados quando a internet voltar',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.warningText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A placeholder card shown in place of features that require internet access.
class OfflineUnavailableCard extends StatelessWidget {
  const OfflineUnavailableCard({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.wifi_off_outlined, size: 36, color: AppColors.muted),
        const Gap(12),
        Text(
          message ?? 'Disponível apenas com conexão à internet',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
