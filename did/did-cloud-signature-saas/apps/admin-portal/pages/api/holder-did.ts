import type { NextApiRequest, NextApiResponse } from 'next';
import { createDIDAgent } from '@saas/agent'; // ⬅️ use ESM import

export default async function handler(_req: NextApiRequest, res: NextApiResponse) {
  try {
    const a = createDIDAgent();
    const id = await a.didManagerCreate({ provider: 'did:key', alias: 'holder-ui' });
    res.json({ did: id.did });
  } catch (e: any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}
