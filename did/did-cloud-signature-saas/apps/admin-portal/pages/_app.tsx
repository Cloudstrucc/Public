import type { AppProps } from 'next/app';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../styles/globals.css';
import { ToasterProvider } from '../components/toaster';

export default function App({ Component, pageProps }: AppProps) {
  return (
    <ToasterProvider>
      <Component {...pageProps} />
    </ToasterProvider>
  );
}

