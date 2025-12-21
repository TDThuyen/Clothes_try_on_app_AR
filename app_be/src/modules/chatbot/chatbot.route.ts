// app_be/src/modules/chatbot/chatbot.route.ts

import { Router } from 'express';
import multer from 'multer';
import { chatbotService, handleChatbotMessage } from './chatbot.service';

const router = Router();

router.post('/', async (req, res, next) => {
  try {
    const { message, productId, sessionId } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'message is required' });
    }

    const userId = (req as any).user?.id as number | undefined;

    const result = await handleChatbotMessage({
      userId,
      message,
      productId,
      sessionId,
    });

    res.json(result);
  } catch (err) {
    next(err);
  }
});

const upload = multer({ storage: multer.memoryStorage() });

router.post('/face-analyze', upload.single('file'), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'file is required' });
    }

    /**
     * Forward image to internal Python Face Tracker service
     * This keeps Python service internal & secure
     */
    const result = await chatbotService.analyzeFaceWithInternalService(req.file);

    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;
