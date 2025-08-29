import Link from 'next/link';
import { ReactNode } from 'react';
import { Container, Nav, Navbar } from 'react-bootstrap';

export default function Layout({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="d-flex" style={{ minHeight: '100vh' }}>
      {/* Sidebar */}
      <div className="bg-light border-end" style={{ width: 260 }}>
        <div className="p-3 border-bottom">
          <strong>DID + Cloud Signature</strong>
          <div className="text-muted small">Admin Portal</div>
        </div>
        <Nav className="flex-column p-2 gap-1">
          <Link href="/" className="nav-link">Dashboard</Link>
          <Link href="/orgs" className="nav-link">Organizations</Link>
          <Link href="/issuance" className="nav-link">Issue Credentials</Link>
          <Link href="/policies" className="nav-link">Policies</Link>
        </Nav>
      </div>

      {/* Main */}
      <div className="flex-grow-1">
        <Navbar bg="white" className="border-bottom">
          <Container fluid>
            <Navbar.Brand className="fw-semibold">{title}</Navbar.Brand>
          </Container>
        </Navbar>
        <main className="p-4">{children}</main>
      </div>
    </div>
  );
}

