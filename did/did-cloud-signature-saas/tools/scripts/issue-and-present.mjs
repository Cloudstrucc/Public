// tools/scripts/issue-and-present.mjs
// Does: create holder DID -> call issuer /issue -> call verifier /presentation-definition -> build VP -> call /verify
// top of file
// tools/scripts/issue-and-present.mjs
// Force IPv4 by default
const ISSUER_URL   = process.env.ISSUER_URL   ?? 'http://127.0.0.1:3004'
const VERIFIER_URL = process.env.VERIFIER_URL ?? 'http://127.0.0.1:3005'


import { createDIDAgent } from '../../packages/agent/dist/index.js';


async function jsonFetch(url, opts = {}) {
  const r = await fetch(url, { headers: { 'content-type': 'application/json', ...(opts.headers||{}) }, ...opts });
  const text = await r.text();
  try { return { ok: r.ok, status: r.status, data: JSON.parse(text) }; }
  catch { return { ok: r.ok, status: r.status, data: text }; }
}

(async () => {
  const agent = createDIDAgent();

  // 1) Create holder DID (the same agent holds the private key)
  const holder = await agent.didManagerCreate({ provider: 'did:key', alias: 'holder' });
  console.log('[holder]', holder.did);

  // 2) Issue VC to that holder
  const issueBody = {
    subject: holder.did,
    claims: { givenName: 'Alice', employeeId: 'E-12345', department: 'IT' },
    expiresInMinutes: 60
  };
  const issue = await jsonFetch(`${ISSUER_URL}/issue`, { method: 'POST', body: JSON.stringify(issueBody) });
  if (!issue.ok) throw new Error(`Issuer error (${issue.status}): ${JSON.stringify(issue.data)}`);
  const vc = issue.data.vc;
  if (!vc || typeof vc !== 'string') throw new Error(`Issuer returned no JWT VC: ${JSON.stringify(issue.data)}`);
  console.log('[vc]', vc.slice(0, 60) + '...');

  // 3) Ask verifier for challenge/domain
  const pd = await jsonFetch(`${VERIFIER_URL}/presentation-definition`);
  if (!pd.ok) throw new Error(`Verifier PD error (${pd.status}): ${JSON.stringify(pd.data)}`);
  const { challenge, domain } = pd.data;
  console.log('[challenge]', challenge, '[domain]', domain);

  // 4) Create VP (signed by holder in this process)
  const vpResult = await agent.createVerifiablePresentation({
    presentation: { holder: holder.did, verifiableCredential: [vc] },
    proofFormat: 'jwt',
    challenge,
    domain
  });

  // Robust JWT extraction across versions
  const vpCandidate = vpResult?.verifiablePresentation ?? vpResult;
  const vpJwt =
    (typeof vpCandidate === 'string' && vpCandidate) ||
    (vpCandidate && vpCandidate.jwt) ||
    (vpCandidate && vpCandidate.proof && vpCandidate.proof.jwt) ||
    null;

  if (!vpJwt) {
    throw new Error(`Could not extract VP JWT from result: ${JSON.stringify(vpResult)}`);
  }

  console.log('[vp]', vpJwt.slice(0, 60) + '...');


  // 5) Send to verifier /verify
  const verifyBody = {
    presentation: { jwt: vpJwt },
    challenge,
    domain,
    context: {
      user: { id: 'alice', email: 'alice@example.com', roles: ['employee'] },
      resource: 'secure-notes',
      action: 'view'
    }
  };
  const verify = await jsonFetch(`${VERIFIER_URL}/verify`, { method: 'POST', body: JSON.stringify(verifyBody) });
  if (!verify.ok) throw new Error(`Verify error (${verify.status}): ${JSON.stringify(verify.data)}`);
  console.log('[verify]', JSON.stringify(verify.data, null, 2));
})().catch((e) => { console.error(e); process.exit(1); });

