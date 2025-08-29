import { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).json({ message: 'Method not allowed' });

  try {
    const { text, audiences, design, labelId } = req.body;

    const adaptiveCard = {
      type: "AdaptiveCard",
      version: "1.4",
      body: [
        { type: "TextBlock", text: "Secure Note Created", weight: "Bolder", size: "Medium" },
        { type: "TextBlock", text: "Click to view encrypted content", wrap: true }
      ],
      actions: [
        { type: "Action.Submit", title: design === 'A' ? "Open Secure Note" : "Decrypt", data: { action: "view", noteId: "generated-note-id" } }
      ]
    };

    res.status(200).json({ card: adaptiveCard, meta: { audiences, labelId } });
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
}
