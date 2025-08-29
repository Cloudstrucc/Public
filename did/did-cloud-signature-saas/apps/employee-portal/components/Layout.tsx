import Head from 'next/head';
import Container from 'react-bootstrap/Container';
import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';

type Props = { title?: string; children: React.ReactNode };

export default function Layout({ title = 'Employee Portal', children }: Props) {
  return (
    <>
      <Head><title>{title}</title></Head>
      <Navbar expand="lg" bg="light" className="mb-4">
        <Container>
          <Navbar.Brand href="/">Employee Portal</Navbar.Brand>
          <Nav className="me-auto">
            <Nav.Link href="/scan">Scan</Nav.Link>
            <Nav.Link href="/import">Import</Nav.Link>
            <Nav.Link href="/dashboard">Dashboard</Nav.Link>
          </Nav>
        </Container>
      </Navbar>
      <Container>{children}</Container>
    </>
  );
}
