import 'package:afc/presentation/blocs/feedback/feedback_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackCubit', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SharedPreferences fakePrefs;

    setUp(() async {
      // Stub PackageInfo platform channel.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/package_info'),
        (MethodCall call) async => <String, dynamic>{
          'appName': 'afc_test',
          'packageName': 'com.afc.test',
          'version': '1.0.0',
          'buildNumber': '1',
          'buildSignature': '',
          'installerStore': null,
        },
      );

      fakeFirestore = FakeFirebaseFirestore();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      fakePrefs = await SharedPreferences.getInstance();
    });

    FeedbackCubit buildCubit() => FeedbackCubit(
          firestore: fakeFirestore,
          prefs: fakePrefs,
        );

    test('initial state is FeedbackState.initial', () {
      final FeedbackCubit cubit = buildCubit();
      expect(cubit.state, const FeedbackState.initial());
      cubit.close();
    });

    group('submit', () {
      blocTest<FeedbackCubit, FeedbackState>(
        'emits [loading, success] on successful submit',
        build: buildCubit,
        act: (FeedbackCubit cubit) async => cubit.submit(
          userId: 'user-1',
          rating: 4,
          message: 'Ótimo app!',
        ),
        expect: () => const <FeedbackState>[
          FeedbackState.loading(),
          FeedbackState.success(),
        ],
      );

      test('persists feedback to Firestore', () async {
        final FeedbackCubit cubit = buildCubit();
        await cubit.submit(userId: 'user-1', rating: 5);

        final QuerySnapshot<Map<String, dynamic>> snap =
            await fakeFirestore.collection('feedback').get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['userId'], 'user-1');
        expect(snap.docs.first.data()['rating'], 5);
        await cubit.close();
      });

      test('marks NPS prompt as shown after submit', () async {
        final FeedbackCubit cubit = buildCubit();
        await cubit.submit(userId: 'user-1', rating: 3);

        expect(fakePrefs.getBool('feedback_nps_shown'), isTrue);
        await cubit.close();
      });
    });

    group('NPS prompt logic', () {
      test('shouldShowNpsPrompt returns false when prompt already shown',
          () async {
        await fakePrefs.setBool('feedback_nps_shown', true);
        await fakePrefs.setInt(
          'feedback_first_launch_ms',
          DateTime.now()
              .subtract(const Duration(days: 10))
              .millisecondsSinceEpoch,
        );

        final FeedbackCubit cubit = buildCubit();
        expect(await cubit.shouldShowNpsPrompt(), isFalse);
        await cubit.close();
      });

      test('shouldShowNpsPrompt returns false before 7 days', () async {
        await fakePrefs.setInt(
          'feedback_first_launch_ms',
          DateTime.now()
              .subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
        );

        final FeedbackCubit cubit = buildCubit();
        expect(await cubit.shouldShowNpsPrompt(), isFalse);
        await cubit.close();
      });

      test('shouldShowNpsPrompt returns true after 7 days', () async {
        await fakePrefs.setInt(
          'feedback_first_launch_ms',
          DateTime.now()
              .subtract(const Duration(days: 8))
              .millisecondsSinceEpoch,
        );

        final FeedbackCubit cubit = buildCubit();
        expect(await cubit.shouldShowNpsPrompt(), isTrue);
        await cubit.close();
      });

      test('shouldShowNpsPrompt returns false when first launch not recorded',
          () async {
        final FeedbackCubit cubit = buildCubit();
        expect(await cubit.shouldShowNpsPrompt(), isFalse);
        await cubit.close();
      });

      test('recordFirstLaunch sets timestamp when not already set', () async {
        final FeedbackCubit cubit = buildCubit();
        await cubit.recordFirstLaunch();

        expect(fakePrefs.getInt('feedback_first_launch_ms'), isNotNull);
        await cubit.close();
      });

      test('recordFirstLaunch does not overwrite existing timestamp', () async {
        const int originalMs = 1000000000000;
        await fakePrefs.setInt('feedback_first_launch_ms', originalMs);

        final FeedbackCubit cubit = buildCubit();
        await cubit.recordFirstLaunch();

        expect(fakePrefs.getInt('feedback_first_launch_ms'), originalMs);
        await cubit.close();
      });

      test('dismissNpsPrompt marks prompt as shown', () async {
        final FeedbackCubit cubit = buildCubit();
        await cubit.dismissNpsPrompt();

        expect(fakePrefs.getBool('feedback_nps_shown'), isTrue);
        await cubit.close();
      });
    });
  });
}
