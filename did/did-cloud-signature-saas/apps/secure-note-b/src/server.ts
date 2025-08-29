import express from 'express';
import cors from 'cors';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';

const app = express();
const PORT = process.env.PORT || 3003;

app.use(cors());
app.use(express.json());

// NOTE: For production, replace this with robust envelope encryption & KMS/HSM key handling
app.post('/secure-note-b', async (req, res) => {
  try {
    const { text, recipients } = req.body;
    const noteId = crypto.randomUUID();

    const key = crypto.randomBytes(32);
    const iv = crypto.randomBytes(12); // GCM best practice
    const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
    const ciphertext = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()]);
    const tag = cipher.getAuthTag();

    // In reality, persist ciphertext and wrap 'key' for recipients
    const noteData = {
      noteId,
      ciphertext: ciphertext.toString('base64'),
      iv: iv.toString('base64'),
      tag: tag.toString('base64'),
      recipients,
      createdAt: new Date()
    };
    console.log('Created encrypted note:', noteId, noteData);

    res.json({ noteId, title: 'Secure Note', blobRef: `note-${noteId}` });
  } catch (error) {
    console.error('Error creating secure note:', error);
    res.status(500).json({ error: 'Failed to create secure note' });
  }
});

app.get('/secure-note-b/:noteId/view', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'No authorization header' });

    const token = authHeader.split(' ')[1];
    jwt.verify(token, process.env.JWT_SECRET || 'dev-secret');

    // Placeholder: fetch note + unwrap key for requester, then decrypt
    res.json({ plaintext: 'Decrypted content placeholder' });
  } catch (error) {
    console.error('Error decrypting note:', error);
    res.status(500).json({ error: 'Failed to decrypt note' });
  }
});

app.listen(PORT, () => console.log(`Secure Note B service running on port ${PORT}`));
