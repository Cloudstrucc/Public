import type { NextApiRequest, NextApiResponse } from 'next';
const VERIFIER_URL = process.env.VERIFIER_API_URL ?? 'http://127.0.0.1:3005';

type Rule = { id: string; name: string; condition?: string; action: 'allow'|'deny'; resources: string[]; claims?: Record<string, any> };
let rules: Rule[] = [
  { id:'allow-it-view-secure-notes', name:'Allow IT to view secure-notes', action:'allow', resources:['secure-notes'], claims:{ department:'IT' } },
];

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') return res.json({ rules });
  if (req.method === 'POST') {
    const r = req.body as Rule;
    const i = rules.findIndex(x=>x.id===r.id);
    if (i>=0) rules[i]=r; else rules.push(r);
    return res.json({ ok:true, rules });
  }
  if (req.method === 'PUT') {
    // push all to verifier
    try {
      const resp = await fetch(`${VERIFIER_URL}/policies`, { method:'POST', headers:{'content-type':'application/json'}, body: JSON.stringify({ rules }) });
      const txt = await resp.text();
      if (!resp.ok) return res.status(resp.status).send(txt);
      return res.json({ ok:true });
    } catch (e:any) {
      return res.status(500).json({ error: String(e?.message||e) });
    }
  }
  res.status(405).end();
}

