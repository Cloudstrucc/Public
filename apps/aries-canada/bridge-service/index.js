const express = require('express');
const axios = require('axios');
require('dotenv').config();
const app = express();
app.use(express.json());

app.post('/issue', async (req, res) => {
  const { subjectDid, claims } = req.body;
  try {
    const response = await axios.post(
      'https://verifiedid.did.msidentity.com/v1.0/issue',
      {
        includeQRCode: false,
        authority: process.env.VERIFIED_ID_AUTHORITY,
        registration: { clientName: 'Aries Canada Issuer' },
        callback: { url: process.env.CALLBACK_URL, state: '123456' },
        claims
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.ENTRA_ACCESS_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    );
    res.json(response.data);
  } catch (error) {
    console.error('Error issuing credential:', error.response?.data || error.message);
    res.status(500).send('Credential issuance failed.');
  }
});

app.listen(4000, () => console.log('Bridge service running on port 4000'));
