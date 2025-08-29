import type { NextApiRequest, NextApiResponse } from 'next';
type Org = { id: string; name: string; did?: string; domain?: string };
const orgs: Org[] = [{ id: 'org-1', name: 'Acme Corp', did: 'did:key:issuer-dev', domain: 'acme.test' }];

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') return res.json({ orgs });
  if (req.method === 'POST') {
    const { name, did, domain } = req.body || {};
    const id = `org-${Date.now()}`;
    orgs.push({ id, name, did, domain });
    return res.json({ ok: true, org: { id, name, did, domain } });
  }
  res.status(405).end();
}

