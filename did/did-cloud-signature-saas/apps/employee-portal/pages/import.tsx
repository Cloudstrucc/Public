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
