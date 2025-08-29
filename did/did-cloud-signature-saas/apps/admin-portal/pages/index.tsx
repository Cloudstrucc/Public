import Layout from '../components/Layout';
import { Card, Col, Row } from 'react-bootstrap';

export default function Home() {
  return (
    <Layout title="Dashboard">
      <Row className="g-3">
        <Col md={4}><Card><Card.Body><Card.Title>Organizations</Card.Title><div className="text-muted">Create & manage issuing orgs.</div></Card.Body></Card></Col>
        <Col md={4}><Card><Card.Body><Card.Title>Issue Credentials</Card.Title><div className="text-muted">Mint employee credentials.</div></Card.Body></Card></Col>
        <Col md={4}><Card><Card.Body><Card.Title>Policies</Card.Title><div className="text-muted">Control access via claims.</div></Card.Body></Card></Col>
      </Row>
    </Layout>
  );
}

