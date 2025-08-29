import { useEffect, useState } from 'react';
import Layout from '../components/Layout';

export default function Import() {
  const [vc, setVc] = useState('');
  useEffect(() => {
    const url = new URL(window.location.href);
    const qp = url.searchParams.get('vc');
    if (qp) setVc(qp);
  }, []);
  return (
    <Layout title="Import Credential">
      <p>Paste or prefilled VC JWT:</p>
      <textarea className="form-control" rows={6} value={vc} onChange={e=>setVc(e.target.value)} />
      <div className="mt-3"><button className="btn btn-primary" onClick={() => alert('Saved locally (demo).')}>Save</button></div>
    </Layout>
  );
}
