// apps/admin-portal/pages/api/issue-offer.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { ISSUER_URL } from '../../src/lib/env';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end('Method Not Allowed');
  try {
    const r = await fetch(`${ISSUER_URL}/oidc/admin/create-offer`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(req.body ?? {}),
    });
    const text = await r.text();

    // attempt JSON, but if issuer returned HTML (error), bubble it up
    try {
      const data = JSON.parse(text);
      if (!r.ok) return res.status(r.status).json(data);
      return res.status(200).json(data);
    } catch {
      // non-JSON from issuer → forward as 502 for visibility
      return res.status(502).send(text);
    }
  } catch (e: any) {
    return res.status(500).json({ error: String(e?.message || e) });
  }
}
