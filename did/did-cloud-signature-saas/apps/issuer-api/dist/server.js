"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const agent_1 = require("@saas/agent");
const oidc4vci_1 = require("./oidc4vci");
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3004;
const ORIGIN = process.env.ISSUER_ORIGIN; // e.g., https://YOUR-NGROK-ID.ngrok.io
app.use((0, cors_1.default)());
app.use(express_1.default.json());
const agent = (0, agent_1.createDIDAgent)();
let issuerDid;
async function ensureIssuerDid() {
    const ALIAS = 'service-issuer';
    try {
        const list = await agent.didManagerFind({ alias: ALIAS });
        if (list.length) {
            issuerDid = list[0].did;
            return;
        }
    }
    catch { /* ignore */ }
    const identity = await agent.didManagerCreate({ provider: 'did:key', alias: ALIAS });
    issuerDid = identity.did;
}
app.get('/issuer-did', (_req, res) => {
    if (!issuerDid)
        return res.status(503).json({ error: 'issuer not ready' });
    res.json({ issuerDid });
});
app.post('/issue', async (req, res) => {
    try {
        if (!issuerDid)
            return res.status(503).json({ error: 'issuer not ready' });
        const { subject, claims, expiresInMinutes = 60 } = req.body || {};
        if (!subject || typeof subject !== 'string') {
            return res.status(400).json({ error: 'subject (holder DID) is required' });
        }
        const now = new Date();
        const exp = new Date(now.getTime() + Number(expiresInMinutes) * 60000);
        const credential = {
            '@context': ['https://www.w3.org/2018/credentials/v1'],
            type: ['VerifiableCredential', 'EmployeeCredential'],
            issuer: { id: issuerDid },
            issuanceDate: now.toISOString(),
            expirationDate: exp.toISOString(),
            credentialSubject: { id: subject, ...(claims || {}) }
        };
        const result = await agent.createVerifiableCredential({
            credential,
            proofFormat: 'jwt'
        });
        // Robust extraction across library versions:
        const vcJwt = (typeof result === 'string' && result) || // some versions return the jwt string
            (result && result.jwt) || // sometimes { jwt }
            (result && result.verifiableCredential) || // sometimes { verifiableCredential: <jwt> }
            (result && result.vc) || // sometimes { vc: <jwt> }
            (result && result.proof && result.proof.jwt) || // VC object with proof.jwt  <-- your case
            null;
        if (!vcJwt || typeof vcJwt !== 'string') {
            console.error('createVerifiableCredential returned unexpected shape:', result);
            return res.status(500).json({ error: 'Failed to create JWT VC (unexpected result shape)' });
        }
        res.json({ vc: vcJwt, issuerDid });
    }
    catch (error) {
        console.error('Error issuing credential:', error);
        res.status(500).json({ error: String(error?.message || error) });
    }
});
// 🔗 Register OIDC4VCI routes
(0, oidc4vci_1.registerOidc4vciRoutes)(app, agent, ORIGIN);
app.listen(PORT, async () => {
    const issuer = await agent.didManagerGetOrCreate({ alias: 'issuer' });
    console.log(`VC Issuer API running on port ${PORT} with issuer ${issuer.did}`);
});
// app.listen(PORT, async () => {
//   await ensureIssuerDid();
//   console.log(`VC Issuer API running on port ${PORT} with issuer ${issuerDid}`);
// });
