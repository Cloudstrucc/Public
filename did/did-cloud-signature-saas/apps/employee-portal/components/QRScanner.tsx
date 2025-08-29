import { useEffect, useRef, useState } from 'react';
declare global { interface Window { BarcodeDetector?: any } }

export default function QRScanner({ onText }: { onText: (text: string)=>void }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [err, setErr] = useState<string>('');

  useEffect(() => {
    let stream: MediaStream | null = null;
    let raf = 0;
    let detector: any = null;

    async function start() {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          await videoRef.current.play();
        }
        if (window.BarcodeDetector) detector = new window.BarcodeDetector({ formats: ['qr_code'] });
        tick();
      } catch (e:any) { setErr(e?.message || String(e)); }
    }

    const tick = async () => {
      const v = videoRef.current, c = canvasRef.current;
      if (!v || !c) { raf = requestAnimationFrame(tick); return; }
      const w = v.videoWidth, h = v.videoHeight;
      if (w && h) {
        c.width = w; c.height = h;
        const ctx = c.getContext('2d'); if (ctx) {
          ctx.drawImage(v, 0, 0, w, h);
          if (detector) {
            try {
              const codes = await detector.detect(c);
              if (codes?.[0]?.rawValue) { onText(codes[0].rawValue); return; }
            } catch {}
          }
        }
      }
      raf = requestAnimationFrame(tick);
    };

    start();
    return () => {
      if (raf) cancelAnimationFrame(raf);
      if (stream) stream.getTracks().forEach(t => t.stop());
    };
  }, [onText]);

  return (
    <div>
      <video ref={videoRef} style={{ width: '100%', borderRadius: 12 }} muted playsInline />
      <canvas ref={canvasRef} style={{ display: 'none' }} />
      {err && <div className="text-danger small mt-2">{err}</div>}
    </div>
  );
}
