import 'package:flutter/material.dart';
import 'package:flutter_pluggy_connect/flutter_pluggy_connect.dart';
import 'package:go_router/go_router.dart';

import '../../utils/logger.dart';

class ConnectBankScreen extends StatelessWidget {
  const ConnectBankScreen({required this.connectToken, super.key});

  final String connectToken;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: PluggyConnect(
          connectToken: connectToken,
          includeSandbox: true,
          onSuccess: (dynamic itemData) {
            logger.d('ConnectBankScreen — onSuccess: $itemData');
            String? itemId;
            if (itemData is Map) {
              itemId =
                  (itemData['item'] as Map<dynamic, dynamic>?)?['id']
                      as String?;
              itemId ??= itemData['itemId'] as String?;
            }
            if (itemId != null && context.mounted) {
              context.pop(itemId);
            }
          },
          onError: (dynamic error) {
            logger.e('ConnectBankScreen — onError: $error');
            if (context.mounted) {
              context.pop<String?>();
            }
          },
          onClose: () {
            if (context.mounted) {
              context.pop<String?>();
            }
          },
        ),
      );
}
