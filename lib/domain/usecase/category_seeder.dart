import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../entity/category_entity.dart';

// ---------------------------------------------------------------------------
// Default categories
// ---------------------------------------------------------------------------

/// Each entry is a (name, iconType) pair.
/// iconType indices map to the `_categoryIcons` list in home_page.dart:
///   0 share_outlined · 1 play_arrow · 2 local_taxi · 3 star_border
///   4 camera_alt · 5 calendar_month · 6 file_upload · 7 coffee
///   8 savings · 9 access_time · 10 heart_broken · 11 compare_arrows
const List<({String name, int iconType})> _kDefaults = <({
  String name,
  int iconType,
})>[
  (name: 'Alimentação', iconType: 7),
  (name: 'Transporte', iconType: 2),
  (name: 'Moradia', iconType: 8),
  (name: 'Saúde', iconType: 10),
  (name: 'Lazer', iconType: 1),
  (name: 'Educação', iconType: 9),
  (name: 'Vestuário', iconType: 3),
  (name: 'Assinaturas', iconType: 5),
  (name: 'Restaurantes', iconType: 7),
  (name: 'Viagem', iconType: 11),
  (name: 'Investimentos', iconType: 8),
  (name: 'Salário', iconType: 11),
  (name: 'Freelance', iconType: 6),
  (name: 'Outros', iconType: 0),
];

// ---------------------------------------------------------------------------
// Seeder
// ---------------------------------------------------------------------------

/// Seeds default categories for a user on their first sign-in.
///
/// Idempotent: a `user_meta/{userId}` document with `seeded_categories: true`
/// is written atomically with the batch — subsequent calls are no-ops.
class CategorySeeder {
  CategorySeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedIfNeeded(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    final DocumentReference<Map<String, dynamic>> metaRef =
        _firestore.collection('user_meta').doc(userId);

    final DocumentSnapshot<Map<String, dynamic>> meta = await metaRef.get();
    if (meta.exists && meta.data()?['seeded_categories'] == true) {
      return;
    }

    const Uuid uuid = Uuid();
    final WriteBatch batch = _firestore.batch();

    for (final ({String name, int iconType}) cat in _kDefaults) {
      final DocumentReference<Map<String, dynamic>> ref =
          _firestore.collection('category').doc();
      batch.set(
        ref,
        CategoryEntity(
          uuid: uuid.v1(),
          name: cat.name,
          iconType: cat.iconType,
        ).toJson(),
      );
    }

    batch.set(
      metaRef,
      <String, Object?>{'seeded_categories': true},
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
