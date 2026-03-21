import 'package:afc/presentation/blocs/home/home_bloc.dart';
import 'package:afc/presentation/blocs/home/stats_state.dart';
import 'package:afc/presentation/blocs/home/transaction_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeBloc', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state has both sub-states as initial', () async {
      // Arrange & Act
      final HomeBloc bloc = HomeBloc(firestore: fakeFirestore);

      // Assert
      expect(
        bloc.state,
        const HomeState(
          transactionState: LastTransactionState.initial(),
          statsState: StatsState.initial(),
        ),
      );
      await bloc.close();
    });

    group('HomeEvent.loadHome', () {
      blocTest<HomeBloc, HomeState>(
        'emits no new state when user has no matching data in Firestore',
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-with-no-data')),
        expect: () => <HomeState>[],
      );

      blocTest<HomeBloc, HomeState>(
        'completes without throwing when Firestore has data for user',
        setUp: () async {
          await fakeFirestore.collection('category').add(<String, Object>{
            'uuid': 'user-1',
            'month': 'january',
            'type': 'expense',
            'amount': 200.0,
          });
        },
        build: () => HomeBloc(firestore: fakeFirestore),
        act: (HomeBloc bloc) =>
            bloc.add(const HomeEvent.loadHome('user-1')),
        expect: () => <HomeState>[],
        errors: () => isEmpty,
      );
    });
  });
}
