# sanity check: list pages dir (it should exist)
ls -la apps/employee-portal/pages || mkdir -p apps/employee-portal/pages

# create (or overwrite) the home page
cat > apps/employee-portal/pages/index.tsx <<'TS'
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
TS

# make sure Next’s env dts exists (harmless if already there)
cat > apps/employee-portal/next-env.d.ts <<'TS'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
TS

