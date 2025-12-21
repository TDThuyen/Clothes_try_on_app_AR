import { getPrisma } from '../../common/prisma';
import { geminiModel } from '../../lib/googleAI';
import { STYLE_GUIDES } from './styleGuides';
import { FAQS } from './faqs';
import { parseUserContextFromMessage } from './parser';
import dotenv from 'dotenv';
import crypto from 'crypto';
dotenv.config();

/* =========================================================
   TYPES
   ========================================================= */

export type HandleChatbotMessageOptions = {
  userId?: number;
  sessionId?: string; // 🔑 face session id (from scan)
  message: string;
  productId?: number;
};

type FaceSessionData = {
  age: number;
  gender: string;
  createdAt: number;
};

/* =========================================================
   CONFIG
   ========================================================= */

const FACE_TRACKER_API: string = process.env.FACE_TRACKER_API ?? '';
if (!FACE_TRACKER_API) {
  throw new Error('FACE_TRACKER_API is not defined in .env');
}

// Face session TTL: 1 day
const FACE_SESSION_TTL = 60 * 24 * 60 * 1000;

/* =========================================================
   IN-MEMORY FACE SESSION STORE
   - 1 session = 1 scan
   - Chat ONLY reads, never updates
   - In production: use Redis
   ========================================================= */

const faceSessionStore = new Map<string, FaceSessionData>();

/* ========================================================= */

export class ChatbotService {
  private prisma = getPrisma();

  /* =========================================================
     UTILS
     ========================================================= */

  private shuffleArray<T>(array: T[]): T[] {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }

  /* =========================================================
     CHATBOT MAIN ENTRY
     - Reuse SAME face session for all chats
     - Session only changes when user scans face again
     ========================================================= */

