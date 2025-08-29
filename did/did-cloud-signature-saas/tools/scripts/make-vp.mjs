// tools/scripts/make-vp.mjs
// Usage: node tools/scripts/make-vp.mjs --vc <vc_jwt> --challenge <uuid> --domain <domain> [--holder <did>]

import { createDIDAgent } from '../../packages/agent/dist/index.js';

function arg(name, def) {
  const i = process.argv.indexOf(`--${name}`);
  return i > -1 ? process.argv[i + 1] : def;
}

(async () => {
  const vc = arg('vc');
  const challenge = arg('challenge');
  const domain = arg('domain');
  const holderArg = arg('holder'); // WARNING: only works if this process ALSO has that holder's keys

  if (!vc || !challenge || !domain) {
    console.error('Usage: node tools/scripts/make-vp.mjs --vc <vc_jwt> --challenge <uuid> --domain <domain> [--holder <did>]');
    process.exit(1);
  }

  const agent = createDIDAgent();

  // If holder not provided (or keys not available here), create a fresh did:key
  let holder = holderArg;
  if (!holder) {
    const id = await agent.didManagerCreate({ provider: 'did:key', alias: 'holder' });
    holder = id.did;
  }

  const vp = await agent.createVerifiablePresentation({
    presentation: { holder, verifiableCredential: [vc] },
    proofFormat: 'jwt',
    challenge,
    domain
  });

  console.log(vp.verifiablePresentation.jwt);
})().catch((e) => { console.error(e); process.exit(1); });

