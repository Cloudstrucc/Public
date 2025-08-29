#!/usr/bin/env bash
set -euo pipefail

PORTAL=apps/employee-portal

echo "==> Verifying employee portal exists..."
test -d "$PORTAL" || { echo "ERROR: $PORTAL not found"; exit 1; }

echo "==> Removing App Router dir (if present)..."
rm -rf "$PORTAL/app" 2>/dev/null || true

echo "==> Forcing Pages Router via next.config.js..."
cat > "$PORTAL/next.config.js" <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Force Pages Router so pages/ is used (not app/)
  experimental: { appDir: false }
};
module.exports = nextConfig;
JS

echo "==> Ensuring Bootstrap CSS is loaded via _app.tsx..."
mkdir -p "$PORTAL/pages" "$PORTAL/components"
cat > "$PORTAL/pages/_app.tsx" <<'TSX'
import 'bootstrap/dist/css/bootstrap.min.css';
import type { AppProps } from 'next/app';
export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
TSX

echo "==> Writing a minimal Layout component..."
cat > "$PORTAL/components/Layout.tsx" <<'TSX'
import Head from 'next/head';
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

type Props = { title?: string; children: React.ReactNode };

export default function Layout({ title = 'Employee Portal', children }: Props) {
  return (
    <>
      <Head><title>{title}</title></Head>
      <Navbar expand="lg" bg="light" className="mb-4">
        <Container>
          <Navbar.Brand href="/">Employee Portal</Navbar.Brand>
          <Nav className="me-auto">
            <Nav.Link href="/scan">Scan</Nav.Link>
            <Nav.Link href="/import">Import</Nav.Link>
            <Nav.Link href="/dashboard">Dashboard</Nav.Link>
          </Nav>
        </Container>
      </Navbar>
      <Container>{children}</Container>
    </>
  );
}
TSX

echo "==> Creating Home page at / ..."
cat > "$PORTAL/pages/index.tsx" <<'TSX'
import Layout from '../components/Layout';
import { Card } from 'react-bootstrap';

export default function Home() {
  return (
    <Layout title="Employee Dashboard">
      <Card><Card.Body>
        <h2>Welcome</h2>
        <p>Use the navbar to Scan or Import a credential, then Present & Verify it.</p>
      </Card.Body></Card>
    </Layout>
  );
}
TSX

echo "==> (Optional) Creating /scan and /import so links do not 404..."
cat > "$PORTAL/pages/scan.tsx" <<'TSX'
import Layout from '../components/Layout';
export default function Scan() {
  return (
    <Layout title="Scan QR">
      <p>Scanner placeholder (QR/RFID). We can hook up a QR lib later.</p>
    </Layout>
  );
}
TSX

cat > "$PORTAL/pages/import.tsx" <<'TSX'
import { useEffect, useState } from 'react';
import Layout from '../components/Layout';

export default function Import() {
  const [vc, setVc] = useState('');
  useEffect(() => {
    const url = new URL(window.location.href);
    const qp = url.searchParams.get('vc');
    if (qp) setVc(qp);
  }, []);
  return (
    <Layout title="Import Credential">
      <p>Paste or prefilled VC JWT:</p>
      <textarea className="form-control" rows={6} value={vc} onChange={e=>setVc(e.target.value)} />
      <div className="mt-3">
        <button className="btn btn-primary" onClick={() => alert('Saved locally (demo).')}>Save</button>
      </div>
    </Layout>
  );
}
TSX

echo "==> Ensuring Next types shim (harmless if already present)..."
cat > "$PORTAL/next-env.d.ts" <<'TS'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
TS

echo "==> Installing @popperjs/core peer for Bootstrap (quiet if present)..."
yarn workspace @saas/employee-portal add -E @popperjs/core >/dev/null

echo "==> Verifying root dev script includes employee portal..."
node - <<'NODE'
const fs=require('fs'); const f='package.json';
const j=JSON.parse(fs.readFileSync(f,'utf8'));
const want='"yarn workspace @saas/employee-portal dev"';
if(!j.scripts || !j.scripts.dev){ console.error('No root "dev" script found.'); process.exit(0); }
if(!j.scripts.dev.includes('@saas/employee-portal')){
  j.scripts.dev = j.scripts.dev + ' ' + want;
  fs.writeFileSync(f, JSON.stringify(j,null,2) + '\n');
  console.log('Updated root scripts.dev to include employee-portal.');
} else {
  console.log('Root scripts.dev already includes employee-portal.');
}
NODE

echo "==> All set. Start just the portal with:"
echo "    yarn workspace @saas/employee-portal dev"
echo "    # then visit http://localhost:3010/"

