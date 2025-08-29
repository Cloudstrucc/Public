import express from 'express';
import cors from 'cors';
import { MIPWrapper } from '@saas/mip-wrapper';

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());

const mipWrapper = new MIPWrapper();

app.post('/secure-note-a', async (req, res) => {
  try {
    const { text, labelId, audiences } = req.body;
    const htmlContent = await renderToHtml(text);
    const protectedFile = await mipWrapper.applyLabel(Buffer.from(htmlContent), labelId);
    const fileUrl = await uploadToSharePoint(protectedFile);
    res.json({ fileUrl, fileId: 'generated-file-id', title: 'Secure Note', audiences });
  } catch (error) {
    console.error('Error creating secure note:', error);
    res.status(500).json({ error: 'Failed to create secure note' });
  }
});

async function renderToHtml(text: string): Promise<string> {
  return `<!DOCTYPE html>
<html>
<head><title>Secure Note</title></head>
<body>
  <div style="padding: 20px; font-family: Arial, sans-serif;">
    <h2>Secure Note</h2>
    <p>${text}</p>
    <small>Created: ${new Date().toISOString()}</small>
  </div>
</body>
</html>`;
}

async function uploadToSharePoint(_file: Buffer): Promise<string> {
  console.log('Uploading to SharePoint...');
  return 'https://tenant.sharepoint.com/sites/secnotes/file.html';
}

app.listen(PORT, () => console.log(`Secure Note A service running on port ${PORT}`));
