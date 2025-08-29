import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3006;

app.use(cors());
app.use(express.json());

app.post('/sign', async (req, res) => {
  try {
    const { pdfData, signingCertificate, timestampUrl } = req.body;
    console.log('Signing PDF with PAdES…', { hasPdf: !!pdfData, signingCertificate: !!signingCertificate, timestampUrl });
    res.json({ signedPdf: 'base64-encoded-signed-pdf', signatureId: 'signature-id' });
  } catch (error) {
    console.error('Error signing PDF:', error);
    res.status(500).json({ error: 'Failed to sign PDF' });
  }
});

app.listen(PORT, () => console.log(`Signing Adapter running on port ${PORT}`));
