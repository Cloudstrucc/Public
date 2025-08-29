import type { NextApiRequest, NextApiResponse } from 'next';
import { ISSUER_URL } from '../../src/env'; // create this small env helper

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const code = String(req.query.code || '');
  if (!code) return res.status(400).json({ error: 'code required' });

  try {
    const r = await fetch(`${ISSUER_URL}/oidc/dev/status?code=${encodeURIComponent(code)}`);
    const data = await r.json();
    res.status(r.status).json(data);
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}

