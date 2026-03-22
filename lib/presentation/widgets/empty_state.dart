import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Column;

const Color _mutedColor = Color(0xFF888888);

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 48, color: _mutedColor),
          const Gap(12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _mutedColor),
          ),
        ],
      ),
    ),
  );
}
