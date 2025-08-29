import React, { useEffect, useState } from 'react';
import Link from 'next/link';

export default function ScanPage() {
  const [code, setCode] = useState<string>('');
  const [status, setStatus] = useState<'idle'|'pending'|'ready'|'error'>('idle');
  const [credential, setCredential] = useState<string>('');
  const [err, setErr] = useState<string>('');

  useEffect(() => {
    const url = new URL(window.location.href);
    const c = url.searchParams.get('code') || '';
    setCode(c);
    if (!c) {
      setStatus('error');
      setErr('Missing ?code');
      return;
    }
    setStatus('pending');

    let alive = true;
    const tick = async () => {
      try {
        const r = await fetch(`/api/offer-status?code=${encodeURIComponent(c)}`);
        const data = await r.json();
        if (!alive) return;

        if (data.status === 'ready' && data.credential) {
          setStatus('ready');
          setCredential(data.credential);
        } else if (data.status === 'pending') {
          setTimeout(tick, 2000);
        } else {
          setStatus('error');
          setErr(data?.error || 'Unknown status');
        }
      } catch (e: any) {
        if (!alive) return;
        setStatus('error');
        setErr(e?.message || String(e));
      }
    };

    tick();
    return () => { alive = false; };
  }, []);

  return (
    <div style={{ maxWidth: 720, margin: '2rem auto', padding: '1rem' }}>
      <h2>Scan / Poll Credential</h2>
      {!code && <p className="text-danger">No code provided.</p>}
      {status === 'pending' && <p>Waiting for wallet to complete… (auto-refreshing)</p>}
      {status === 'error' && <p className="text-danger">Error: {err}</p>}
      {status === 'ready' && (
        <>
          <p className="text-success">Credential is ready!</p>
          <details>
            <summary>Show VC JWT</summary>
            <pre style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>{credential}</pre>
          </details>
          <p className="mt-3">
            You can copy this JWT into your dev wallet or keep it for testing.
          </p>
        </>
      )}
      <p className="mt-4">
        <Link href="/">Back home</Link>
      </p>
    </div>
  );
}
