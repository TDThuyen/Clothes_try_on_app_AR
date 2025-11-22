// filepath: d:\TADUYTHUYEN\Clothes_try_on_app_AR\app_be\scripts\seed-from-storage.ts

import { PrismaClient } from '@prisma/client';
import { bucket } from '../src/common/firebase';

const prisma = new PrismaClient();

// Map thư mục Firebase -> loại sản phẩm + category name trong DB
const FOLDER_CONFIG: Record<
  string,
  {
    categoryName: 'Quần' | 'Áo' | 'Kính' | 'Mũ';
    productTypeVi: 'quần' | 'áo' | 'kính' | 'mũ';
    genderVi: 'nam' | 'nữ';
  }
> = {
  men_glasses: { categoryName: 'Kính', productTypeVi: 'kính', genderVi: 'nam' },
  women_glasses: { categoryName: 'Kính', productTypeVi: 'kính', genderVi: 'nữ' },
  men_shirt: { categoryName: 'Áo', productTypeVi: 'áo', genderVi: 'nam' },
  women_shirt: { categoryName: 'Áo', productTypeVi: 'áo', genderVi: 'nữ' },
  men_trousers: { categoryName: 'Quần', productTypeVi: 'quần', genderVi: 'nam' },
  women_trousers: { categoryName: 'Quần', productTypeVi: 'quần', genderVi: 'nữ' },
  men_hat: { categoryName: 'Mũ', productTypeVi: 'mũ', genderVi: 'nam' },
  women_hat: { categoryName: 'Mũ', productTypeVi: 'mũ', genderVi: 'nữ' },
};

// Helper: mô tả dài, giàu ngữ cảnh cho RAG
function buildRichDescription(args: {
  productName: string;
  productTypeVi: 'quần' | 'áo' | 'kính' | 'mũ';
  genderVi: 'nam' | 'nữ';
  price: number;
}) {
  const { productName, productTypeVi, genderVi, price } = args;

  let priceSegment = '';
  if (price < 200_000) {
    priceSegment =
      'Mức giá rẻ, phù hợp học sinh – sinh viên cần outfit gọn gàng mà vẫn tiết kiệm.';
  } else if (price < 400_000) {
    priceSegment =
      'Mức giá tầm trung, phù hợp sinh viên và người mới đi làm muốn đầu tư outfit dùng lâu dài.';
  } else {
    priceSegment =
      'Mức giá nhỉnh hơn một chút, phù hợp khi muốn đầu tư một món đồ chất lượng, dùng lâu dài và dễ phối nhiều outfit khác nhau.';
  }

  const genderText =
    genderVi === 'nam'
      ? 'phù hợp cho nam, đặc biệt là học sinh – sinh viên nam.'
      : 'phù hợp cho nữ, đặc biệt là học sinh – sinh viên nữ.';

  let usage = '';
  let style = '';
  let coord = '';

  switch (productTypeVi) {
    case 'áo':
      style = 'Phong cách: casual, basic, dễ phối, có thể lên nhẹ street tuỳ cách phối.';
      usage =
        'Dịp sử dụng: đi học, đi chơi, đi cafe, sinh hoạt hàng ngày, có thể dùng cho thuyết trình không quá trang trọng.';
      coord = `Gợi ý phối đồ:
- Đi học: phối với quần jean hoặc quần vải tối màu, mang sneaker trắng hoặc đen.
- Đi chơi: có thể phối với quần ống suông, quần short hoặc layer thêm áo khoác mỏng để trông năng động hơn.`;
      break;
    case 'quần':
      style = 'Phong cách: casual, gọn gàng, dễ phối với nhiều kiểu áo.';
      usage =
        'Dịp sử dụng: đi học, đi làm môi trường thoải mái, đi chơi, hẹn cafe.';
      coord = `Gợi ý phối đồ:
- Đi học: phối với áo thun basic hoặc áo sơ mi đơn giản, mang sneaker.
- Đi chơi: phối với áo oversize hoặc hoodie để tạo cảm giác trẻ trung, thoải mái.`;
      break;
    case 'kính':
      style = 'Phong cách: street, casual, có thể tạo điểm nhấn cho khuôn mặt.';
      usage =
        'Dịp sử dụng: đi học buổi trưa nắng, đi chơi, đi du lịch, đi biển hoặc chụp hình sống ảo.';
      coord = `Gợi ý phối đồ:
- Phối với áo thun, quần jean và sneaker cho look năng động.
- Phối với áo sơ mi trắng, quần tối màu nếu muốn nhìn trưởng thành, chững chạc hơn.`;
      break;
    case 'mũ':
      style = 'Phong cách: street, sporty, dễ dùng hàng ngày.';
      usage =
        'Dịp sử dụng: đi học, đi chơi, đi dạo, chạy bộ, tập thể thao hoặc che nắng nhẹ khi ra đường.';
      coord = `Gợi ý phối đồ:
- Phối với áo thun oversize và quần jean/short cho phong cách đường phố.
- Phối với hoodie hoặc áo khoác thể thao cho những ngày trời mát.`;
      break;
  }

  return `
Sản phẩm: ${productName}
Loại: ${productTypeVi} thời trang, ${genderText}

${style}
${usage}

${priceSegment}

${coord}

Lưu ý: có thể kết hợp linh hoạt với các item khác trong tủ đồ để tạo nhiều outfit khác nhau tùy hoàn cảnh (đi học, đi chơi, đi làm thêm,...).
  `.trim();
}

