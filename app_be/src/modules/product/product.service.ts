import type { Prisma } from '../../generated/prisma/client';
import { getPrisma } from '../../common/prisma';
import type { PaginatedProductsResult, Product, SearchProductsQueryDto } from './product.dto';

const prisma = getPrisma();

export class ProductService {
  async searchProducts(params: SearchProductsQueryDto): Promise<PaginatedProductsResult> {
    const {
      q,
      minPrice,
      maxPrice,
      categoryId,
      categoryName,
      gender,
      page = 1,
      limit = 20,
      sortBy = 'newest',
    } = params;

    const where: Prisma.ProductWhereInput = {};
    const AND: Prisma.ProductWhereInput[] = [];

    if (q) {
      AND.push({
        OR: [{ name: { contains: q } }, { description: { contains: q } }],
      });
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      const priceFilter: Prisma.FloatFilter = {};

      if (minPrice !== undefined) priceFilter.gte = minPrice;
      if (maxPrice !== undefined) priceFilter.lte = maxPrice;

      AND.push({ price: priceFilter });
    }

    if (categoryId !== undefined) {
      AND.push({ categoryId });
    }

    if (categoryName) {
      AND.push({
        category: {
          name: {
            contains: categoryName,
          },
        },
      });
    }

    if (gender) {
      AND.push({ gender });
    }

    if (AND.length > 0) {
      where.AND = AND;
    }

    let orderBy: Prisma.ProductOrderByWithRelationInput;
    switch (sortBy) {
      case 'price_asc':
        orderBy = { price: 'asc' };
        break;
      case 'price_desc':
        orderBy = { price: 'desc' };
        break;
      case 'newest':
      default:
        orderBy = { createdAt: 'desc' as Prisma.SortOrder };
        break;
    }

    const skip = (page - 1) * limit;
    const take = limit;

    const [items, total] = await prisma.$transaction([
      prisma.product.findMany({
        where,
        orderBy,
        skip,
        take,
      }),
      prisma.product.count({ where }),
    ]);

    return {
      items: items as unknown as Product[],
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Lấy tất cả sản phẩm từ database.
   */
  async getAllProducts() {
    const products = await prisma.product.findMany({
      orderBy: {
        createdAt: 'desc', // Sắp xếp sản phẩm mới nhất lên đầu
      },
    });
    return products;
  }
}

export const productService = new ProductService();
