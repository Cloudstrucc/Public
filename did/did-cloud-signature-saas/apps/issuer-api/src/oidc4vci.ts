// import express, { type Request, type Response, type Express } from 'express';
// import QRCode from 'qrcode';
// import { v4 as uuidv4 } from 'uuid';

// type Offer = {
//   code: string;
//   txCode?: string;
//   claims: Record<string, any>;
//   credentialConfigurationId: string;
//   orgId?: string;
//   createdAt: number;
// };
// type Token = {
//   accessToken: string;
//   offerCode: string;
//   scope: string;
//   cNonce: string;
//   cNonceExpiresAt: number;
//   expiresAt: number;
// };

// const offers = new Map<string, Offer>();
// const tokens = new Map<string, Token>();

// // NEW: dev store for “is my credential ready?”
// const issuedByCode = new Map<string, { credential: string; issuedAt: number }>();

// function resolveOrigin(envOrigin?: string, req?: Request) {
//   if (envOrigin) return envOrigin.replace(/\/+$/, '');
//   if (req) {
//     const proto = (req.headers['x-forwarded-proto'] as string) || 'http';
//     const host = req.headers['host'];
//     return `${proto}://${host}`;
//   }
//   return 'http://localhost:3004';
// }

// export function registerOidc4vciRoutes(app: Express, agent: any, explicitOrigin?: string) {
//   app.get('/.well-known/openid-credential-issuer', (req: Request, res: Response) => {
//     const origin = resolveOrigin(explicitOrigin, req);
//     const metadata = {
//       credential_issuer: origin,
//       token_endpoint: `${origin}/oidc/token`,
//       credential_endpoint: `${origin}/oidc/credential`,
//       display: [
//         { name: 'Cloud Signature Issuer', locale: 'en-US', description: 'Demo OIDC4VCI issuer' },
//       ],
//       authorization_server: origin,
//       credential_configurations_supported: {
//         employee_jwt_vc: {
//           format: 'jwt_vc_json',
//           scope: 'employee_vc',
//           cryptographic_binding_methods_supported: ['did:key', 'did:web', 'did:jwk'],
//           cryptographic_suites_supported: ['EdDSA', 'ES256', 'ES256K'],
//           display: [
//             { locale: 'en-US', name: 'Employee ID', description: 'Employee entitlement credential' },
//           ],
//           credential_definition: {
//             '@context': ['https://www.w3.org/2018/credentials/v1'],
//             type: ['VerifiableCredential', 'EmployeeCredential'],
//             credentialSubject: { givenName: {}, employeeId: {}, department: {} },
//           },
//         },
//       },
//     };
//     res.json(metadata);
//   });

//   app.post('/oidc/admin/create-offer', async (req: Request, res: Response) => {
//     try {
//       const origin = resolveOrigin(explicitOrigin, req);
//       const {
//         claims = {},
//         orgId,
//         tx_code_length = 0,
//         credential_configuration_id = 'employee_jwt_vc',
//       } = req.body || {};

//       const code = uuidv4();
//       const txCode =
//         tx_code_length && tx_code_length > 0
//           ? Math.random().toString().slice(2).padStart(tx_code_length, '0').slice(0, tx_code_length)
//           : undefined;

//       offers.set(code, {
//         code,
//         txCode,
//         claims,
//         credentialConfigurationId: credential_configuration_id,
//         orgId,
//         createdAt: Date.now(),
//       });

//       issuedByCode.delete(code); // reset any previous status for this code

//       const offerUri = `${origin}/oidc/credential-offer/${code}`;
//       const deepLink = `openid-credential-offer://?credential_offer_uri=${encodeURIComponent(offerUri)}`;
//       const qr_png_data_url = await QRCode.toDataURL(deepLink);

