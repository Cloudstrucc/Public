// temporary probe
console.log('Layout is', Layout); // should log a function, not undefined


import { useEffect, useState } from 'react';
import Layout from '../../components/Layout';
import { Alert, Button, Card, Col, Container, Form, Row } from 'react-bootstrap';
import { QRCodeCanvas as QRCode } from 'qrcode.react';   // <-- named export
import { useToaster } from '../../components/toaster';

export default function IssuancePage() {
  const [orgs, setOrgs] = useState<any[]>([]);
  const [form, setForm] = useState({ orgId: '', givenName: '', employeeId: '', department: 'IT' });
  const [vc, setVc] = useState<string>(''); 
  const [error, setError] = useState<string>('');
  const { push } = useToaster();

  useEffect(()=>{(async()=>{
    const j = await (await fetch('/api/orgs')).json(); 
    setOrgs(j.orgs);
    setForm(f=>({...f, orgId:j.orgs?.[0]?.id || ''}));
  })()},[]);

  const submit = async (e:any) => {
    e.preventDefault(); setError(''); setVc('');
    try {
      const subjectDid = await (await fetch('/api/holder-did')).json().then(j=>j.did);
      const r = await fetch('/api/issue', {
        method: 'POST', headers: {'content-type':'application/json'},
        body: JSON.stringify({
          subject: subjectDid,
          claims: { givenName: form.givenName, employeeId: form.employeeId, department: form.department },
          expiresInMinutes: 60
        })
      });
      const j = await r.json();
      if (!r.ok || !j?.vc) { setError(j?.error || 'Issuance failed'); push({ title:'Issuance failed', bg:'danger' }); return; }
      setVc(j.vc); push({ title:'Credential issued', bg:'success' });
    } catch (e:any) { setError(String(e?.message||e)); push({ title:'Issuance error', body:String(e?.message||e), bg:'danger' }); }
  };

  return (
    <Layout title="Issue Credentials">
      <Container fluid>
        <Row className="g-3">
          <Col md={5}>
            <Card><Card.Body>
              <Card.Title>Credential details</Card.Title>
              <Form onSubmit={submit}>
                <Form.Group className="mb-3"><Form.Label>Organization</Form.Label>
                  <Form.Select value={form.orgId} onChange={e=>setForm({...form, orgId:e.target.value})}>
                    {orgs.map((o:any)=> <option key={o.id} value={o.id}>{o.name}</option>)}
                  </Form.Select>
                </Form.Group>
                <Form.Group className="mb-3"><Form.Label>Given Name</Form.Label>
                  <Form.Control required value={form.givenName} onChange={e=>setForm({...form, givenName:e.target.value})}/>
                </Form.Group>
                <Form.Group className="mb-3"><Form.Label>Employee ID</Form.Label>
                  <Form.Control required value={form.employeeId} onChange={e=>setForm({...form, employeeId:e.target.value})}/>
                </Form.Group>
                <Form.Group className="mb-3"><Form.Label>Department</Form.Label>
                  <Form.Control value={form.department} onChange={e=>setForm({...form, department:e.target.value})}/>
                </Form.Group>
                <Button type="submit">Issue</Button>
              </Form>
              {error && <Alert variant="danger" className="mt-3">{error}</Alert>}
            </Card.Body></Card>
          </Col>
          <Col md={7}>
            <Card><Card.Body>
              <Card.Title>Credential QR (VC-JWT)</Card.Title>
              {!vc ? <p className="text-muted">Issue a credential to see the QR here.</p> :
                <>
                  <div className="d-flex justify-content-center my-3">
                    <QRCode value={vc} size={240} />
                  </div>
                  <div className="d-flex gap-2">
                    <Button onClick={()=>navigator.clipboard.writeText(vc)}>Copy VC</Button>
                    <Button variant="secondary" onClick={()=>{
                      const blob=new Blob([vc],{type:'text/plain'});
                      const url=URL.createObjectURL(blob);
                      const a=document.createElement('a'); a.href=url; a.download='credential.jwt.txt'; a.click();
                      URL.revokeObjectURL(url);
                    }}>Download</Button>
                  </div>
                  <p className="mt-3 small text-muted">For Entra, swap this to the Issuance Request QR.</p>
                </>
              }
            </Card.Body></Card>
          </Col>
        </Row>
      </Container>
    </Layout>
  );
}

