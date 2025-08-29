#!/usr/bin/env bash
# add-employee-portal.sh — create apps/employee-portal (Next.js pages router) using Yarn only
set -euo pipefail

ROOT="$(pwd)"
APP_DIR="$ROOT/apps/employee-portal"

echo "[INFO] Creating directories…"
mkdir -p "$APP_DIR"/{pages/api,components,styles}

echo "[INFO] Writing package.json…"
cat > "$APP_DIR/package.json" <<'JSON'
{
  "name": "@saas/employee-portal",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3010",
    "build": "next build",
    "start": "next start -p 3010",
    "clean": "rm -rf .next"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-bootstrap": "^2.10.0",
    "bootstrap": "^5.3.3",
    "qrcode.react": "^3.1.0",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/react": "^18.2.0",
    "@types/node": "^20.0.0"
  }
}
JSON

echo "[INFO] Writing next.config.js…"
cat > "$APP_DIR/next.config.js" <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  transpilePackages: ['@saas/agent']
};
module.exports = nextConfig;
JS

echo "[INFO] Writing tsconfig.json…"
cat > "$APP_DIR/tsconfig.json" <<'JSON'
{
  "compilerOptions": {
    "target": "es6",
    "lib": ["dom", "dom.iterable", "es2021"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
JSON

echo "[INFO] Writing styles and app shell…"
cat > "$APP_DIR/styles/globals.css" <<'CSS'
html, body { height: 100%; }
body { background: #f7f7f9; }
CSS

cat > "$APP_DIR/pages/_app.tsx" <<'TS'
import type { AppProps } from 'next/app';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../styles/globals.css';
export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
TS

echo "[INFO] Writing Layout component…"
cat > "$APP_DIR/components/Layout.tsx" <<'TS'
import Link from 'next/link';
import { ReactNode } from 'react';
import { Container, Nav, Navbar } from 'react-bootstrap';

export default function Layout({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="d-flex" style={{ minHeight: '100vh' }}>
      <div className="bg-light border-end" style={{ width: 260 }}>
        <div className="p-3 border-bottom">
          <strong>DID + Cloud Signature</strong>
          <div className="text-muted small">Employee Portal</div>
        </div>
        <Nav className="flex-column p-2 gap-1">
          <Link className="nav-link" href="/">Dashboard</Link>
          <Link className="nav-link" href="/scan">Scan QR</Link>
          <Link className="nav-link" href="/import">Import VC</Link>
        </Nav>
      </div>
      <div className="flex-grow-1">
        <Navbar bg="white" className="border-bottom">
          <Container fluid><Navbar.Brand className="fw-semibold">{title}</Navbar.Brand></Container>
        </Navbar>
        <main className="p-4">{children}</main>
      </div>
    </div>
  );
}
TS

echo "[INFO] Writing QRScanner (BarcodeDetector) …"
cat > "$APP_DIR/components/QRScanner.tsx" <<'TS'
import { useEffect, useRef, useState } from 'react';
declare global { interface Window { BarcodeDetector?: any } }

export default function QRScanner({ onText }: { onText: (text: string)=>void }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [err, setErr] = useState<string>('');

  useEffect(() => {
    let stream: MediaStream | null = null;
    let raf = 0;
    let detector: any = null;

    async function start() {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          await videoRef.current.play();
        }
        if (window.BarcodeDetector) detector = new window.BarcodeDetector({ formats: ['qr_code'] });
        tick();
      } catch (e:any) { setErr(e?.message || String(e)); }
    }

    const tick = async () => {
      const v = videoRef.current, c = canvasRef.current;
      if (!v || !c) { raf = requestAnimationFrame(tick); return; }
      const w = v.videoWidth, h = v.videoHeight;
      if (w && h) {
        c.width = w; c.height = h;
        const ctx = c.getContext('2d'); if (ctx) {
          ctx.drawImage(v, 0, 0, w, h);
          if (detector) {
            try {
              const codes = await detector.detect(c);
              if (codes?.[0]?.rawValue) { onText(codes[0].rawValue); return; }
            } catch {}
          }
        }
      }
      raf = requestAnimationFrame(tick);
    };

    start();
    return () => {
      if (raf) cancelAnimationFrame(raf);
      if (stream) stream.getTracks().forEach(t => t.stop());
    };
  }, [onText]);

  return (
    <div>
      <video ref={videoRef} style={{ width: '100%', borderRadius: 12 }} muted playsInline />
      <canvas ref={canvasRef} style={{ display: 'none' }} />
      {err && <div className="text-danger small mt-2">{err}</div>}
    </div>
  );
}
TS

echo "[INFO] Writing pages…"
cat > "$APP_DIR/pages/index.tsx" <<'TS'
import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { Button, Card, Col, Form, Row, Table } from 'react-bootstrap';
import { v4 as uuidv4 } from 'uuid';

type VCEntry = { id: string; title?: string; vc: string; addedAt: string; lastVerify?: string; verified?: boolean; details?: any };
const LS_KEY = 'employee_vc_list';

export default function Dashboard() {
  const [list, setList] = useState<VCEntry[]>([]);
  const [verifierUrl, setVerifierUrl] = useState('http://localhost:3005');

  useEffect(() => {
    const raw = localStorage.getItem(LS_KEY);
    if (raw) setList(JSON.parse(raw));
  }, []);

  const save = (items: VCEntry[]) => { setList(items); localStorage.setItem(LS_KEY, JSON.stringify(items)); };

  async function verify(idx: number) {
    const item = list[idx];
    try {
      const pd = await fetch(`${verifierUrl}/presentation-definition`).then(r=>r.json());
      const vp = await fetch('/api/present', {
        method: 'POST', headers: {'content-type':'application/json'},
        body: JSON.stringify({ vc: item.vc, challenge: pd.challenge, domain: pd.domain })
      }).then(r=>r.json());
      const res = await fetch(`${verifierUrl}/verify`, {
        method: 'POST', headers: {'content-type':'application/json'},
        body: JSON.stringify({ presentation: { jwt: vp.jwt }, challenge: pd.challenge, domain: pd.domain,
          context: { user:{id:'employee'}, resource:'secure-notes', action:'view' } })
      }).then(r=>r.json());
      const now = new Date().toISOString();
      const updated = [...list];
      updated[idx] = { ...item, lastVerify: now, verified: !!res?.verified, details: res };
      save(updated);
    } catch (e:any) {
      const now = new Date().toISOString();
      const updated = [...list];
      updated[idx] = { ...item, lastVerify: now, verified: false, details: { error: String(e?.message||e) } };
      save(updated);
    }
  }

  function remove(idx:number){ const updated = list.filter((_,i)=>i!==idx); save(updated); }
  function addManual(){
    const vc = prompt('Paste VC (JWT) here:'); if (!vc) return;
    const entry: VCEntry = { id: uuidv4(), title: 'Credential', vc, addedAt: new Date().toISOString() };
    save([entry, ...list]);
  }

  return (
    <Layout title="Employee Dashboard">
      <Row className="g-3">
        <Col md={12}>
          <Card><Card.Body>
            <Form className="d-flex align-items-center gap-3 flex-wrap">
              <Form.Group>
                <Form.Label className="mb-0">Verifier URL</Form.Label>
                <Form.Control value={verifierUrl} onChange={e=>setVerifierUrl(e.target.value)} style={{minWidth:320}} />
              </Form.Group>
              <Button href="/scan">Scan VC QR</Button>
              <Button href="/import" variant="secondary">Import VC</Button>
              <Button variant="outline-primary" onClick={addManual}>Paste VC</Button>
            </Form>
          </Card.Body></Card>
        </Col>

        <Col md={12}>
          <Card><Card.Body>
            <Card.Title>My Credentials</Card.Title>
            {!list.length ? <p className="text-muted mb-0">No credentials yet. Scan or import to get started.</p> :
              <div className="table-responsive">
                <Table hover className="align-middle">
                  <thead><tr><th>Title</th><th>Added</th><th>Last verify</th><th>Result</th><th>Actions</th></tr></thead>
                  <tbody>
                    {list.map((it, i)=>(
                      <tr key={it.id}>
                        <td>{it.title ?? 'Credential'}</td>
                        <td><code>{new Date(it.addedAt).toLocaleString()}</code></td>
                        <td>{it.lastVerify ? <code>{new Date(it.lastVerify).toLocaleString()}</code> : <span className="text-muted">—</span>}</td>
                        <td>{it.verified === undefined ? <span className="text-muted">—</span> :
                             it.verified ? <span className="text-success">Verified</span> : <span className="text-danger">Failed</span>}</td>
                        <td className="d-flex gap-2">
                          <Button size="sm" onClick={()=>verify(i)}>Present & Verify</Button>
                          <Button size="sm" variant="outline-secondary" onClick={()=>navigator.clipboard.writeText(it.vc)}>Copy VC</Button>
                          <Button size="sm" variant="outline-danger" onClick={()=>remove(i)}>Delete</Button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </Table>
              </div>
            }
          </Card.Body></Card>
        </Col>
      </Row>
    </Layout>
  );
}
TS

cat > "$APP_DIR/pages/import.tsx" <<'TS'
import { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { Button, Card, Col, Form, Row } from 'react-bootstrap';
import { useRouter } from 'next/router';
import { v4 as uuidv4 } from 'uuid';
const LS_KEY = 'employee_vc_list';

export default function ImportVC() {
  const router = useRouter();
  const [vc, setVc] = useState('');
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    const q = router.query?.vc;
    if (typeof q === 'string' && q.length > 20) setVc(q);
  }, [router.query]);

  function save(){
    const raw = localStorage.getItem(LS_KEY);
    const list = raw ? JSON.parse(raw) : [];
    list.unshift({ id: uuidv4(), title: 'Credential', vc, addedAt: new Date().toISOString() });
    localStorage.setItem(LS_KEY, JSON.stringify(list));
    setSaved(true);
    setTimeout(()=>router.push('/'), 600);
  }

  return (
    <Layout title="Import Credential">
      <Row className="g-3">
        <Col md={8}>
          <Card><Card.Body>
            <Card.Title>Paste or prefilled VC</Card.Title>
            <Form.Group className="mb-3">
              <Form.Control as="textarea" rows={10} value={vc} onChange={e=>setVc(e.target.value)} placeholder="Paste JWT VC here" />
            </Form.Group>
            <Button disabled={!vc} onClick={save}>Save to Wallet</Button>
            {saved && <span className="ms-3 text-success">Saved ✔</span>}
          </Card.Body></Card>
        </Col>
        <Col md={4}>
          <Card><Card.Body>
            <Card.Title>Tip</Card.Title>
            <p>From the Admin Issuance page, click <em>“Open in Employee Portal”</em> to land here with your VC prefilled.</p>
          </Card.Body></Card>
        </Col>
      </Row>
    </Layout>
  );
}
TS

cat > "$APP_DIR/pages/scan.tsx" <<'TS'
import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { Card } from 'react-bootstrap';
import { useCallback } from 'react';
import dynamic from 'next/dynamic';

const QRScanner = dynamic(()=>import('../components/QRScanner'), { ssr:false });

export default function Scan() {
  const router = useRouter();
  const onText = useCallback((txt: string) => {
    try {
      const u = new URL(txt);
      const vc = u.searchParams.get('vc');
      if (vc) { router.push(`/import?vc=${encodeURIComponent(vc)}`); return; }
    } catch {}
    if (txt.length > 20) router.push(`/import?vc=${encodeURIComponent(txt)}`);
  }, [router]);

  return (
    <Layout title="Scan QR">
      <Card><Card.Body>
        <QRScanner onText={onText} />
        <div className="mt-3 text-muted small">Point your camera at the Admin QR (VC) or a credential-offer link.</div>
      </Card.Body></Card>
    </Layout>
  );
}
TS

echo "[INFO] Writing API route /api/present…"
cat > "$APP_DIR/pages/api/present.ts" <<'TS'
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
TS

echo "[INFO] Ensuring root workspaces include apps/* and packages/* …"
node - <<'NODE'
const fs = require('fs');
const p = 'package.json';
const j = JSON.parse(fs.readFileSync(p,'utf8'));
j.workspaces = Array.from(new Set([...(j.workspaces||[]), "apps/*", "packages/*"]));
fs.writeFileSync(p, JSON.stringify(j,null,2));
NODE

echo "[INFO] Installing with Yarn (workspaces)…"
rm -f "$APP_DIR/package-lock.json" 2>/dev/null || true
yarn install

echo "[OK] Employee Portal ready at apps/employee-portal"
echo "Run: yarn workspace @saas/employee-portal dev   (→ http://localhost:3010)"