//       res.json({
//         preAuthorizedCode: code,
//         offer_uri: offerUri,
//         deep_link: deepLink,
//         qr_png_data_url,
//       });
//     } catch (e: any) {
//       res.status(500).json({ error: String(e?.message || e) });
//     }
//   });

//   app.get('/oidc/credential-offer/:code', (req: Request, res: Response) => {
//     const origin = resolveOrigin(explicitOrigin, req);
//     const code = req.params.code;
//     const offer = offers.get(code);
//     if (!offer) return res.status(404).json({ error: 'unknown_offer' });

//     const body: any = {
//       credential_issuer: origin,
//       credential_configuration_ids: [offer.credentialConfigurationId],
//       grants: {
//         'urn:ietf:params:oauth:grant-type:pre-authorized_code': {
//           'pre-authorized_code': offer.code,
//         },
//       },
//     };
//     if (offer.txCode) {
//       body.grants['urn:ietf:params:oauth:grant-type:pre-authorized_code'].tx_code = {
//         length: offer.txCode.length,
//         input_mode: 'numeric',
//       };
//     }
//     res.json(body);
//   });

//   app.post('/oidc/token', express.urlencoded({ extended: true }), (req: Request, res: Response) => {
//     const {
//       grant_type,
//       ['pre-authorized_code']: preAlt,
//       pre_authorized_code,
//       tx_code,
//     } = (req.body || {}) as Record<string, string>;

//     if (grant_type !== 'urn:ietf:params:oauth:grant-type:pre-authorized_code') {
//       return res.status(400).json({ error: 'unsupported_grant_type' });
//     }

//     const code = preAlt || pre_authorized_code;
//     const offer = code && offers.get(code);
//     if (!offer) return res.status(400).json({ error: 'invalid_grant' });
//     if (offer.txCode && offer.txCode !== String(tx_code || '')) {
//       return res.status(400).json({ error: 'invalid_tx_code' });
//     }

//     const accessToken = uuidv4();
//     const cNonce = uuidv4();
//     const now = Date.now();
//     tokens.set(accessToken, {
//       accessToken,
//       offerCode: offer.code,
//       scope: 'employee_vc',
//       cNonce,
//       cNonceExpiresAt: now + 5 * 60 * 1000,
//       expiresAt: now + 10 * 60 * 1000,
//     });

//     res.json({
//       access_token: accessToken,
//       token_type: 'bearer',
//       expires_in: 600,
//       scope: 'employee_vc',
//       c_nonce: cNonce,
//       c_nonce_expires_in: 300,
//     });
//   });

//   app.post('/oidc/credential', async (req: Request, res: Response) => {
//     try {
//       const auth = req.headers.authorization || '';
//       const token = auth.startsWith('Bearer ') ? auth.slice(7) : '';
//       const t = token && tokens.get(token);
//       if (!t) return res.status(401).json({ error: 'invalid_token' });
//       if (Date.now() > t.expiresAt) return res.status(401).json({ error: 'token_expired' });

//       const offer = offers.get(t.offerCode);
//       if (!offer) return res.status(400).json({ error: 'invalid_request' });

//       const { format, credential_definition, proof } = req.body || {};
//       if (format !== 'jwt_vc_json') {
//         return res.status(400).json({ error: 'unsupported_credential_format' });
//       }

//       let subjectDid: string | undefined;
//       if (proof?.jwt) {
//         try {
//           const verified = await agent.verifyJWT({ jwt: proof.jwt });
//           subjectDid = verified?.payload?.iss as string | undefined;
//         } catch {
//           // for dev we tolerate, for prod: return res.status(400)…
//         }
//       }
//       if (!subjectDid) {
//         return res.status(400).json({ error: 'missing_or_invalid_proof' });
//       }

