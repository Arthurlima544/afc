# Pluggy Connect Widget — Debug Investigation

## Symptom
The Connect Widget shows:
> "Ops! Parece que você esqueceu de incluir o seu Connect Token ao iniciar o Pluggy Connect."

This happens both in Android WebView **and** when the URL is pasted directly into Chrome — ruling out any Flutter/WebView issue entirely. The token itself is being rejected.

## Key Evidence

| Observation | Implication |
|-------------|-------------|
| Same error in Chrome browser | NOT a WebView/Flutter problem |
| `{"detail":"event submission rejected with_reason: ProjectId"}` | Segment analytics: widget's project ID doesn't match the token's project |
| Only `createConnectToken` Firebase Function called | Token is generated, widget immediately rejects it |
| Token is 892-char JWT starting with `eyJ...` | Token shape is correct |
| Free plan → "Development Applications" → "Pluggy Demo App" | Development credentials |

---

## Root Cause Hypotheses

### 1. `clientId` is required in the Connect Widget URL ⭐ MOST LIKELY

Pluggy's Connect Widget needs to know **which client** is loading it so it can validate the token against the correct project. The `clientId` must be passed as an additional URL parameter.

Without `clientId`, the widget cannot look up project settings and rejects the token entirely.

**Fix**: Add `clientId` to the URL in `ConnectBankScreen`:
```dart
final Uri url = Uri.https(
  'connect.pluggy.ai',
  '/',
  <String, String>{
    'connectToken': widget.connectToken,
    'clientId': 'YOUR_PLUGGY_CLIENT_ID', // same value as PLUGGY_CLIENT_ID secret
  },
);
```

This requires passing the `clientId` from Flutter to the screen, or hardcoding it (not ideal for prod, but fine for testing).

---

### 2. Development credentials use a different Connect Widget URL

The Connect Widget at `connect.pluggy.ai` may only accept **production** tokens. Development/sandbox tokens might need:
- `https://sandbox.connect.pluggy.ai` (if Pluggy has a sandbox widget)
- Or a specific `env=development` URL param

**How to confirm**: In the Pluggy Dashboard under your "Pluggy Demo App", look for an integration guide or "Test Connect" button — it will show the exact URL format they expect for development.

---

### 3. Token field name mismatch

Our `client.ts` returns `res.data.accessToken`. If Pluggy's API response actually nests the token differently, we'd be sending `undefined`.

**How to verify**: Check Firebase Functions logs for the `createConnectToken` call and see if the function logged a valid token (the cubit logs the first 20 chars).

---

## Current Implementation (`client.ts` line 37)

```typescript
private readonly baseUrl = 'https://api.pluggy.ai'; // ✓ correct
```

Authentication flow:
1. `POST /auth` with `{clientId, clientSecret}` → `{apiKey}` ✓
2. `POST /connect_token` with `X-API-KEY` header → `{accessToken}` ✓
3. Token passed to Flutter as `connectToken` ✓
4. Used as `?connectToken=<token>` in Connect Widget URL ← possible issue here

---

## Action Plan

### Step 1 — Check Firebase Functions log for the actual token

```
firebase functions:log --only createConnectToken
```

Confirm the log shows `token received (892 chars): eyJhb...` (not `[EMPTY]` or short).

### Step 2 — Add `clientId` to the Connect Widget URL

This is the highest-probability fix. The `clientId` tells the widget which project to validate against.

In `connect_bank_screen.dart`, change the URL construction. But first, expose `clientId` from the Firebase Function or store it as a Flutter env var.

**Option A** — Return `clientId` from the Firebase Function alongside `connectToken`:
- Modify `createConnectToken` function to also return the `clientId`
- Pass it to `ConnectBankScreen` alongside `connectToken`
- Add it to the URL params

**Option B** — Add it to `.env`:
```
PLUGGY_CLIENT_ID=your_client_id_here
```
Then read it in Flutter and pass to the screen.

### Step 3 — Look in Pluggy Dashboard for the exact Connect Widget URL

Under "Development Applications" → "Pluggy Demo App" → integration docs or SDK guide. The dashboard should show the exact initialization snippet including the URL or JS snippet for mobile.

---

## Files to Modify

| File | Change needed |
|------|---------------|
| `functions/src/index.ts` | Return `clientId` from `createConnectToken` response |
| `lib/presentation/blocs/open_finance/open_finance_cubit.dart` | Store `clientId` from response |
| `lib/presentation/screens/connect_bank_screen.dart` | Accept + pass `clientId` in URL |
| `.env` | Add `PLUGGY_CLIENT_ID` (alternative approach) |
