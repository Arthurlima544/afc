import 'package:afc/domain/usecase/category_seeder.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategorySeeder', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategorySeeder seeder;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      seeder = CategorySeeder(firestore: fakeFirestore);
    });

    test('seeds 14 categories on first call', () async {
      await seeder.seedIfNeeded('user-1');

      final snap = await fakeFirestore.collection('category').get();
      expect(snap.docs.length, 14);
    });

    test('sets seeded_categories flag in user_meta', () async {
      await seeder.seedIfNeeded('user-1');

      final meta =
          await fakeFirestore.collection('user_meta').doc('user-1').get();
      expect(meta.exists, isTrue);
      expect(meta.data()?['seeded_categories'], isTrue);
    });

    test('is idempotent — second call writes no extra categories', () async {
      await seeder.seedIfNeeded('user-1');
      await seeder.seedIfNeeded('user-1');

      final snap = await fakeFirestore.collection('category').get();
      expect(snap.docs.length, 14);
    });

    test('does nothing for empty userId', () async {
      await seeder.seedIfNeeded('');

      final snap = await fakeFirestore.collection('category').get();
      expect(snap.docs.isEmpty, isTrue);
    });

    test('seeds expected category names', () async {
      await seeder.seedIfNeeded('user-1');

      final snap = await fakeFirestore.collection('category').get();
      final List<String> names = snap.docs
          .map((d) => d.data()['name'] as String)
          .toList();

      expect(names, containsAll(<String>[
        'Alimentação',
        'Transporte',
        'Moradia',
        'Saúde',
        'Lazer',
        'Educação',
        'Vestuário',
        'Assinaturas',
        'Restaurantes',
        'Viagem',
        'Investimentos',
        'Salário',
        'Freelance',
        'Outros',
      ]));
    });

    test('different users each get their own 14 categories', () async {
      await seeder.seedIfNeeded('user-1');
      await seeder.seedIfNeeded('user-2');

      final snap = await fakeFirestore.collection('category').get();
      expect(snap.docs.length, 28);
    });
  });
}
