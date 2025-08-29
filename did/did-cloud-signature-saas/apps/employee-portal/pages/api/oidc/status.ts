import type { NextApiRequest, NextApiResponse } from 'next';

const ISSUER_URL =
  process.env.NEXT_PUBLIC_ISSUER_URL || 'http://localhost:3004';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    const { txId } = req.query;
    if (!txId || typeof txId !== 'string') return res.status(400).json({ error: 'txId required' });

    // change path here if your issuer uses a different endpoint:
    const r = await fetch(`${ISSUER_URL}/oidc/result?txId=${encodeURIComponent(txId)}`);
    const json = await r.json();
    res.status(r.status).json(json);
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}

