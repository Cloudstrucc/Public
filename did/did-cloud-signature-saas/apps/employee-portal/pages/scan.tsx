import { useRouter } from 'next/router';
import Layout from '../components/Layout';
import { Card } from 'react-bootstrap';
import { useCallback } from 'react';
import dynamic from 'next/dynamic';

const QRScanner = dynamic(()=>import('../components/QRScanner'), { ssr:false });

export default function Scan() {
  const router = useRouter();
  const onText = useCallback((txt: string) => {
    try {
      const u = new URL(txt);
      const vc = u.searchParams.get('vc');
      if (vc) { router.push(`/import?vc=${encodeURIComponent(vc)}`); return; }
    } catch {}
    if (txt.length > 20) router.push(`/import?vc=${encodeURIComponent(txt)}`);
  }, [router]);

  return (
    <Layout title="Scan QR">
      <Card><Card.Body>
        <QRScanner onText={onText} />
        <div className="mt-3 text-muted small">Point your camera at the Admin QR (VC) or a credential-offer link.</div>
      </Card.Body></Card>
    </Layout>
  );
}
