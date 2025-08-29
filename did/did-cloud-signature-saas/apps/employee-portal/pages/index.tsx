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