//       const employeeClaims = { ...offer.claims };
//       const issued = await agent.createVerifiableCredential({
//         credential: {
//           issuer: {
//             id: (await agent.didManagerGetOrCreate({ alias: 'issuer' })).did,
//           },
//           '@context': credential_definition?.['@context'] || ['https://www.w3.org/2018/credentials/v1'],
//           type: credential_definition?.type || ['VerifiableCredential', 'EmployeeCredential'],
//           issuanceDate: new Date().toISOString(),
//           credentialSubject: {
//             id: subjectDid,
//             ...employeeClaims,
//           },
//         },
//         proofFormat: 'jwt',
//       });

//       const jwt =
//         typeof issued?.verifiableCredential === 'string'
//           ? issued.verifiableCredential
//           : issued?.verifiableCredential?.proof?.jwt;

//       if (!jwt) return res.status(500).json({ error: 'issuance_failed' });

//       // save for polling by the employee portal (dev only)
//       issuedByCode.set(offer.code, { credential: jwt, issuedAt: Date.now() });

//       res.json({ format: 'jwt_vc_json', credential: jwt });
//     } catch (e: any) {
//       res.status(500).json({ error: String(e?.message || e) });
//     }
//   });

//   // NEW: Dev status endpoint so the employee portal can poll by code
//   app.get('/oidc/dev/status', (req: Request, res: Response) => {
//     const code = String(req.query.code || '');
//     if (!code) return res.status(400).json({ error: 'code required' });

//     const ready = issuedByCode.get(code);
//     if (!ready) return res.json({ status: 'pending' });

//     res.json({
//       status: 'ready',
//       issuedAt: ready.issuedAt,
//       credential: ready.credential,
//     });
//   });
// }
import express, { type Request, type Response, type Express } from 'express'
import QRCode from 'qrcode'
import { v4 as uuidv4 } from 'uuid'

/**
 * Minimal in-memory stores for dev.
 * In production, replace with Redis/DB and add expiry/cleanup.
 */
type Offer = {
  code: string
  txCode?: string
  claims: Record<string, any>
  credentialConfigurationId: string
  orgId?: string
  createdAt: number
}
type Token = {
  accessToken: string
  offerCode: string
  scope: string
  cNonce: string
  cNonceExpiresAt: number
  expiresAt: number
}

const offers = new Map<string, Offer>()
const tokens = new Map<string, Token>()

/** Helper: absolute origin for metadata/links. */
function resolveOrigin(envOrigin?: string, req?: Request) {
  if (envOrigin) return envOrigin.replace(/\/+$/, '')
  if (req) {
    const proto = (req.headers['x-forwarded-proto'] as string) || 'http'
    const host = req.headers['host']
    return `${proto}://${host}`
  }
  return 'http://localhost:3004'
}

