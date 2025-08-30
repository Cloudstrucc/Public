// apps/employee-portal/pages/import.tsx
import React, { useEffect, useState } from 'react';
import type { GetServerSideProps } from 'next';
import { Card, Row, Col, Alert, Spinner, Container } from 'react-bootstrap';

const Layout: React.FC<{ title?: string; children: React.ReactNode }> = ({ title, children }) => (
  <Container className="mt-4">
    {title && <h2 className="mb-4">{title}</h2>}
    {children}
  </Container>
);

// If you already have a shared env util, import from there instead:
const ISSUER_URL =
  process.env.NEXT_PUBLIC_ISSUER_URL ||
  process.env.ISSUER_URL ||
  'http://localhost:3004';

type OfferGrants = {
  ['urn:ietf:params:oauth:grant-type:pre-authorized_code']: {
    'pre-authorized_code': string;
    tx_code?: { length: number; input_mode: string };
  };
};

type OfferPayload = {
  credential_issuer: string;
  credential_configuration_ids: string[];
  grants: OfferGrants;
};

type Props = {
  initialTxId: string | null;
};

export const getServerSideProps: GetServerSideProps<Props> = async (ctx) => {
  const txId = ctx.query.txId?.toString() ?? null;
  return { props: { initialTxId: txId } };
};

export default function ImportPage({ initialTxId }: Props) {
  const [offer, setOffer] = useState<OfferPayload | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(!!initialTxId);

  useEffect(() => {
    let abort = false;

    async function fetchOffer() {
      if (!initialTxId) return;
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(
          `${ISSUER_URL}/oidc/credential-offer/${encodeURIComponent(initialTxId)}`
        );
        if (!res.ok) {
          const txt = await res.text();
          throw new Error(
            `Offer not found (status ${res.status}). ${txt?.slice(0, 200)}`
          );
        }
        const json = (await res.json()) as OfferPayload;
        if (!abort) setOffer(json);
      } catch (e: any) {
        if (!abort) setError(String(e?.message || e));
      } finally {
        if (!abort) setLoading(false);
      }
    }

    fetchOffer();
    return () => {
      abort = true;
    };
  }, [initialTxId]);

  return (
    <Layout title="Import Credential">
      <Row className="mb-4">
        <Col>
          <h3>Import Credential</h3>
          {!initialTxId && (
            <Alert variant="warning" className="mt-3">
              No <code>txId</code> was provided. Open this page from the Admin
              portal “Open Employee Portal to Track” button, or visit:
              <div className="mt-2">
                <code>http://localhost:3010/import?txId=&lt;offerCode&gt;</code>
              </div>
            </Alert>
          )}
        </Col>
      </Row>

      {initialTxId && (
        <Row>
          <Col md={8}>
            <Card className="mb-3">
              <Card.Body>
                <Card.Title>Tracking transaction</Card.Title>
                <div className="text-muted mb-2">
                  txId: <code>{initialTxId}</code>
                </div>

                {loading && (
                  <div className="d-flex align-items-center">
                    <Spinner animation="border" size="sm" className="me-2" />
                    <span>Loading offer…</span>
                  </div>
                )}

                {error && (
                  <Alert variant="danger" className="mt-3">
                    {error}
                  </Alert>
                )}

                {offer && (
                  <>
                    <Alert variant="success" className="mt-3">
                      Offer found from issuer: <code>{offer.credential_issuer}</code>
                    </Alert>
                    <div className="mb-2">
                      <strong>Configuration IDs:</strong>{' '}
                      {offer.credential_configuration_ids.join(', ')}
                    </div>

                    {'urn:ietf:params:oauth:grant-type:pre-authorized_code' in
                      offer.grants && (
                      <div className="text-muted">
                        Grant type: <code>pre-authorized_code</code>
                        {offer.grants[
                          'urn:ietf:params:oauth:grant-type:pre-authorized_code'
                        ]?.tx_code && (
                          <>
                            {' '}
                            • Requires TX code of length{' '}
                            {
                              offer.grants[
                                'urn:ietf:params:oauth:grant-type:pre-authorized_code'
                              ]!.tx_code!.length
                            }{' '}
                            (
                            {
                              offer.grants[
                                'urn:ietf:params:oauth:grant-type:pre-authorized_code'
                              ]!.tx_code!.input_mode
                            }
                            )
                          </>
                        )}
                      </div>
                    )}

                    <Alert variant="info" className="mt-3">
                      <div className="mb-2 fw-bold">How to complete on a wallet:</div>
                      <ol className="mb-0">
                        <li>In the Admin portal, show the QR (OIDC4VCI offer).</li>
                        <li>
                          Scan with an OIDC4VCI-capable wallet (e.g., Trinsic, Lissi).
                          For mobile testing, expose issuer with <code>ngrok http 3004</code>{' '}
                          and regenerate the QR.
                        </li>
                        <li>The wallet redeems the offer and receives the credential.</li>
                      </ol>
                    </Alert>
                  </>
                )}
              </Card.Body>
            </Card>
          </Col>
        </Row>
      )}
    </Layout>
  );
}
