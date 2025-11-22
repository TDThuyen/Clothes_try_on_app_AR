// app_be/src/modules/chatbot/styleGuides.ts
export type StyleGuide = {
  id: string;
  title: string;
  targetGender?: "male" | "female";
  minAge?: number;
  maxAge?: number;
  minBudget?: number;
  maxBudget?: number;
  content: string;
};

export const STYLE_GUIDES: StyleGuide[] = [
  {
    id: "student_budget",
    title: "Gợi ý outfit cho sinh viên ngân sách dưới 500k",
    targetGender: "unisex",
    minAge: 16,
    maxAge: 25,
    minBudget: 200000,
    maxBudget: 500000,
    content: `
- Ưu tiên áo thun basic màu trung tính (trắng, đen, xám).
- Kết hợp với quần jean hoặc quần kaki tối màu, dễ phối nhiều outfit.
- Tránh đồ quá trend, in hình quá nổi hoặc màu quá chói.
    `,
  },
  // ... thêm dần
];
