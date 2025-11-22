// src/modules/chatbot/chatbot.service.ts

import { getPrisma } from '../../common/prisma';
import { geminiModel } from '../../lib/googleAI'; // 👈 dùng Google AI
import { STYLE_GUIDES } from './styleGuides';
import { FAQS } from './faqs';
import { parseUserContextFromMessage } from './parser';

export type HandleChatbotMessageOptions = {
  userId?: number;
  message: string;
  productId?: number;
};

export class ChatbotService {
  private prisma = getPrisma();

  // Hàm shuffle để mỗi lần gợi ý sản phẩm có thứ tự khác nhau
  private shuffleArray<T>(array: T[]): T[] {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }

  async handleChatbotMessage(options: HandleChatbotMessageOptions) {
    const { userId, message, productId } = options;

    const parsed = parseUserContextFromMessage(message);

    // 1. Lấy user nếu cần (để sau này suy ra gender, sở thích, v.v.)
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

    // 2. Lấy danh sách sản phẩm liên quan (RAG retrieve)
    let products: any[] = [];

    if (productId) {
      // Hỏi về 1 sản phẩm cụ thể (từ trang detail)
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
      // Hỏi tư vấn chung theo tuổi / tài chính / màu / loại
      const whereAnd: any[] = [];

      // --- budget ---
      if (parsed.budget) {
        whereAnd.push({ price: { lte: parsed.budget } });
      }

      // --- màu sắc: lấy màu đầu tiên parse được ---
      if (parsed.colors && parsed.colors.length > 0) {
        whereAnd.push({
          color: { contains: parsed.colors[0] }, // 'đen', 'trắng', 'xanh',...
        });
      }

      // --- loại đồ: jean, áo, quần, kính, mũ ---
      if (parsed.itemTypes && parsed.itemTypes.length > 0) {
        const types = parsed.itemTypes;
        const typeOr: any[] = [];

        const pushKeyword = (kw: string) => {
          typeOr.push(
            { category: { name: { contains: kw } } },
            { name: { contains: kw } },
          );
        };

        if (types.includes('jean')) {
          pushKeyword('jean');
        }

        if (types.includes('ao')) {
          // áo / áo thun / áo sơ mi ...
          pushKeyword('áo');
        }

        if (types.includes('quan')) {
          // quần nói chung → ưu tiên từ "quần"
          pushKeyword('quần');
        }

        if (types.includes('kinh')) {
          pushKeyword('kính');
          pushKeyword('kinh'); // phòng trường hợp không dấu
        }

        if (types.includes('mu')) {
          pushKeyword('mũ');
          pushKeyword('nón');
        }

        if (typeOr.length > 0) {
          whereAnd.push({ OR: typeOr });
        }
      }

      const where = whereAnd.length ? { AND: whereAnd } : undefined;

      try {
        if (where) {
          /**
           * ✅ Có điều kiện lọc rõ ràng từ câu hỏi
           * → Chỉ lấy những sản phẩm đáp ứng câu hỏi (WHERE)
           * → Không giới hạn 5, mà trả về toàn bộ match (để context đầy đủ)
           * → Sau đó shuffle để mỗi lần trả lời thứ tự khác nhau
           */
          const matched = await this.prisma.product.findMany({
            where,
            include: { category: true },
          });

          products = this.shuffleArray(matched);
        } else {
          /**
           * ❓ Không parse được gì từ câu hỏi (không có budget/màu/loại)
           * → Câu hỏi quá chung: gợi ý ngẫu nhiên một vài sản phẩm (ví dụ tối đa 5)
           * → Dùng skip random để mỗi lần gợi ý khác nhau
           */
          const total = await this.prisma.product.count();
          if (total > 0) {
            const take = Math.min(5, total); // vẫn nên giới hạn để context không quá dài
            const maxSkip = Math.max(total - take, 0);
            const skip =
              maxSkip > 0 ? Math.floor(Math.random() * (maxSkip + 1)) : 0;

            const randomProducts = await this.prisma.product.findMany({
              skip,
              take,
              include: { category: true },
            });

            products = this.shuffleArray(randomProducts);
          } else {
            products = [];
          }
        }
      } catch {
        products = [];
      }
    }

    // 3. Chọn style guide phù hợp sơ sơ theo tuổi/budget
    const relatedGuides = STYLE_GUIDES.filter((g) => {
      if (parsed.age && g.minAge && g.minAge > parsed.age) return false;
      if (parsed.age && g.maxAge && g.maxAge < parsed.age) return false;
      if (parsed.budget && g.minBudget && g.minBudget > parsed.budget) return false;
      if (parsed.budget && g.maxBudget && g.maxBudget < parsed.budget) return false;
      return true;
    }).slice(0, 3);

    // 4. Lấy một số FAQ cơ bản
    const faqs = FAQS.slice(0, 5);

    // 5. Build context cho sản phẩm (RAG context)
    const productContext = products
      .map((p) => {
        const gender = (p as any).gender ?? 'không ghi';
        const color = (p as any).color ?? 'không ghi';
        const sizes =
          (p as any).available_sizes ??
          (p as any).availableSizes ??
          'không ghi';

        return `
[PRODUCT]
Tên: ${(p as any).name}
Danh mục: ${(p as any).category?.name ?? 'không rõ'}
Giá: ${(p as any).price?.toLocaleString('vi-VN') ?? 'không rõ'} VND
Giới tính: ${gender}
Màu: ${color}
Size: ${sizes}
Mô tả chi tiết: ${(p as any).description ?? 'không có mô tả chi tiết'}
`.trim();
      })
      .join('\n\n');

    // 6. Context cho style guide
    const guideContext = relatedGuides
      .map(
        (g) => `
[STYLE_GUIDE: ${g.title}]
${g.content}
`.trim(),
      )
      .join('\n\n');

    // 7. Context cho FAQ
    const faqContext = faqs
      .map(
        (f) => `
[FAQ: ${f.topic}]
Q: ${f.question}
A: ${f.answer}
`.trim(),
      )
      .join('\n\n');

    // 8. Thông tin user parse được
    const userInfoText = `
[USER_INFO]
Tuổi (nếu đoán được): ${parsed.age ?? 'không rõ'}
Ngân sách (nếu đoán được): ${
      parsed.budget ? parsed.budget.toLocaleString('vi-VN') + ' VND' : 'không rõ'
    }
`.trim();

    const systemPrompt = `
Bạn là stylist tư vấn thời trang cho ứng dụng bán quần áo trên mobile.
Nhiệm vụ:
- Tư vấn cách ăn mặc dựa trên tuổi, ngân sách, ngữ cảnh (đi học, đi làm, đi chơi...).
- Nếu có danh sách [PRODUCT], hãy gợi ý 2-3 sản phẩm cụ thể, nhắc lại đúng tên sản phẩm để người dùng dễ tìm.
- Giải thích lý do chọn kiểu đồ đó (phù hợp vóc dáng, hoàn cảnh, tài chính).
- Nếu user hỏi về đổi trả, ship, AR... hãy dựa vào phần [FAQ].
- Nói chuyện thân thiện, dễ hiểu, ngắn gọn, dùng tiếng Việt.
- Nếu thiếu thông tin (tuổi, ngân sách, giới tính) thì có thể hỏi lại nhẹ nhàng.
`.trim();

    const fullContext = `
${systemPrompt}

${userInfoText}

[PRODUCT_LIST]
${productContext || 'Không có sản phẩm phù hợp trong danh sách.'}

[STYLE_GUIDES]
${guideContext || 'Không có style guide phù hợp.'}

[FAQS]
${faqContext || 'Không có FAQ.'}

Người dùng hỏi: """${message}"""
`.trim();

    // 9. Gọi Google Gemini
    let outputText = 'Xin lỗi, hiện tại tôi không trả lời được.';

    try {
      const result = await geminiModel.generateContent({
        contents: [
          {
            role: 'user',
            parts: [{ text: fullContext }],
          },
        ],
      });

      const text = result.response.text();
      if (typeof text === 'string' && text.trim().length > 0) {
        outputText = text.trim();
      }
    } catch (err) {
      console.error('[chatbot] Gemini error:', err);
    }

    return {
      answer: outputText,
      products,
    };
  }
}

// Instance giống checkout
export const chatbotService = new ChatbotService();

// Hàm tiện dụng để route cũ vẫn dùng được nếu đang import handleChatbotMessage
export async function handleChatbotMessage(
  options: HandleChatbotMessageOptions,
) {
  return chatbotService.handleChatbotMessage(options);
}
