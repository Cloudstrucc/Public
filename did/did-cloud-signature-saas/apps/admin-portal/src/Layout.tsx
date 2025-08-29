import React from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import { Container, Navbar } from 'react-bootstrap';

type Props = { children: React.ReactNode };

export default function Layout({ children }: Props) {
  return (
    <>
      <Navbar bg="light" className="mb-4">
        <Container>
          <Navbar.Brand>DID + VC Admin</Navbar.Brand>
        </Container>
      </Navbar>
      <Container>{children}</Container>
    </>
  );
}

