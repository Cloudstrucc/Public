import express from 'express';
import cors from 'cors';
import { createDIDAgent } from '@saas/agent';
import { registerOidc4vciRoutes } from './oidc4vci';

const app = express();
const PORT = Number(process.env.PORT || 3004);

// Public origin for deep links / metadata (e.g., your ngrok URL). Falls back to http://localhost:3004
const ISSUER_PUBLIC_ORIGIN =
  (process.env.ISSUER_ORIGIN || process.env.ISSUER_PUBLIC_ORIGIN || '').replace(/\/+$/, '') ||
  `http://localhost:${PORT}`;

app.use(cors());
app.use(express.json());

const agent = createDIDAgent();
let issuerDid: string;

/** Create or load an issuer DID once, at boot */
async function initIssuerDid() {
  // try a stable alias first so we reuse the same DID across restarts
  const alias = 'issuer';
  try {
    const found = await agent.didManagerFind({ alias });
    if (found?.length) {
      issuerDid = found[0].did;
      return;
    }
  } catch { /* ignore */ }

  const id = await agent.didManagerGetOrCreate({ alias, provider: 'did:key' });
  issuerDid = id.did;
}

app.get('/health', (_req, res) => res.json({ ok: true }));

app.get('/issuer-did', (_req, res) => {
  if (!issuerDid) return res.status(503).json({ error: 'issuer not ready' });
  res.json({ issuerDid });
});

app.post('/issue', async (req, res) => {
  try {
    if (!issuerDid) return res.status(503).json({ error: 'issuer not ready' });

    const { subject, claims, expiresInMinutes = 60 } = req.body || {};
    if (!subject || typeof subject !== 'string') {
      return res.status(400).json({ error: 'subject (holder DID) is required' });
    }

    const now = new Date();
    const exp = new Date(now.getTime() + Number(expiresInMinutes) * 60_000);

    const credential = {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      type: ['VerifiableCredential', 'EmployeeCredential'],
      issuer: { id: issuerDid },
      issuanceDate: now.toISOString(),
      expirationDate: exp.toISOString(),
      credentialSubject: { id: subject, ...(claims || {}) },
    };

    const result = await agent.createVerifiableCredential({
      credential,
      proofFormat: 'jwt',
    });

    // Normalize result across veramo versions
    const vcJwt =
      (typeof result === 'string' && result) ||
      (result && (result as any).jwt) ||
      (result && (result as any).verifiableCredential) ||
      (result && (result as any).vc) ||
      (result && (result as any).proof && (result as any).proof.jwt) ||
      null;

    if (!vcJwt || typeof vcJwt !== 'string') {
      console.error('createVerifiableCredential returned unexpected shape:', result);
      return res.status(500).json({ error: 'Failed to create JWT VC (unexpected result shape)' });
    }

    res.json({ vc: vcJwt, issuerDid });
  } catch (error: any) {
    console.error('Error issuing credential:', error);
    res.status(500).json({ error: String(error?.message || error) });
  }
});

// 🔗 Register OIDC4VCI routes (well-known, offer, token, credential)
registerOidc4vciRoutes(app, agent, ISSUER_PUBLIC_ORIGIN);

app.listen(PORT, async () => {
  await initIssuerDid();
  console.log(`VC Issuer API running on port ${PORT} with issuer ${issuerDid}`);
});
