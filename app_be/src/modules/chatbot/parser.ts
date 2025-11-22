export type ParsedUserContext = {
  age?: number;
  budget?: number;
  colors?: string[];    // ví dụ: ['đen', 'trắng']
  itemTypes?: string[]; // ví dụ: ['ao', 'jean', 'kaki']
};

export function parseUserContextFromMessage(message: string): ParsedUserContext {
  const text = message.toLowerCase();
  const result: ParsedUserContext = {};

  // --- tuổi: "20 tuổi", "18t" ---
  const ageMatch = text.match(/(\d{1,2})\s*(tuoi|tuổi|t)\b/);
  if (ageMatch) {
    const age = parseInt(ageMatch[1], 10);
    if (!isNaN(age)) result.age = age;
  }

  // --- budget: "500k", "1tr", "1 triệu" ---
  let budget: number | undefined;

  const kMatch = text.match(/(\d+)\s*(k|ngan|ngàn|nghìn)\b/);
  if (kMatch) {
    budget = parseInt(kMatch[1], 10) * 1000;
  }

  const trMatch = text.match(/(\d+)\s*(tr|triệu|trieu)\b/);
  if (!budget && trMatch) {
    budget = parseInt(trMatch[1], 10) * 1_000_000;
  }

  if (!budget) {
    const plainNumber = text.match(/(\d{5,9})/);
    if (plainNumber) budget = parseInt(plainNumber[1], 10);
  }

  if (budget && !isNaN(budget)) {
    result.budget = budget;
  }

  // --- màu sắc ---
  const colors: string[] = [];
  if (text.includes('đen')) colors.push('đen');
  if (text.includes('trắng')) colors.push('trắng');
  if (text.includes('xanh')) colors.push('xanh');
  if (text.includes('hồng')) colors.push('hồng');
  if (text.includes('be')) colors.push('be');
  if (colors.length) result.colors = colors;

    // --- loại đồ: áo / quần / jean / kaki / sơ mi / kính / mũ ---
    const itemTypes: string[] = [];

    if (text.includes('áo thun') || text.includes('áo phông') || text.includes('tshirt')) {
      itemTypes.push('ao');
    } else if (text.includes('áo')) {
      itemTypes.push('ao');
    }

    if (text.includes('quần jean') || text.includes('jean') || text.includes('denim')) {
      itemTypes.push('jean');
    }
    if (text.includes('quần kaki') || text.includes('kaki')) {
      itemTypes.push('kaki');
    }
    if (text.includes('sơ mi') || text.includes('shirt')) {
      itemTypes.push('somi');
    }
    if (text.includes('quần')) {
      itemTypes.push('quan');
    }

    // 👇 MỚI: kính & mũ
    if (text.includes('kính') || text.includes('kinh')) {
      itemTypes.push('kinh');
    }
    if (text.includes('mũ') || text.includes('mu ') || text.includes('nón') || text.includes('non ')) {
      itemTypes.push('mu');
    }

    if (itemTypes.length) result.itemTypes = [...new Set(itemTypes)];


  return result;
}
