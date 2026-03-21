import 'package:afc/presentation/blocs/auth/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClerkAuthState extends Mock implements ClerkAuthState {}

void main() {
  group('AuthBloc', () {
    late MockClerkAuthState mockClerkAuthState;

    setUp(() {
      mockClerkAuthState = MockClerkAuthState();
    });

    test('initial state is AuthState.initial()', () {
      // Arrange & Act
      final AuthBloc bloc = AuthBloc();

      // Assert
      expect(bloc.state, const AuthState.initial());
      bloc.close();
    });

    group('AuthEvent.started', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unknown] when started event is added',
        build: AuthBloc.new,
        act: (AuthBloc bloc) => bloc.add(const AuthEvent.started()),
        expect: () => <AuthState>[const AuthState.unknown()],
      );
    });

    group('AuthEvent.signIn', () {
      blocTest<AuthBloc, AuthState>(
        'emits [signedIn] with clerk auth state when signIn event is added',
        build: AuthBloc.new,
        act: (AuthBloc bloc) =>
            bloc.add(AuthEvent.signIn(mockClerkAuthState)),
        expect: () => <AuthState>[AuthState.signedIn(mockClerkAuthState)],
      );
    });

    group('AuthEvent.signOut', () {
      blocTest<AuthBloc, AuthState>(
        'emits [signedOut] when signOut event is added',
        build: AuthBloc.new,
        act: (AuthBloc bloc) => bloc.add(const AuthEvent.signOut()),
        expect: () => <AuthState>[const AuthState.signedOut()],
      );
    });

    group('state transitions', () {
      blocTest<AuthBloc, AuthState>(
        'transitions from signedIn to signedOut on signOut',
        build: AuthBloc.new,
        seed: () => AuthState.signedIn(mockClerkAuthState),
        act: (AuthBloc bloc) => bloc.add(const AuthEvent.signOut()),
        expect: () => <AuthState>[const AuthState.signedOut()],
      );

      blocTest<AuthBloc, AuthState>(
        'transitions from signedOut to signedIn on signIn',
        build: AuthBloc.new,
        seed: () => const AuthState.signedOut(),
        act: (AuthBloc bloc) =>
            bloc.add(AuthEvent.signIn(mockClerkAuthState)),
        expect: () => <AuthState>[AuthState.signedIn(mockClerkAuthState)],
      );
    });
  });
}
