import type { NextApiRequest, NextApiResponse } from 'next';
import { ISSUER_URL } from '../../../src/lib/env';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (req.method !== 'POST') return res.status(405).end();
    // body can include orgId, template, claims etc.
    const body = req.body || {};
    // change path here if your issuer uses a different endpoint:
    const r = await fetch(`${ISSUER_URL}/oidc/offer`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(body),
    });
    const json = await r.json();
    res.status(r.status).json(json);
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}

