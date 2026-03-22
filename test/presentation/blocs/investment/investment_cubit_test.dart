import 'package:afc/domain/entity/investment_entity.dart';
import 'package:afc/presentation/blocs/investment/investment_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvestmentCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    const InvestmentEntity tInvestment = InvestmentEntity(
      uuid: 'inv-1',
      userId: 'user-1',
      name: 'Petrobras',
      ticker: 'PETR4',
      type: 'stock',
      quantity: 100.0,
      avgCost: 30.0,
      currentPrice: 35.0,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is InvestmentState.initial', () {
      final InvestmentCubit cubit =
          InvestmentCubit(firestore: fakeFirestore);
      expect(cubit.state, const InvestmentState.initial());
      cubit.close();
    });

    group('loadInvestments', () {
      blocTest<InvestmentCubit, InvestmentState>(
        'emits [loading, listed([])] when no investments exist',
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.loadInvestments('user-1'),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.listed(<InvestmentEntity>[]),
        ],
      );

      blocTest<InvestmentCubit, InvestmentState>(
        'emits listed with seeded investments',
        setUp: () async {
          await fakeFirestore
              .collection('investment')
              .add(tInvestment.toJson());
        },
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.loadInvestments('user-1'),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.listed(<InvestmentEntity>[tInvestment]),
        ],
      );

      blocTest<InvestmentCubit, InvestmentState>(
        'does not include investments for other users',
        setUp: () async {
          await fakeFirestore.collection('investment').add(
            tInvestment.copyWith(userId: 'other-user').toJson(),
          );
        },
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.loadInvestments('user-1'),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.listed(<InvestmentEntity>[]),
        ],
      );
    });

    group('create', () {
      blocTest<InvestmentCubit, InvestmentState>(
        'emits [loading, success] when investment is created',
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async => cubit.create(tInvestment),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.success(tInvestment),
        ],
      );

      test('persists investment to Firestore collection', () async {
        final InvestmentCubit cubit =
            InvestmentCubit(firestore: fakeFirestore);

        await cubit.create(tInvestment);

        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore.collection('investment').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Petrobras');
        expect(snapshot.docs.first.data()['ticker'], 'PETR4');
        expect(snapshot.docs.first.data()['quantity'], 100.0);
        await cubit.close();
      });
    });

    group('updatePrice', () {
      blocTest<InvestmentCubit, InvestmentState>(
        'emits [loading, success] with updated price',
        setUp: () async {
          await fakeFirestore
              .collection('investment')
              .add(tInvestment.toJson());
        },
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.updatePrice('inv-1', 40.0),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          InvestmentState.success(tInvestment.copyWith(currentPrice: 40.0)),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('investment').get();
          expect(snap.docs.first.data()['currentPrice'], 40.0);
        },
      );

      blocTest<InvestmentCubit, InvestmentState>(
        'emits error when uuid not found',
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.updatePrice('non-existent', 99.0),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.error('Investimento não encontrado.'),
        ],
      );
    });

    group('delete', () {
      blocTest<InvestmentCubit, InvestmentState>(
        'delete removes investment from Firestore then reloads',
        setUp: () async {
          await fakeFirestore
              .collection('investment')
              .add(tInvestment.toJson());
        },
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async {
          await cubit.loadInvestments('user-1');
          await cubit.delete('inv-1', 'user-1');
        },
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          const InvestmentState.listed(<InvestmentEntity>[tInvestment]),
          const InvestmentState.loading(),
          const InvestmentState.listed(<InvestmentEntity>[]),
        ],
        verify: (_) async {
          final QuerySnapshot<Map<String, dynamic>> snap =
              await fakeFirestore.collection('investment').get();
          expect(snap.docs.isEmpty, isTrue);
        },
      );
    });

    group('update', () {
      blocTest<InvestmentCubit, InvestmentState>(
        'emits [loading, success] after updating investment',
        setUp: () async {
          await fakeFirestore
              .collection('investment')
              .add(tInvestment.toJson());
        },
        build: () => InvestmentCubit(firestore: fakeFirestore),
        act: (InvestmentCubit cubit) async =>
            cubit.update(tInvestment.copyWith(name: 'Vale')),
        expect: () => <InvestmentState>[
          const InvestmentState.loading(),
          InvestmentState.success(tInvestment.copyWith(name: 'Vale')),
        ],
      );
    });

    group('gain/loss calculation', () {
      test('gainLoss is positive when currentPrice > avgCost', () {
        const double qty = 10;
        const double avgCost = 50;
        const double currentPrice = 60;
        const double totalInvested = qty * avgCost;
        const double currentValue = qty * currentPrice;
        const double gainLoss = currentValue - totalInvested;
        expect(gainLoss, 100.0);
      });

      test('gainLossPct is 20% when gain is 100 on 500 invested', () {
        const double qty = 10;
        const double avgCost = 50;
        const double currentPrice = 60;
        const double totalInvested = qty * avgCost;
        const double currentValue = qty * currentPrice;
        const double gainLoss = currentValue - totalInvested;
        const double gainLossPct = gainLoss / totalInvested * 100;
        expect(gainLossPct, 20.0);
      });

      test('gainLoss is negative when currentPrice < avgCost', () {
        const double qty = 10;
        const double avgCost = 50;
        const double currentPrice = 40;
        const double totalInvested = qty * avgCost;
        const double currentValue = qty * currentPrice;
        const double gainLoss = currentValue - totalInvested;
        expect(gainLoss, -100.0);
      });

      test('gainLossPct is -20% when loss is 100 on 500 invested', () {
        const double qty = 10;
        const double avgCost = 50;
        const double currentPrice = 40;
        const double totalInvested = qty * avgCost;
        const double currentValue = qty * currentPrice;
        const double gainLoss = currentValue - totalInvested;
        const double gainLossPct = gainLoss / totalInvested * 100;
        expect(gainLossPct, -20.0);
      });

      test('gainLossPct is 0 when totalInvested is 0', () {
        const double totalInvested = 0.0;
        const double gainLoss = 0.0;
        const double gainLossPct = totalInvested > 0
            ? gainLoss / totalInvested * 100
            : 0;
        expect(gainLossPct, 0.0);
      });

      test('totalInvested and currentValue computed correctly for multiple', () {
        const List<InvestmentEntity> portfolio = <InvestmentEntity>[
          InvestmentEntity(
            uuid: 'a',
            userId: 'u1',
            name: 'A',
            type: 'stock',
            quantity: 10,
            avgCost: 50,
            currentPrice: 60,
          ),
          InvestmentEntity(
            uuid: 'b',
            userId: 'u1',
            name: 'B',
            type: 'crypto',
            quantity: 5,
            avgCost: 100,
            currentPrice: 80,
          ),
        ];
        final double totalInvested = portfolio.fold(
          0.0,
          (double sum, InvestmentEntity inv) =>
              sum + inv.quantity * inv.avgCost,
        );
        final double currentValue = portfolio.fold(
          0.0,
          (double sum, InvestmentEntity inv) =>
              sum + inv.quantity * inv.currentPrice,
        );
        expect(totalInvested, 1000.0);
        expect(currentValue, 1000.0);
        expect(currentValue - totalInvested, 0.0);
      });
    });
  });
}
