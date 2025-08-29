# 0) Make sure the employee portal exists
test -d apps/employee-portal || { echo "employee-portal missing"; exit 1; }

# 1) Remove any App Router folder that might shadow pages/
rm -rf apps/employee-portal/app 2>/dev/null || true

# 2) Create a next.config.js that forces Pages Router
cat > apps/employee-portal/next.config.js <<'JS'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: { appDir: false } // Force Pages Router
};
module.exports = nextConfig;
JS

# 3) Ensure a minimal Layout component
mkdir -p apps/employee-portal/components
cat > apps/employee-portal/components/Layout.tsx <<'TSX'
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

# 4) Ensure _app.tsx to load bootstrap CSS
mkdir -p apps/employee-portal/pages
cat > apps/employee-portal/pages/_app.tsx <<'TSX'
import 'bootstrap/dist/css/bootstrap.min.css';
import type { AppProps } from 'next/app';
export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
TSX

# 5) Create the home page
cat > apps/employee-portal/pages/index.tsx <<'TSX'
import Layout from '../components/Layout';
import { Card } from 'react-bootstrap';

export default function Home() {
  return (
    <Layout title="Employee Dashboard">
      <Card><Card.Body>
        <h2>Welcome</h2>
        <p>Use the sidebar to Scan or Import a credential, then Present & Verify it.</p>
      </Card.Body></Card>
    </Layout>
  );
}
TSX

# 6) (Optional) create /scan and /import pages so links don’t 404
cat > apps/employee-portal/pages/scan.tsx <<'TSX'
import Layout from '../components/Layout';
export default function Scan() {
  return (
    <Layout title="Scan QR">
      <p>Scanner placeholder (QR/RFID). We can hook up a QR lib later.</p>
    </Layout>
  );
}
TSX

cat > apps/employee-portal/pages/import.tsx <<'TSX'
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
      <div className="mt-3"><button className="btn btn-primary" onClick={() => alert('Saved locally (demo).')}>Save</button></div>
    </Layout>
  );
}
TSX

# 7) Make sure TypeScript knows about Next types (harmless if exists)
cat > apps/employee-portal/next-env.d.ts <<'TS'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
TS

# 8) Add Popper peer for Bootstrap (clears Yarn warning)
yarn workspace @saas/employee-portal add -E @popperjs/core

