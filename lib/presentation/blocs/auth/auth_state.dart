part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.signedIn(ClerkAuthState authState) = _SignedIn;
  const factory AuthState.signedOut() = _SignedOut;
  const factory AuthState.unknown() = _Unknown;
}
