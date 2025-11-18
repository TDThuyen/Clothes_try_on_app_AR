// filepath: d:\TADUYTHUYEN\Clothes_try_on_app_AR\app_be\scripts\seed-from-storage.ts
import { PrismaClient } from '@prisma/client';
import { bucket } from '../src/common/firebase';

const prisma = new PrismaClient();

// Ánh xạ tên thư mục trong Firebase với category_id trong database
const categoryMap: { [key: string]: number } = {
  men_glasses: 1,
  women_glasses: 2,
  men_shirt: 3,
  women_shirt: 4,
  men_trousers: 5,
  women_trousers: 6,
  men_hat: 7,
  women_hat: 8,
};

async function main() {
  console.log('🚀 Starting to seed database from Firebase Storage...');

  // 1. Xóa tất cả sản phẩm cũ để đồng bộ lại từ đầu
  await prisma.product.deleteMany({});
  console.log('🗑️  Cleared existing products from the database.');

  // 2. Lấy tất cả các file trong thư mục 'products'
  const [files] = await bucket.getFiles({ prefix: 'products/' });
  console.log(`☁️  Found ${files.length} files in Firebase Storage.`);

  // *** BẮT ĐẦU THAY ĐỔI TỪ ĐÂY ***

  for (const file of files) {
    // Bỏ qua các thư mục hoặc file không phải ảnh
    if (file.name.endsWith('/') || !file.name.match(/\.(png|jpg|jpeg|webp)$/i)) {
      continue;
    }

    // 3. Phân tích đường dẫn để lấy thông tin
    const pathParts = file.name.split('/');
    if (pathParts.length < 4) continue;

    const categoryFolder = pathParts[1]; // 'men_glasses'
    const fileName = pathParts[3]; // '1'

    const categoryId = categoryMap[categoryFolder];
    if (!categoryId) {
      console.warn(`⚠️  Unknown category folder: ${categoryFolder}. Skipping file: ${file.name}`);
      continue;
    }

    // 4. Lấy URL công khai (Download URL)
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: '03-09-2491', // Ngày hết hạn rất xa trong tương lai
    });

    // 5. Tạo dữ liệu ảo cho sản phẩm
    const productName = fileName.split('.')[0].replace(/-/g, ' '); // 'Michael Kors NAO MK 3018 Front'
    const productData = {
      name: productName,
      description: `A stylish ${productName} from the ${categoryFolder.replace('_', ' ')} collection.`,
      price: Math.floor(Math.random() * (5000000 - 500000) + 500000), // Giá ngẫu nhiên từ 500k - 5M
      categoryId: categoryId, // Sửa từ category_id
      gender: categoryFolder.startsWith('men') ? 'MALE' : 'FEMALE',
      imageUrl: url, // Sửa từ image_url
      ratingAvg: Math.round((Math.random() * (5 - 3.5) + 3.5) * 10) / 10, // Sửa từ rating_avg
    };

    // 6. Tạo sản phẩm trong database NGAY LẬP TỨC
    try {
      const createdProduct = await prisma.product.create({
        data: productData,
      });
      console.log(`✅ Created product: ${createdProduct.name} (ID: ${createdProduct.id})`);
    } catch (error) {
      console.error(`❌ Failed to create product for file ${fileName}:`, error);
    }
  }
  // *** KẾT THÚC THAY ĐỔI ***
}

main()
  .then(async () => {
    await prisma.$disconnect();
    console.log('\n🎉 Seeding process finished successfully!');
  })
  .catch(async (e) => {
    console.error('\n❌ An error occurred during the seeding process:', e);
    await prisma.$disconnect();
    process.exit(1);
  });
