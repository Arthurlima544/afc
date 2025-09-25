import 'package:bloc/bloc.dart';
import 'package:clerk_flutter/clerk_flutter.dart' show ClerkAuthState;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  void signOut() {
    emit(const AuthState.signedOut());
  }

  void signIn(ClerkAuthState authState) {
    emit(AuthState.signedIn(authState));
  }
}
