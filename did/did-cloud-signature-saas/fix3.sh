# Ensure the pages directory + home exists
ls -la apps/employee-portal/pages

# (Re)create a minimal home page if needed
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

# Make sure Next has its env d.ts (harmless to add even if not strictly required)
cat > apps/employee-portal/next-env.d.ts <<'TS'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
TS

# Restart the portal
yarn workspace @saas/employee-portal dev
