import { useEffect, useState } from 'react';
import { Button, Card, Col, Form, Row, Table } from 'react-bootstrap';
import { useToaster } from '../../src/toaster';
import { v4 as uuid } from 'uuid';
import Layout from '../../components/Layout';


type Rule = { id: string; name: string; condition?: string; action: 'allow'|'deny'; resources: string[]; claims?: any };

export default function Policies() {
  const [rules, setRules] = useState<Rule[]>([]);
  const [form, setForm] = useState<Rule>({ id:'', name:'', action:'allow', resources:['secure-notes'], claims:{ department:'IT' }});
  const { push } = useToaster();

  const load = async ()=>{ const j = await (await fetch('/api/policies')).json(); setRules(j.rules); };
  useEffect(()=>{ load(); },[]);

  const submit = async (e:any) => {
    e.preventDefault();
    const payload = { ...form, id: form.id || uuid(), resources: (Array.isArray(form.resources)?form.resources:String(form.resources).split(',').map(s=>s.trim()).filter(Boolean)) };
    try {
      const r = await fetch('/api/policies',{ method:'POST', headers:{'content-type':'application/json'}, body: JSON.stringify(payload) });
      if (!r.ok) throw new Error(await r.text());
      setForm({ id:'', name:'', action:'allow', resources:['secure-notes'], claims:{} }); push({ title:'Rule saved', bg:'success' }); load();
    } catch(e:any){ push({ title:'Save failed', body:String(e?.message||e), bg:'danger' }); }
  };

  const pushToVerifier = async () => {
    const r = await fetch('/api/policies', { method:'PUT' });
    if (r.ok) push({ title:'Policies pushed to verifier', bg:'success' });
    else push({ title:'Push failed', bg:'danger', body: await r.text() });
  };

  return (
    <Layout title="Policies">
      <Row className="g-3">
        <Col md={5}>
          <Card><Card.Body>
            <Card.Title>Create / Edit Rule</Card.Title>
            <Form onSubmit={submit}>
              <Form.Group className="mb-2"><Form.Label>Name</Form.Label>
                <Form.Control value={form.name} onChange={e=>setForm({...form, name:e.target.value})} required/>
              </Form.Group>
              <Form.Group className="mb-2"><Form.Label>Action</Form.Label>
                <Form.Select value={form.action} onChange={e=>setForm({...form, action:e.target.value as any})}>
                  <option value="allow">allow</option><option value="deny">deny</option>
                </Form.Select>
              </Form.Group>
              <Form.Group className="mb-2"><Form.Label>Resources (comma)</Form.Label>
                <Form.Control value={Array.isArray(form.resources)?form.resources.join(','):form.resources as any}
                  onChange={e=>setForm({...form, resources: e.target.value as any})}/>
              </Form.Group>
              <Form.Group className="mb-2"><Form.Label>Condition (optional, JS)</Form.Label>
                <Form.Control placeholder='e.g. user.roles.includes("admin")' value={form.condition||''}
                  onChange={e=>setForm({...form, condition: e.target.value})}/>
              </Form.Group>
              <Form.Group className="mb-3"><Form.Label>Claims (JSON)</Form.Label>
                <Form.Control as="textarea" rows={4} value={JSON.stringify(form.claims??{}, null, 2)}
                  onChange={e=>{ try{ setForm({...form, claims: JSON.parse(e.target.value||'{}')}); } catch{ /* ignore */ } }}/>
              </Form.Group>
              <div className="d-flex gap-2">
                <Button type="submit">Save Rule</Button>
                <Button variant="secondary" onClick={()=>setForm({ id:'', name:'', action:'allow', resources:['secure-notes'], claims:{} })}>Reset</Button>
              </div>
            </Form>
          </Card.Body></Card>
        </Col>
        <Col md={7}>
          <Card><Card.Body>
            <Card.Title>Current Rules</Card.Title>
            <Table hover size="sm">
              <thead><tr><th>Name</th><th>Action</th><th>Resources</th><th>Claims</th></tr></thead>
              <tbody>{rules.map(r=>(
                <tr key={r.id} onClick={()=>setForm(r)} style={{cursor:'pointer'}}>
                  <td>{r.name}</td><td>{r.action}</td><td>{r.resources?.join(', ')}</td>
                  <td><code className="small">{JSON.stringify(r.claims??{})}</code></td>
                </tr>
              ))}</tbody>
            </Table>
            <div className="d-grid"><Button onClick={pushToVerifier}>Push to Verifier</Button></div>
          </Card.Body></Card>
        </Col>
      </Row>
    </Layout>
  );
}