async function main() {
  console.log('🚀 Starting to seed database from Firebase Storage for RAG...');

  // Lấy categories hiện có (Quần, Áo, Kính, Mũ)
  const categories = await prisma.category.findMany();
  if (!categories.length) {
    console.warn(
      '⚠️  Không tìm thấy category nào trong database. Hãy seed 4 category (Quần, Áo, Kính, Mũ) trước.'
    );
  }

  const getCategoryIdByName = (name: string): number | null => {
    const cat = categories.find((c) => c.name === name);
    return cat ? cat.id : null;
  };

  // 1. Xóa tất cả sản phẩm cũ để đồng bộ lại từ đầu
  await prisma.product.deleteMany({});
  console.log('🗑️  Cleared existing products from the database.');

  // 2. Lấy tất cả các file trong thư mục 'products'
  const [files] = await bucket.getFiles({ prefix: 'products/' });
  console.log(`☁️  Found ${files.length} files in Firebase Storage.`);

  for (const file of files) {
    // Bỏ qua các thư mục hoặc file không phải ảnh
    if (file.name.endsWith('/') || !file.name.match(/\.(png|jpg|jpeg|webp)$/i)) {
      continue;
    }

    // 3. Phân tích đường dẫn để lấy thông tin
    // Ví dụ: products/men_glasses/brand/1.png
    const pathParts = file.name.split('/');
    if (pathParts.length < 2) continue;

    const categoryFolder = pathParts[1]; // 'men_glasses', 'women_shirt', ...

    const config = FOLDER_CONFIG[categoryFolder];
    if (!config) {
      console.warn(
        `⚠️  Unknown category folder: ${categoryFolder}. Skipping file: ${file.name}`
      );
      continue;
    }

    const categoryId = getCategoryIdByName(config.categoryName);
    if (!categoryId) {
      console.warn(
        `⚠️  Category "${config.categoryName}" không tồn tại trong DB. Bỏ qua file: ${file.name}`
      );
      continue;
    }

    const fileName = pathParts[pathParts.length - 1]; // lấy tên file cuối cùng
    const baseName = fileName.split('.')[0];

    // 4. Lấy URL công khai (Download URL)
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: '03-09-2491', // Ngày hết hạn rất xa trong tương lai
    });

    // 5. Random giá và xây mô tả RAG-friendly
    const price = Math.floor(Math.random() * (5000000 - 500000) + 500000); // 500k - 5M

    // Đặt name cho dễ đọc hơn 1 chút (nếu file toàn số thì vẫn ok)
    const productName = baseName.replace(/[-_]/g, ' ').trim() || 'Sản phẩm thời trang';

    const description = buildRichDescription({
      productName,
      productTypeVi: config.productTypeVi,
      genderVi: config.genderVi,
      price,
    });

    // Gán gender theo kiểu string đơn giản, chatbot sẽ đọc mô tả là chính
    const genderDb =
      config.genderVi === 'nam' ? 'male' : 'female';

    // Size & color đơn giản tuỳ loại đồ
    let availableSizes: string | null = null;
    let color: string | null = null;

    if (config.productTypeVi === 'áo' || config.productTypeVi === 'quần') {
      availableSizes = 'S,M,L,XL';
      color = 'không rõ';
    } else if (config.productTypeVi === 'kính' || config.productTypeVi === 'mũ') {
      availableSizes = 'freesize';
      color = 'không rõ';
    }

    const ratingAvg =
      Math.round((Math.random() * (5 - 3.5) + 3.5) * 10) / 10;

    const productData = {
      name: productName,
      description,
      price,
      categoryId,
      gender: genderDb,
      availableSizes,
      color,
      imageUrl: url,
      arModelUrl: null,
      ratingAvg,
    };

    // 6. Tạo sản phẩm trong database
    try {
      const createdProduct = await prisma.product.create({
        data: productData,
      });
      console.log(`✅ Created product: ${createdProduct.name} (ID: ${createdProduct.id})`);
    } catch (error) {
      console.error(`❌ Failed to create product for file ${fileName}:`, error);
    }
  }

  console.log('\n🎉 Seeding process finished successfully (RAG-ready descriptions)!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('\n❌ An error occurred during the seeding process:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
