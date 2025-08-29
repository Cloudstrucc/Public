import { createContext, useContext, useMemo, useState } from 'react';
import { Toast, ToastContainer } from 'react-bootstrap';

type ToastMsg = { id: string; title: string; body?: string; bg?: 'success'|'danger'|'info'|'warning' };
const ToasterCtx = createContext<{ push: (m: Omit<ToastMsg,'id'>)=>void }>({ push: () => {} });

export function ToasterProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastMsg[]>([]);
  const push = (m: Omit<ToastMsg,'id'>) => {
    setItems(prev => [...prev, { id: String(Date.now()+Math.random()), ...m }]);
    setTimeout(() => setItems(prev => prev.slice(1)), 4000);
  };
  const v = useMemo(()=>({ push }),[]);
  return (
    <ToasterCtx.Provider value={v}>
      {children}
      <ToastContainer position="bottom-end" className="p-3">
        {items.map(t => (
          <Toast key={t.id} bg={t.bg ?? 'info'}>
            <Toast.Header closeButton={false}><strong className="me-auto">{t.title}</strong></Toast.Header>
            {t.body && <Toast.Body className="text-white">{t.body}</Toast.Body>}
          </Toast>
        ))}
      </ToastContainer>
    </ToasterCtx.Provider>
  );
}
export function useToaster(){ return useContext(ToasterCtx); }

