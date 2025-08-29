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

/**
 * Helper: absolute origin for metadata/links.
 */
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

    // Draft/Final OID4VCI metadata using credential_configurations_supported (jwt_vc_json)
    const metadata = {
      credential_issuer: origin,
      token_endpoint: `${origin}/oidc/token`,
      credential_endpoint: `${origin}/oidc/credential`,
      display: [
        { name: 'Cloud Signature Issuer', locale: 'en-US', description: 'Demo OIDC4VCI issuer' }
      ],
      // Link your AS if it’s separate; here issuer == AS for dev
      authorization_server: origin,

      // Key bit: what credentials you can issue
      credential_configurations_supported: {
        employee_jwt_vc: {
          format: 'jwt_vc_json',
          scope: 'employee_vc',
          cryptographic_binding_methods_supported: ['did:key','did:web','did:jwk'],
          cryptographic_suites_supported: ['EdDSA','ES256','ES256K'],
          display: [
            { locale:'en-US', name:'Employee ID', description:'Employee entitlement credential' }
          ],
          credential_definition: {
            '@context': ['https://www.w3.org/2018/credentials/v1'],
            'type': ['VerifiableCredential','EmployeeCredential'],
            // (Optional) provide hints to wallets on subject claims
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
   * returns: { preAuthorizedCode, offer_uri, deep_link, qr_png_data_url }
   */
  app.post('/oidc/admin/create-offer', async (req: Request, res: Response) => {
    try {
      const origin = resolveOrigin(explicitOrigin, req)
      const { claims = {}, orgId, tx_code_length = 0, credential_configuration_id = 'employee_jwt_vc' } = req.body || {}

      const code = uuidv4()
      const txCode = tx_code_length && tx_code_length > 0
        ? (Math.random().toString().slice(2).padStart(tx_code_length, '0').slice(0, tx_code_length))
        : undefined

      offers.set(code, {
        code,
        txCode,
        claims,
        credentialConfigurationId: credential_configuration_id,
        orgId,
        createdAt: Date.now()
      })

      // Spec-compliant credential offer (served via URI)
      const offerUri = `${origin}/oidc/credential-offer/${code}`
      const deepLink = `openid-credential-offer://?credential_offer_uri=${encodeURIComponent(offerUri)}`
      const qr_png_data_url = await QRCode.toDataURL(deepLink)

      res.json({
        preAuthorizedCode: code,
        offer_uri: offerUri,
        deep_link: deepLink,
        qr_png_data_url
      })
    } catch (e:any) {
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

      // Very light proof check for dev (verify JWT if present)
      // Wallets will sign a proof JWT including the c_nonce we returned.
      // For production, parse & verify per spec claims (nonce, audience, etc).
      let subjectDid = undefined as string | undefined
      if (proof?.jwt) {
        // Use Veramo to verify the proof JWT (best-effort)
        try {
          const verified = await agent.verifyJWT({ jwt: proof.jwt })
          subjectDid = verified?.payload?.iss as string | undefined
          // (Optional) verify nonce binding here (c_nonce in the proof)
        } catch (e) {
          // For dev we won't fail if your wallet doesn't send proof yet
          // return res.status(400).json({ error: 'invalid_proof' })
        }
      }
      // Fallback to subject from proof-less flows (not recommended for prod)
      if (!subjectDid) {
        // If no proof, we can't reliably know holder DID — reject in prod
        return res.status(400).json({ error: 'missing_or_invalid_proof' })
      }

      // Compose VC claims from the stored offer + subjectDid
      const employeeClaims = { ...offer.claims }
      const vc = await agent.createVerifiableCredential({
        credential: {
          issuer: { id: (await agent.didManagerGet({ did: (await agent.didManagerGetOrCreate({ alias: 'issuer' })).did })).did },
          '@context': credential_definition?.['@context'] || ['https://www.w3.org/2018/credentials/v1'],
          type: credential_definition?.type || ['VerifiableCredential','EmployeeCredential'],
          issuanceDate: new Date().toISOString(),
          credentialSubject: {
            id: subjectDid,
            ...employeeClaims
          }
        },
        proofFormat: 'jwt' // → returns { verifiableCredential: string | object }
      })

      // Veramo returns an object or JWT depending on plugin version.
      // Normalize to a JWT string for OIDC4VCI response.
      const jwt =
        typeof (vc?.verifiableCredential) === 'string'
          ? vc.verifiableCredential
          : vc?.verifiableCredential?.proof?.jwt

      if (!jwt) {
        return res.status(500).json({ error: 'issuance_failed' })
      }

      // OIDC4VCI response for jwt_vc_json:
      res.json({
        format: 'jwt_vc_json',
        credential: jwt
      })
    } catch (e:any) {
      res.status(500).json({ error: String(e?.message || e) })
    }
  })
}

