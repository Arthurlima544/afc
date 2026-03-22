import 'package:afc/domain/entity/template_entity.dart';
import 'package:afc/presentation/blocs/template/template_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TemplateEntity _template({
  String uuid = 'tpl-1',
  String title = 'Netflix',
  double amount = 49.9,
  String typeUuid = 'expense',
  String categoryUUid = 'cat-1',
}) =>
    TemplateEntity(
      uuid: uuid,
      userId: 'user-1',
      title: title,
      amount: amount,
      categoryUUid: categoryUUid,
      typeUuid: typeUuid,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TemplateCubit', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('initial state is TemplateState.initial()', () {
      final TemplateCubit cubit = TemplateCubit(firestore: fakeFirestore);
      expect(cubit.state, const TemplateState.initial());
      cubit.close();
    });

    // -----------------------------------------------------------------------
    // save
    // -----------------------------------------------------------------------

    blocTest<TemplateCubit, TemplateState>(
      'save emits [loading, success] and persists to Firestore',
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.save(_template()),
      expect: () => <TemplateState>[
        const TemplateState.loading(),
        TemplateState.success(_template()),
      ],
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('template')
            .where('uuid', isEqualTo: 'tpl-1')
            .get();
        expect(snap.docs, hasLength(1));
        expect(snap.docs.first.data()['title'], 'Netflix');
      },
    );

    // -----------------------------------------------------------------------
    // loadTemplates
    // -----------------------------------------------------------------------

    blocTest<TemplateCubit, TemplateState>(
      'loadTemplates emits [loading, listed([])] when no templates exist',
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.loadTemplates('user-1'),
      expect: () => <TemplateState>[
        const TemplateState.loading(),
        const TemplateState.listed(<TemplateEntity>[]),
      ],
    );

    blocTest<TemplateCubit, TemplateState>(
      'loadTemplates emits listed with seeded templates',
      setUp: () async {
        await fakeFirestore.collection('template').add(_template().toJson());
      },
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.loadTemplates('user-1'),
      verify: (TemplateCubit cubit) {
        cubit.state.whenOrNull(
          listed: (List<TemplateEntity> templates) {
            expect(templates, hasLength(1));
            expect(templates.first.uuid, 'tpl-1');
            expect(templates.first.title, 'Netflix');
          },
        );
      },
    );

    blocTest<TemplateCubit, TemplateState>(
      'loadTemplates returns only templates for the given userId',
      setUp: () async {
        await fakeFirestore.collection('template').add(_template().toJson());
        await fakeFirestore.collection('template').add(
          _template(uuid: 'tpl-other').toJson()..[  'userId'] = 'user-2',
        );
      },
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.loadTemplates('user-1'),
      verify: (TemplateCubit cubit) {
        cubit.state.whenOrNull(
          listed: (List<TemplateEntity> templates) {
            expect(templates, hasLength(1));
            expect(templates.first.uuid, 'tpl-1');
          },
        );
      },
    );

    // -----------------------------------------------------------------------
    // delete
    // -----------------------------------------------------------------------

    blocTest<TemplateCubit, TemplateState>(
      'delete removes template from Firestore',
      setUp: () async {
        await fakeFirestore.collection('template').add(_template().toJson());
      },
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.delete('tpl-1'),
      verify: (_) async {
        final QuerySnapshot<Map<String, dynamic>> snap = await fakeFirestore
            .collection('template')
            .where('uuid', isEqualTo: 'tpl-1')
            .get();
        expect(snap.docs, isEmpty);
      },
    );

    blocTest<TemplateCubit, TemplateState>(
      'delete is a no-op when uuid does not exist',
      build: () => TemplateCubit(firestore: fakeFirestore),
      act: (TemplateCubit cubit) => cubit.delete('nonexistent'),
      expect: () => <TemplateState>[],
    );
  });
}
