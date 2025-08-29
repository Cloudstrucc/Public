import type { NextApiRequest, NextApiResponse } from 'next';
const ISSUER_URL = process.env.ISSUER_API_URL ?? 'http://127.0.0.1:3004';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end();
  try {
    const r = await fetch(`${ISSUER_URL}/issue`, { method:'POST', headers:{'content-type':'application/json'}, body: JSON.stringify(req.body||{}) });
    const txt = await r.text();
    if (!r.ok) return res.status(r.status).send(txt);
    res.setHeader('content-type','application/json'); res.send(txt);
  } catch (e:any) { res.status(500).json({ error: String(e?.message || e) }); }
}