  async handleChatbotMessage(options: HandleChatbotMessageOptions) {
    const { userId, sessionId, message, productId } = options;

    console.log('[CHATBOT] incoming message:', {
      message,
      sessionId: sessionId ?? 'NONE',
    });

    const parsed = parseUserContextFromMessage(message);

    /* ---------------- FACE SESSION LOOKUP ---------------- */

    let faceSession: FaceSessionData | undefined;

    if (sessionId && faceSessionStore.has(sessionId)) {
      const stored = faceSessionStore.get(sessionId)!;

      // ⏱️ Expire old sessions
      if (Date.now() - stored.createdAt < FACE_SESSION_TTL) {
        faceSession = stored;
        console.log('[CHATBOT] using face session:', sessionId, stored);
      } else {
        faceSessionStore.delete(sessionId);
        console.log('[CHATBOT] face session expired:', sessionId);
      }
    } else if (sessionId) {
      console.log('[CHATBOT] face session NOT FOUND:', sessionId);
    }

    /* ---------------- USER FETCH (OPTIONAL) ---------------- */

    let user: any = null;
    if (userId) {
      try {
        user = await this.prisma.user.findUnique({
          where: { id: userId },
        });
      } catch {
        user = null;
      }
    }

    /* ---------------- PRODUCT RETRIEVAL (RAG) ---------------- */

    let products: any[] = [];

    if (productId) {
      try {
        const p = await this.prisma.product.findUnique({
          where: { id: productId },
          include: { category: true },
        });
        products = p ? [p] : [];
      } catch {
        products = [];
      }
    } else {
      const whereAnd: any[] = [];

      if (parsed.budget) {
        whereAnd.push({ price: { lte: parsed.budget } });
      }

      if (parsed.colors?.length) {
        whereAnd.push({ color: { contains: parsed.colors[0] } });
      }

      if (parsed.itemTypes?.length) {
        const or: any[] = [];

        const push = (kw: string) =>
          or.push({ category: { name: { contains: kw } } }, { name: { contains: kw } });

        if (parsed.itemTypes.includes('jean')) push('jean');
        if (parsed.itemTypes.includes('ao')) push('áo');
        if (parsed.itemTypes.includes('quan')) push('quần');
        if (parsed.itemTypes.includes('kinh')) {
          push('kính');
          push('kinh');
        }
        if (parsed.itemTypes.includes('mu')) {
          push('mũ');
          push('nón');
        }

        if (or.length) whereAnd.push({ OR: or });
      }

      const where = whereAnd.length ? { AND: whereAnd } : undefined;

      try {
        if (where) {
          const matched = await this.prisma.product.findMany({
            where,
            include: { category: true },
          });
          products = this.shuffleArray(matched);
        } else {
          const total = await this.prisma.product.count();
          if (total > 0) {
            const take = Math.min(5, total);
            const skip = total > take ? Math.floor(Math.random() * (total - take + 1)) : 0;

            products = await this.prisma.product.findMany({
              skip,
              take,
              include: { category: true },
            });
          }
        }
      } catch {
        products = [];
      }
    }

    /* ---------------- STYLE GUIDES ---------------- */

    const relatedGuides = STYLE_GUIDES.filter((g) => {
      if (parsed.age && g.minAge && g.minAge > parsed.age) return false;
      if (parsed.age && g.maxAge && g.maxAge < parsed.age) return false;
      if (parsed.budget && g.minBudget && g.minBudget > parsed.budget) return false;
      if (parsed.budget && g.maxBudget && g.maxBudget < parsed.budget) return false;
      return true;
    }).slice(0, 3);

    /* ---------------- CONTEXT BUILDING ---------------- */

    const productContext = products
      .map((p) => {
        return `
[PRODUCT]
Tên: ${p.name}
Danh mục: ${p.category?.name ?? 'không rõ'}
Giá: ${p.price?.toLocaleString('vi-VN') ?? 'không rõ'} VND
Giới tính: ${p.gender ?? 'không ghi'}
Màu: ${p.color ?? 'không ghi'}
Size: ${p.available_sizes ?? 'không ghi'}
Mô tả: ${p.description ?? 'không có'}
`.trim();
      })
      .join('\n\n');

    const guideContext = relatedGuides.map((g) => `[STYLE_GUIDE]\n${g.content}`).join('\n\n');

    const faqContext = FAQS.slice(0, 5)
      .map((f) => `[FAQ]\nQ: ${f.question}\nA: ${f.answer}`)
      .join('\n\n');

    // 🔑 FINAL USER INFO (FACE SESSION OVERRIDES TEXT)
    const finalAge = faceSession?.age ?? parsed.age;
    const finalGender = faceSession?.gender;

    const userInfoText = `
[USER_INFO]
Tuổi: ${finalAge ?? 'không rõ'}
Giới tính: ${finalGender ?? 'không rõ'}
Ngân sách: ${parsed.budget ? parsed.budget.toLocaleString('vi-VN') + ' VND' : 'không rõ'}
`.trim();

    const systemPrompt = `
Bạn là stylist tư vấn thời trang cho ứng dụng bán quần áo.
Tư vấn dựa trên tuổi, giới tính, ngân sách và hoàn cảnh.
Nói ngắn gọn, thân thiện, tiếng Việt.
`.trim();

    const fullContext = `
${systemPrompt}

${userInfoText}

[PRODUCT_LIST]
${productContext || 'Không có sản phẩm phù hợp.'}

[STYLE_GUIDES]
${guideContext || 'Không có.'}

[FAQS]
${faqContext || 'Không có.'}

Người dùng hỏi: """${message}"""
`.trim();

    /* ---------------- GEMINI CALL ---------------- */

    let outputText = 'Xin lỗi, hiện tại tôi không trả lời được.';

    try {
      console.log('===== PROMPT SENT TO GEMINI =====');
      console.log(fullContext);
      console.log('================================');

      const result = await geminiModel.generateContent({
        contents: [{ role: 'user', parts: [{ text: fullContext }] }],
      });

      const text = result.response.text();
      if (text?.trim()) outputText = text.trim();
    } catch (err) {
      console.error('[Gemini error]', err);
    }

    return {
      answer: outputText,
      products,
    };
  }

  /* =========================================================
     FACE ANALYSIS ENTRY
     - ALWAYS CREATE NEW SESSION
     - Session changes ONLY when user scans again
     ========================================================= */

  async analyzeFaceWithInternalService(file: Multer.File) {
    const form = new FormData();

    const blob = new Blob([file.buffer], {
      type: file.mimetype || 'image/jpeg',
    });

    form.append('file', blob, file.originalname || 'face.jpg');

    const res = await fetch(FACE_TRACKER_API, {
      method: 'POST',
      body: form,
    });

    if (!res.ok) {
      throw new Error(await res.text());
    }

    const data = await res.json();

    if (!data.valid) return data;

    const sessionId = crypto.randomUUID();

    faceSessionStore.set(sessionId, {
      age: data.age,
      gender: data.gender,
      createdAt: Date.now(),
    });

    console.log('[FACE] session created:', sessionId, data);

    return {
      valid: true,
      sessionId,
    };
  }
}

/* =========================================================
   EXPORTS
   ========================================================= */

export const chatbotService = new ChatbotService();

export async function handleChatbotMessage(options: HandleChatbotMessageOptions) {
  return chatbotService.handleChatbotMessage(options);
}
