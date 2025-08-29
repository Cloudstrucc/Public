import express from 'express';
import cors from 'cors';
import { PolicyEngine } from '@saas/policy-engine';
// NEW ↓↓↓
import { verifyPresentation } from 'did-jwt-vc';
import { Resolver } from 'did-resolver';
import { getResolver as keyDidResolver } from 'key-did-resolver';
import { getResolver as webDidResolver } from 'web-did-resolver';

const app = express();
const PORT = process.env.PORT || 3005;

app.use(cors());
app.use(express.json());

const policyEngine = new PolicyEngine();

// simple challenge store (already in your file)
import crypto from 'crypto';
const challenges = new Map<string, { domain: string; expiresAt: number }>();
const CHALLENGE_TTL_MS = 5 * 60 * 1000;

app.get('/presentation-definition', (_req, res) => {
  const challenge = crypto.randomUUID();
  const domain = 'did-cloud-signature.local';
  challenges.set(challenge, { domain, expiresAt: Date.now() + CHALLENGE_TTL_MS });
  const presentation_definition = {
    id: 'pd-employee-credential',
    input_descriptors: [
      {
        id: 'employee-cred',
        name: 'Employee Credential',
        constraints: {
          fields: [
            { path: ['$.type'], filter: { type: 'array', contains: { const: 'EmployeeCredential' } } }
          ]
        }
      }
    ]
  };
  res.json({ presentation_definition, challenge, domain });
});

// REPLACED: verify VP via did-jwt-vc (JWT path, no LD plugin needed)
app.post('/verify', async (req, res) => {
  try {
    const { presentation, challenge, domain, context } = req.body;

    if (!presentation?.jwt) return res.status(400).json({ error: 'missing presentation.jwt' });
    if (!challenge || !domain) return res.status(400).json({ error: 'challenge and domain are required' });

    const record = challenges.get(challenge);
    if (!record) return res.status(400).json({ error: 'invalid challenge' });
    if (record.domain !== domain) return res.status(400).json({ error: 'domain mismatch' });
    if (record.expiresAt < Date.now()) return res.status(400).json({ error: 'challenge expired' });
    challenges.delete(challenge); // one-time use

    // DID resolver supporting did:key and did:web
    const resolver = new Resolver({
      ...keyDidResolver(),
      ...webDidResolver(),
    });

    // Verify the VP JWT
    const verified = await verifyPresentation(presentation.jwt, resolver, {
      challenge,
      audience: domain,
    });



    // (Optional) you can inspect verified.verifiablePresentation / payload here

    // TODO: extract claims from embedded VCs if you want policy on content
    const claims = {};

    const allowed = await policyEngine.evaluate({
      user: context?.user ?? { id: 'unknown', email: 'unknown', roles: [] },
      resource: context?.resource ?? 'unknown',
      action: context?.action ?? 'unknown',
      claims
    });

    res.json({ verified: true, allowed, details: verified });
  } catch (error: any) {
    console.error('Error verifying presentation:', error);
    res.status(500).json({ error: String(error?.message || error) });
  }
});

app.listen(PORT, () => {
  console.log(`VC Verifier API running on port ${PORT}`);
});

