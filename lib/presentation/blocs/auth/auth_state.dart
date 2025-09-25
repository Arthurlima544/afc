part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.signedIn(ClerkAuthState authState) = _SignedIn;
  const factory AuthState.signedOut() = _SignedOut;
}
