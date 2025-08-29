import React, { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';

type Result = {
  status: 'pending' | 'issued' | 'error';
  vc?: string;
  error?: string;
};

export default function ImportPage() {
  const [status, setStatus] = useState<'idle'|'pending'|'issued'|'error'>('idle');
  const [vc, setVc] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);

  const txId = useMemo(() => {
    if (typeof window === 'undefined') return '';
    const u = new URL(window.location.href);
    return u.searchParams.get('txId') || '';
  }, []);

  useEffect(() => {
    if (!txId) return;

    setStatus('pending');
    let stop = false;

    async function once() {
      try {
        const r = await fetch(`/api/oidc/status?txId=${encodeURIComponent(txId)}`);
        const json: Result = await r.json();
        if (!r.ok) throw new Error(json?.error || 'poll_failed');

        if (json.status === 'issued' && json.vc) {
          setVc(json.vc);
          setStatus('issued');
          return true; // stop
        }
        if (json.status === 'error') {
          setErr(json?.error || 'issuer_error');
          setStatus('error');
          return true; // stop
        }
        // still pending
        return false;
      } catch (e: any) {
        setErr(String(e?.message || e));
        setStatus('error');
        return true; // stop
      }
    }

    // poll until issued/error
    (async () => {
      while (!stop) {
        const done = await once();
        if (done) break;
        await new Promise((r) => setTimeout(r, 2000));
      }
    })();

    return () => { stop = true; };
  }, [txId]);

  function downloadVc() {
    if (!vc) return;
    const blob = new Blob([vc], { type: 'application/jwt' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `credential-${txId}.jwt.txt`;
    a.click();
  }

  return (
    <div style={{ maxWidth: 720, margin: '40px auto', padding: 16 }}>
      <h3>Import Credential</h3>
      {!txId && (
        <p className="text-muted">No <code>txId</code> was provided. Try opening this page from the Admin “Open Employee Portal to Track” button.</p>
      )}

      {txId && (
        <p className="text-muted">
          Tracking transaction <code>{txId}</code>. Keep this page open while you scan and accept the offer in your wallet.
        </p>
      )}

      {status === 'pending' && (
        <p>Waiting for wallet to complete issuance…</p>
      )}

      {status === 'issued' && vc && (
        <>
          <div className="alert alert-success">
            Credential issued! You can save the raw JWT below or import into a developer wallet.
          </div>
          <pre style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word', background:'#f6f6f6', padding:12, borderRadius:8 }}>
{vc}
          </pre>

          <div className="d-flex gap-2">
            <button className="btn btn-primary" onClick={downloadVc}>Download VC (JWT)</button>
            <Link className="btn btn-outline-secondary" href="/scan">Scan Another</Link>
          </div>
        </>
      )}

      {status === 'error' && (
        <div className="alert alert-danger">
          {err || 'An error occurred'}
        </div>
      )}
    </div>
  );
}

