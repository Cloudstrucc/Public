import express from 'express';
import cors from 'cors';
import { createDIDAgent } from '@saas/agent';

const app = express();
const PORT = process.env.PORT || 3004;

app.use(cors());
app.use(express.json());

const agent = createDIDAgent();
let issuerDid: string;

async function ensureIssuerDid() {
  const ALIAS = 'service-issuer';
  try {
    const list = await agent.didManagerFind({ alias: ALIAS });
    if (list.length) {
      issuerDid = list[0].did;
      return;
    }
  } catch { /* ignore */ }
  const identity = await agent.didManagerCreate({ provider: 'did:key', alias: ALIAS });
  issuerDid = identity.did;
}

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
      credentialSubject: { id: subject, ...(claims || {}) }
    };

    const result = await agent.createVerifiableCredential({
      credential,
      proofFormat: 'jwt'
    });

    // Robust extraction across library versions:
    const vcJwt =
      (typeof result === 'string' && result) ||                 // some versions return the jwt string
      (result && (result as any).jwt) ||                        // sometimes { jwt }
      (result && (result as any).verifiableCredential) ||       // sometimes { verifiableCredential: <jwt> }
      (result && (result as any).vc) ||                         // sometimes { vc: <jwt> }
      (result && (result as any).proof && (result as any).proof.jwt) || // VC object with proof.jwt  <-- your case
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


app.listen(PORT, async () => {
  await ensureIssuerDid();
  console.log(`VC Issuer API running on port ${PORT} with issuer ${issuerDid}`);
});

