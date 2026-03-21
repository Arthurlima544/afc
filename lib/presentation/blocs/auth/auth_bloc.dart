import 'package:bloc/bloc.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    Future<void> Function()? onFirebaseSignIn,
    Future<void> Function()? onFirebaseSignOut,
  }) : _onFirebaseSignIn = onFirebaseSignIn ?? _noOp,
       _onFirebaseSignOut = onFirebaseSignOut ?? _noOp,
       super(const _Initial()) {
    on<AuthEvent>((AuthEvent event, Emitter<AuthState> emit) async {
      await event.map(
        started: (_Started e) async {
          emit(const AuthState.unknown());
        },
        signIn: (_SignIn e) async {
          await _onFirebaseSignIn();
          emit(AuthState.signedIn(e.authState));
        },
        signOut: (_SignOut e) async {
          await _onFirebaseSignOut();
          emit(const AuthState.signedOut());
        },
      );
    });
  }

  final Future<void> Function() _onFirebaseSignIn;
  final Future<void> Function() _onFirebaseSignOut;

  static Future<void> _noOp() async {}
}
