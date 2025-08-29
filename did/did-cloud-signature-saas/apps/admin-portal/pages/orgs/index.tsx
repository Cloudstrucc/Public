import { useEffect, useState } from 'react';
import { Button, Card, Col, Container, Form, Row, Table } from 'react-bootstrap';
import { useToaster } from '../../src/toaster';
import Layout from '../../components/Layout';


export default function OrgsPage() {
  const [orgs, setOrgs] = useState<any[]>([]);
  const [form, setForm] = useState({ name: '', did: '', domain: '' });
  const { push } = useToaster();

  const load = async () => { const j = await (await fetch('/api/orgs')).json(); setOrgs(j.orgs); };
  useEffect(() => { load(); }, []);

  const onSubmit = async (e: any) => {
    e.preventDefault();
    const r = await fetch('/api/orgs', { method: 'POST', headers: { 'content-type':'application/json' }, body: JSON.stringify(form) });
    if (r.ok) { setForm({ name:'', did:'', domain:'' }); push({ title:'Organization created', bg:'success' }); load(); }
    else push({ title:'Failed to create org', bg:'danger' });
  };

  return (
    <Layout title="Organizations">
      <Container fluid>
        <Row className="g-3">
          <Col md={5}>
            <Card><Card.Body>
              <Card.Title>Create Organization</Card.Title>
              <Form onSubmit={onSubmit}>
                <Form.Group className="mb-3"><Form.Label>Name</Form.Label>
                  <Form.Control required value={form.name} onChange={e=>setForm({...form, name:e.target.value})} />
                </Form.Group>
                <Form.Group className="mb-3"><Form.Label>Issuer DID (optional)</Form.Label>
                  <Form.Control value={form.did} onChange={e=>setForm({...form, did:e.target.value})}/>
                </Form.Group>
                <Form.Group className="mb-3"><Form.Label>Domain (optional)</Form.Label>
                  <Form.Control value={form.domain} onChange={e=>setForm({...form, domain:e.target.value})}/>
                </Form.Group>
                <Button type="submit">Create</Button>
              </Form>
            </Card.Body></Card>
          </Col>
          <Col md={7}>
            <Card><Card.Body>
              <Card.Title>Existing Orgs</Card.Title>
              <Table hover size="sm">
                <thead><tr><th>Name</th><th>DID</th><th>Domain</th></tr></thead>
                <tbody>{orgs.map((o:any)=>(
                  <tr key={o.id}><td>{o.name}</td><td>{o.did||'—'}</td><td>{o.domain||'—'}</td></tr>
                ))}</tbody>
              </Table>
            </Card.Body></Card>
          </Col>
        </Row>
      </Container>
    </Layout>
  );
}

