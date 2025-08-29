import React, { useState } from 'react';
import Layout from '../../src/Layout';
import { Card, Row, Col, Button, Form, Spinner, Alert } from 'react-bootstrap';
import { EMPLOYEE_PORTAL_URL } from '../../src/lib/env';

export default function IssuancePage() {
  const [givenName, setGivenName] = useState('Alice');
  const [employeeId, setEmployeeId] = useState('E-12345');
  const [department, setDepartment] = useState('IT');
  const [txLen, setTxLen] = useState(0);

  const [loading, setLoading] = useState(false);
  const [error, setErr] = useState<string | null>(null);

  const [qr, setQr] = useState<string | null>(null);
  const [deepLink, setDeepLink] = useState<string | null>(null);
  const [code, setCode] = useState<string | null>(null);

  const handleGenerate = async () => {
    setErr(null);
    setQr(null);
    setDeepLink(null);
    setCode(null);
    setLoading(true);
    try {
      const r = await fetch('/api/issue-offer', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          claims: { givenName, employeeId, department },
          tx_code_length: Number(txLen) || 0,
        }),
      });
      const data = await r.json();
      if (!r.ok) throw new Error(data?.error || 'failed to create offer');

      setQr(data.qr_png_data_url);
      setDeepLink(data.deep_link);
      setCode(data.preAuthorizedCode);
    } catch (e: any) {
      setErr(e?.message || String(e));
    } finally {
      setLoading(false);
    }
  };

  return (
    <Layout title="Issue Credentials">
      <Row className="mb-4">
        <Col md={6}>
          <Card>
            <Card.Body>
              <Card.Title>Create Credential Offer</Card.Title>
              <Form>
                <Form.Group className="mb-2">
                  <Form.Label>Given Name</Form.Label>
                  <Form.Control value={givenName} onChange={(e) => setGivenName(e.target.value)} />
                </Form.Group>
                <Form.Group className="mb-2">
                  <Form.Label>Employee ID</Form.Label>
                  <Form.Control value={employeeId} onChange={(e) => setEmployeeId(e.target.value)} />
                </Form.Group>
                <Form.Group className="mb-3">
                  <Form.Label>Department</Form.Label>
                  <Form.Control value={department} onChange={(e) => setDepartment(e.target.value)} />
                </Form.Group>
                <Form.Group className="mb-3">
                  <Form.Label>TX Code Length (optional)</Form.Label>
                  <Form.Control
                    type="number"
                    min={0}
                    value={txLen}
                    onChange={(e) => setTxLen(Number(e.target.value))}
                  />
                </Form.Group>
                <Button onClick={handleGenerate} disabled={loading}>
                  {loading ? <Spinner size="sm" /> : 'Generate QR'}
                </Button>
              </Form>
              {error && <Alert variant="danger" className="mt-3">{error}</Alert>}
            </Card.Body>
          </Card>
        </Col>

        <Col md={6}>
          <Card>
            <Card.Body>
              <Card.Title>Scan with a Wallet</Card.Title>
              {!qr && <p className="text-muted">Generate an offer to see the QR here.</p>}
              {qr && (
                <>
                  <img src={qr} alt="OIDC4VCI Offer QR" style={{ maxWidth: '100%', height: 'auto' }} />
                  <div className="mt-3">
                    <p className="small text-muted">
                      Deep Link: <code style={{ wordBreak: 'break-all' }}>{deepLink}</code>
                    </p>
                    {code && (
                      <a
                        className="btn btn-outline-primary btn-sm"
                        href={`${EMPLOYEE_PORTAL_URL}/scan?code=${encodeURIComponent(code)}`}
                        target="_blank"
                        rel="noreferrer"
                      >
                        Open Employee Portal (poll)
                      </a>
                    )}
                  </div>
                </>
              )}
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Layout>
  );
}
