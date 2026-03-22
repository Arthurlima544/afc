// FCM Service stub for bill reminders.
//
// Architecture overview:
// - A Cloud Function (see functions/src/billReminders.ts) runs on a daily
//   schedule via Firebase Cloud Scheduler.
// - For each user, it queries the `bill` Firestore collection and finds bills
//   whose `dueDay` equals today's date + 3 days.
// - For each matching bill, it sends a push notification via FCM using the
//   user's device token stored in the `fcm_token` Firestore collection.
//
// Flutter side integration steps (not yet wired):
// 1. Add `firebase_messaging` to pubspec.yaml dependencies.
// 2. Request notification permissions on app startup (iOS requires explicit
//    permission; Android 13+ requires POST_NOTIFICATIONS).
// 3. Call `FirebaseMessaging.instance.getToken()` and persist the token to
//    Firestore under `fcm_token/{userId}`.
// 4. Handle foreground messages via `FirebaseMessaging.onMessage.listen(...)`.
// 5. Handle background/terminated messages via
//    `FirebaseMessaging.onBackgroundMessage(...)` with a top-level handler.
// 6. Add google-services.json (Android) and GoogleService-Info.plist (iOS)
//    from the Firebase console.
// 7. Update AndroidManifest.xml and iOS Info.plist with the required keys.
//
// This file is intentionally left as a stub. Wiring FCM requires native
// platform configuration that is outside the scope of this feature.

abstract final class FcmService {
  // Placeholder — no implementation until platform config is in place.
}
