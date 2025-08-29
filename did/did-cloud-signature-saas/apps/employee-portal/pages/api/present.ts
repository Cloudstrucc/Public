import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  try {
    const { vc, challenge, domain } = req.body || {};
    if (!vc || !challenge || !domain) return res.status(400).json({ error: 'vc, challenge, domain required' });

    const { createDIDAgent } = await import('@saas/agent');
    const a = createDIDAgent();
    const holder = await a.didManagerCreate({ provider: 'did:key', alias: 'employee-holder' });

    const vp = await a.createVerifiablePresentation({
      presentation: {
        holder: holder.did,
        verifier: [domain],
        type: ['VerifiablePresentation'],
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        verifiableCredential: [vc]
      },
      challenge,
      domain,
      proofFormat: 'jwt'
    });

    res.json({ jwt: vp.verifiablePresentation });
  } catch (e:any) {
    res.status(500).json({ error: String(e?.message || e) });
  }
}
