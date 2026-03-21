import 'package:flutter/material.dart'
    hide Colors, ButtonStyle, IconButton, LinearProgressIndicator;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    hide Column, Row, Expanded;
import 'package:webview_flutter/webview_flutter.dart';

class ConnectBankScreen extends StatefulWidget {
  const ConnectBankScreen({required this.connectToken, super.key});

  final String connectToken;

  @override
  State<ConnectBankScreen> createState() => _ConnectBankScreenState();
}

class _ConnectBankScreenState extends State<ConnectBankScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final String url = request.url;
            if (url.startsWith('pluggyafc://success')) {
              final Uri uri = Uri.parse(url);
              final String? itemId = uri.queryParameters['itemId'];
              if (mounted) {
                context.pop(itemId);
              }
              return NavigationDecision.prevent;
            }
            if (url.startsWith('pluggyafc://cancel')) {
              if (mounted) {
                context.pop<String?>();
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://connect.pluggy.ai'
          '?accessToken=${widget.connectToken}'
          '&clientFinishUrl=pluggyafc://success'
          '&clientCancelUrl=pluggyafc://cancel',
        ),
      );
  }

  @override
  Widget build(BuildContext context) => Material(
    child: SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                IconButton(
                  variance: const ButtonStyle.outline(),
                  onPressed: () => context.pop<String?>(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Gap(8),
                const Expanded(
                  child: Text(
                    'Conectar Banco',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    ),
  );
}