export function registerOidc4vciRoutes(app: Express, agent: any, explicitOrigin?: string) {
  // ---- 1) WELL-KNOWN (Issuer Metadata)
  app.get('/.well-known/openid-credential-issuer', (req: Request, res: Response) => {
    const origin = resolveOrigin(explicitOrigin, req)

    // Draft OID4VCI metadata using credential_configurations_supported (jwt_vc_json)
    const metadata = {
      credential_issuer: origin,
      token_endpoint: `${origin}/oidc/token`,
      credential_endpoint: `${origin}/oidc/credential`,
      display: [
        { name: 'Cloud Signature Issuer', locale: 'en-US', description: 'Demo OIDC4VCI issuer' }
      ],
      authorization_server: origin, // issuer == AS (dev)

      credential_configurations_supported: {
        employee_jwt_vc: {
          format: 'jwt_vc_json',
          scope: 'employee_vc',
          cryptographic_binding_methods_supported: ['did:key', 'did:web', 'did:jwk'],
          cryptographic_suites_supported: ['EdDSA', 'ES256', 'ES256K'],
          display: [
            { locale: 'en-US', name: 'Employee ID', description: 'Employee entitlement credential' }
          ],
          credential_definition: {
            '@context': ['https://www.w3.org/2018/credentials/v1'],
            type: ['VerifiableCredential', 'EmployeeCredential'],
            credentialSubject: {
              givenName: {},
              employeeId: {},
              department: {}
            }
          }
        }
      }
    }
    res.json(metadata)
  })

  /**
   * ---- 2) ADMIN: Create a pre-authorized offer
   * POST /oidc/admin/create-offer
   * body: { claims: {...}, orgId?: string, tx_code_length?: number, credential_configuration_id?: string }
   * returns: { preAuthorizedCode, offer_uri, deep_link, qr_png_data_url, deep_link_inline, offer_inline }
   */
  app.post('/oidc/admin/create-offer', async (req: Request, res: Response) => {
    try {
      const origin = resolveOrigin(explicitOrigin, req)
      const {
        claims = {},
        orgId,
        tx_code_length = 0,
        credential_configuration_id = 'employee_jwt_vc'
      } = req.body || {}

      const code = uuidv4()
      const txCode =
        tx_code_length && tx_code_length > 0
          ? Math.random().toString().slice(2).padStart(tx_code_length, '0').slice(0, tx_code_length)
          : undefined

      // Store the offer
      offers.set(code, {
        code,
        txCode,
        claims,
        credentialConfigurationId: credential_configuration_id,
        orgId,
        createdAt: Date.now()
      })

      // A) Link-based offer (good for Microsoft / many wallets)
      const offerUri = `${origin}/oidc/credential-offer/${code}`

      // B) Inline JSON offer (good for Altme / some wallets)
      const inlineOffer = {
        credential_issuer: origin,
        credential_configuration_ids: [credential_configuration_id],
        grants: {
          'urn:ietf:params:oauth:grant-type:pre-authorized_code': {
            'pre-authorized_code': code,
            ...(txCode
              ? { tx_code: { length: txCode.length, input_mode: 'numeric' } }
              : {})
          }
        }
      }

      // Compose a deep link that contains BOTH forms for maximum compatibility.
      // Wallets usually pick the param they support and ignore the other.
      const deepLink =
        `openid-credential-offer://?credential_offer_uri=${encodeURIComponent(offerUri)}` +
        `&credential_offer=${encodeURIComponent(JSON.stringify(inlineOffer))}`

      const qr_png_data_url = await QRCode.toDataURL(deepLink)

      res.json({
        preAuthorizedCode: code,
        offer_uri: offerUri,
        deep_link: deepLink,                 // combined URI + inline
        deep_link_inline: `openid-credential-offer://?credential_offer=${encodeURIComponent(JSON.stringify(inlineOffer))}`, // just inline
        offer_inline: inlineOffer,           // returned for debugging/dev tools
        qr_png_data_url
      })
    } catch (e: any) {
      res.status(500).json({ error: String(e?.message || e) })
    }
  })

  /**
   * ---- 3) Public: serve the offer for a code
   * GET /oidc/credential-offer/:code
   */
  app.get('/oidc/credential-offer/:code', (req: Request, res: Response) => {
    const origin = resolveOrigin(explicitOrigin, req)
    const code = req.params.code
    const offer = offers.get(code)
    if (!offer) return res.status(404).json({ error: 'unknown_offer' })

    const body: any = {
      credential_issuer: origin,
      credential_configuration_ids: [offer.credentialConfigurationId],
      grants: {
        'urn:ietf:params:oauth:grant-type:pre-authorized_code': {
          'pre-authorized_code': offer.code
        }
      }
    }
    if (offer.txCode) {
      body.grants['urn:ietf:params:oauth:grant-type:pre-authorized_code'].tx_code = {
        length: offer.txCode.length,
        input_mode: 'numeric'
      }
    }
    res.json(body)
  })

  /**
   * ---- 4) Token endpoint (pre-authorized_code flow)
   * POST x-www-form-urlencoded:
   *   grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code
   *   pre-authorized_code=...
   *   tx_code=... (if required)
   */
  app.post('/oidc/token', express.urlencoded({ extended: true }), (req: Request, res: Response) => {
    const { grant_type, ['pre-authorized_code']: pre, pre_authorized_code, tx_code } = req.body || {}
    const code = pre || pre_authorized_code
    if (grant_type !== 'urn:ietf:params:oauth:grant-type:pre-authorized_code') {
      return res.status(400).json({ error: 'unsupported_grant_type' })
    }
    const offer = code && offers.get(code)
    if (!offer) return res.status(400).json({ error: 'invalid_grant' })
    if (offer.txCode && offer.txCode !== String(tx_code || '')) {
      return res.status(400).json({ error: 'invalid_tx_code' })
    }

    const accessToken = uuidv4()
    const cNonce = uuidv4()
    const now = Date.now()
    tokens.set(accessToken, {
      accessToken,
      offerCode: offer.code,
      scope: 'employee_vc',
      cNonce,
      cNonceExpiresAt: now + 5 * 60 * 1000,
      expiresAt: now + 10 * 60 * 1000
    })

    res.json({
      access_token: accessToken,
      token_type: 'bearer',
      expires_in: 600,
      scope: 'employee_vc',
      c_nonce: cNonce,
      c_nonce_expires_in: 300
    })
  })

  /**
   * ---- 5) Credential endpoint
   * POST application/json:
   *   {
   *     "format": "jwt_vc_json",
   *     "credential_definition": { "type": [...], "@context":[...], "credentialSubject": {...optional hints...} },
   *     "proof": { "proof_type":"jwt", "jwt":"<holder proof bound to c_nonce>" }
   *   }
   * Authorization: Bearer <access_token>
   */
  app.post('/oidc/credential', async (req: Request, res: Response) => {
    try {
      const auth = req.headers.authorization || ''
      const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
      const t = token && tokens.get(token)
      if (!t) return res.status(401).json({ error: 'invalid_token' })
      if (Date.now() > t.expiresAt) return res.status(401).json({ error: 'token_expired' })

      const offer = offers.get(t.offerCode)
      if (!offer) return res.status(400).json({ error: 'invalid_request' })

      const { format, credential_definition, proof } = req.body || {}
      if (format !== 'jwt_vc_json') {
        return res.status(400).json({ error: 'unsupported_credential_format' })
      }

      // Light proof verification (dev)
      let subjectDid: string | undefined = undefined
      if (proof?.jwt) {
        try {
          const verified = await agent.verifyJWT({ jwt: proof.jwt })
          subjectDid = verified?.payload?.iss as string | undefined
          // TODO: Verify c_nonce binding per spec
        } catch {
          // For dev you could allow proof-less; for prod, enforce it.
          return res.status(400).json({ error: 'invalid_proof' })
        }
      } else {
        return res.status(400).json({ error: 'missing_or_invalid_proof' })
      }

      const employeeClaims = { ...offer.claims }
      const vcResult = await agent.createVerifiableCredential({
        credential: {
          issuer: { id: (await agent.didManagerGetOrCreate({ alias: 'issuer' })).did },
          '@context': credential_definition?.['@context'] || ['https://www.w3.org/2018/credentials/v1'],
          type: credential_definition?.type || ['VerifiableCredential', 'EmployeeCredential'],
          issuanceDate: new Date().toISOString(),
          credentialSubject: {
            id: subjectDid,
            ...employeeClaims
          }
        },
        proofFormat: 'jwt'
      })

      const jwt =
        typeof (vcResult as any)?.verifiableCredential === 'string'
          ? (vcResult as any).verifiableCredential
          : (vcResult as any)?.verifiableCredential?.proof?.jwt

      if (!jwt) return res.status(500).json({ error: 'issuance_failed' })

      res.json({ format: 'jwt_vc_json', credential: jwt })
    } catch (e: any) {
      res.status(500).json({ error: String(e?.message || e) })
    }
  })
}
