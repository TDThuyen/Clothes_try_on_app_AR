// app_be/src/modules/chatbot/chatbot.route.ts

import { Router } from "express";
import { handleChatbotMessage } from "./chatbot.service";

const router = Router();

router.post("/", async (req, res, next) => {
  try {
    const { message, productId } = req.body;

    if (!message || typeof message !== "string") {
      return res.status(400).json({ error: "message is required" });
    }

    // nếu mày có middleware auth thì gắn user vào req
    const userId = (req as any).user?.id as number | undefined;

    const result = await handleChatbotMessage({
      userId,
      message,
      productId,
    });

    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;
