import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/feedback/feedback_cubit.dart';
import '../widgets/design_system.dart';

/// Bottom sheet for submitting in-app feedback (star rating + optional message).
///
/// Must be wrapped with a [BlocProvider<FeedbackCubit>] by the caller.
class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key});

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  int _rating = 0;
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      return;
    }
    final String userId = context
            .read<AuthBloc>()
            .state
            .whenOrNull(signedIn: (ClerkAuthState s) => s.user?.id) ??
        '';
    await context.read<FeedbackCubit>().submit(
          userId: userId,
          rating: _rating,
          message: _msgCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (BuildContext ctx, FeedbackState state) {
          state.whenOrNull(
            success: () => Navigator.of(ctx).pop(),
            error: (String msg) => ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(msg)),
            ),
          );
        },
        builder: (BuildContext ctx, FeedbackState state) {
          final bool loading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Enviar feedback',
                          style: AppTextStyles.heading,
                        ),
                      ),
                      AppIconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Gap(8),
                  const Text(
                    'Como você avalia o AFC?',
                    style: AppTextStyles.body,
                  ),
                  const Gap(16),
                  // Star rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: loading
                              ? null
                              : () => setState(() => _rating = i),
                          icon: Icon(
                            i <= _rating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: i <= _rating
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  const Gap(16),
                  AppTextField(
                    controller: _msgCtrl,
                    hintText: 'Comentário (opcional)',
                    maxLines: 3,
                    enabled: !loading,
                  ),
                  const Gap(20),
                  PrimaryButton(
                    onPressed: (_rating == 0 || loading) ? null : _submit,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar'),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

/// One-time NPS prompt shown after 7 days.
///
/// Wraps [FeedbackSheet] content inline so it can be displayed as a bottom
/// sheet without a separate route.
class NpsFeedbackPrompt extends StatelessWidget {
  const NpsFeedbackPrompt({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<FeedbackCubit>(
    create: (_) => FeedbackCubit(),
    child: const FeedbackSheet(),
  );
}
