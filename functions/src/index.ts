import * as admin from 'firebase-admin';
import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { PluggyClient } from './pluggy/client';

admin.initializeApp();

const pluggyClientId = defineSecret('PLUGGY_CLIENT_ID');
const pluggyClientSecret = defineSecret('PLUGGY_CLIENT_SECRET');

function formatDate(date: Date): string {
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
}

async function getPluggyClient(): Promise<PluggyClient> {
  const client = new PluggyClient(
    pluggyClientId.value(),
    pluggyClientSecret.value(),
  );
  await client.authenticate();
  return client;
}

async function syncTransactionsForItem(
  client: PluggyClient,
  pluggyItemId: string,
  clerkUserId: string,
  daysBack: number,
): Promise<number> {
  const db = admin.firestore();
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - daysBack);

  const accounts = await client.getAccounts(pluggyItemId);

  // Build set of existing pluggy transaction IDs for this user
  const existingSnap = await db
    .collection('raw_transaction')
    .where('userId', '==', clerkUserId)
    .get();
  const existingIds = new Set<string>(
    existingSnap.docs.map((d) => d.data()['pluggyTransactionId'] as string),
  );

  let newCount = 0;
  const batch = db.batch();

  for (const account of accounts) {
    const transactions = await client.getTransactions(
      account.id,
      formatDate(from),
      formatDate(to),
    );

    for (const tx of transactions) {
      if (existingIds.has(tx.id)) {
        continue;
      }
      const ref = db.collection('raw_transaction').doc();
      batch.set(ref, {
        uuid: ref.id,
        userId: clerkUserId,
        pluggyTransactionId: tx.id,
        accountId: tx.accountId,
        amount: Math.abs(tx.amount),
        description: tx.description,
        date: tx.date,
        type: tx.type.toLowerCase(),
        status: 'pending',
        suggestedCategoryUuid: null,
      });
      newCount++;
    }
  }

  if (newCount > 0) {
    await batch.commit();
  }

  return newCount;
}

export const createConnectToken = onCall(
  { secrets: [pluggyClientId, pluggyClientSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const { itemId, clerkUserId } = request.data as {
      itemId?: string;
      clerkUserId: string;
    };

    const client = await getPluggyClient();
    const connectToken = await client.createConnectToken(itemId);

    return { connectToken };
  },
);

export const saveConnectedAccount = onCall(
  { secrets: [pluggyClientId, pluggyClientSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const { itemId, clerkUserId } = request.data as {
      itemId: string;
      clerkUserId: string;
    };

    const client = await getPluggyClient();
    const db = admin.firestore();

    const item = await client.getItem(itemId);

    const connectedAccountRef = db.collection('connected_account').doc();
    await connectedAccountRef.set({
      uuid: connectedAccountRef.id,
      userId: clerkUserId,
      pluggyItemId: itemId,
      institutionName: item.connector.name,
      institutionLogo: item.connector.imageUrl ?? null,
      lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'active',
    });

    const newTransactions = await syncTransactionsForItem(
      client,
      itemId,
      clerkUserId,
      90,
    );

    return { success: true, newTransactions };
  },
);

export const onPluggyWebhook = onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  const body = req.body as {
    event?: string;
    type?: string;
    data?: { item?: { id?: string } };
    itemId?: string;
  };

  const eventType = body.event ?? body.type ?? '';
  if (eventType !== 'item/updated' && eventType !== 'ITEM_UPDATED') {
    res.status(200).send('OK');
    return;
  }

  const pluggyItemId =
    body.itemId ?? body.data?.item?.id;

  if (!pluggyItemId) {
    res.status(400).send('Missing itemId');
    return;
  }

  const db = admin.firestore();
  const snap = await db
    .collection('connected_account')
    .where('pluggyItemId', '==', pluggyItemId)
    .limit(1)
    .get();

  if (snap.empty) {
    res.status(200).send('OK');
    return;
  }

  const accountDoc = snap.docs[0];
  const clerkUserId = accountDoc.data()['userId'] as string;

  try {
    const client = await getPluggyClient();
    await syncTransactionsForItem(client, pluggyItemId, clerkUserId, 30);
    await accountDoc.ref.update({
      lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    console.error('Webhook sync error:', err);
  }

  res.status(200).send('OK');
});

export const syncUserItems = onCall(
  { secrets: [pluggyClientId, pluggyClientSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const { clerkUserId } = request.data as { clerkUserId: string };

    const db = admin.firestore();
    const snap = await db
      .collection('connected_account')
      .where('userId', '==', clerkUserId)
      .where('status', '==', 'active')
      .get();

    const client = await getPluggyClient();
    let synced = 0;

    for (const doc of snap.docs) {
      const pluggyItemId = doc.data()['pluggyItemId'] as string;
      try {
        await syncTransactionsForItem(client, pluggyItemId, clerkUserId, 30);
        await doc.ref.update({
          lastSyncedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        synced++;
      } catch (err) {
        console.error(`Error syncing item ${pluggyItemId}:`, err);
      }
    }

    return { synced };
  },
);

export const deleteConnectedAccount = onCall(
  { secrets: [pluggyClientId, pluggyClientSecret] },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const { accountUuid, clerkUserId } = request.data as {
      accountUuid: string;
      clerkUserId: string;
    };

    const db = admin.firestore();
    const snap = await db
      .collection('connected_account')
      .where('uuid', '==', accountUuid)
      .where('userId', '==', clerkUserId)
      .limit(1)
      .get();

    if (snap.empty) {
      throw new HttpsError('not-found', 'Connected account not found.');
    }

    const accountDoc = snap.docs[0];
    const pluggyItemId = accountDoc.data()['pluggyItemId'] as string;

    try {
      const client = await getPluggyClient();
      await client.deleteItem(pluggyItemId);
    } catch (err) {
      console.error('Error deleting Pluggy item:', err);
    }

    await accountDoc.ref.delete();

    return { success: true };
  },
);
