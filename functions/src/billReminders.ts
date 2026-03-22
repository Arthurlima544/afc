import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';

/**
 * Scheduled Cloud Function: sendBillReminders
 *
 * Runs every day at 09:00 UTC.
 * Finds all bills due in exactly 3 days and sends a push notification
 * via FCM to the user's registered device token.
 *
 * Firestore schema expected:
 *   bill/{docId}  — { uuid, userId, name, amount, dueDay, categoryUuid }
 *   fcm_token/{userId} — { token: string }
 */
export const sendBillReminders = onSchedule('every day 09:00', async () => {
  const db = admin.firestore();
  const messaging = admin.messaging();

  const now = new Date();
  const targetDay = now.getDate() + 3;

  // Query bills whose dueDay matches the target day
  const snap = await db
    .collection('bill')
    .where('dueDay', '==', targetDay)
    .get();

  if (snap.empty) {
    console.log('No bills due in 3 days.');
    return;
  }

  const notifications: Promise<void>[] = [];

  for (const doc of snap.docs) {
    const data = doc.data() as {
      userId: string;
      name: string;
      amount: number;
      dueDay: number;
    };

    const tokenSnap = await db
      .collection('fcm_token')
      .doc(data.userId)
      .get();

    if (!tokenSnap.exists) {
      continue;
    }

    const token = (tokenSnap.data() as { token: string }).token;

    const message: admin.messaging.Message = {
      token,
      notification: {
        title: 'Lembrete de conta',
        body: `"${data.name}" vence em 3 dias — R$ ${data.amount.toFixed(2)}`,
      },
      data: {
        billDueDay: String(data.dueDay),
        billName: data.name,
      },
    };

    notifications.push(
      messaging
        .send(message)
        .then(() => {
          console.log(`Notification sent for bill "${data.name}" to user ${data.userId}`);
        })
        .catch((err: unknown) => {
          console.error(
            `Failed to send notification for bill "${data.name}":`,
            err,
          );
        }),
    );
  }

  await Promise.all(notifications);
});
