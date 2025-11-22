// app_be/src/modules/chatbot/faqs.ts
export type Faq = {
  topic: string;
  question: string;
  answer: string;
};

export const FAQS: Faq[] = [
  {
    topic: "shipping",
    question: "Thời gian giao hàng bao lâu?",
    answer:
      "Thông thường giao hàng từ 2-5 ngày làm việc tùy khu vực. Các đơn ở nội thành thường nhanh hơn.",
  },
  {
    topic: "return",
    question: "Chính sách đổi trả như thế nào?",
    answer:
      "Bạn có thể đổi trả trong vòng 7 ngày nếu sản phẩm bị lỗi, sai size hoặc không đúng mô tả. Sản phẩm cần còn tag và chưa qua giặt.",
  },
  // ...
];
