// src/modules/products/product.service.ts
import { Prisma, Product } from '../../generated/prisma/client';
import { getPrisma } from '../../common/prisma';
import {
  PaginatedProductsResult,
  SearchProductsDto,
} from './product.dto';

const prisma = getPrisma();

export class ProductService {
  async searchProducts(
    params: SearchProductsDto,
  ): Promise<PaginatedProductsResult<Product>> {
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

    // Search theo name / description (KHÔNG dùng mode cho version Prisma cũ)
    if (q) {
      AND.push({
        OR: [
          { name: { contains: q } },
          { description: { contains: q } },
        ],
      });
    }

    // Filter theo khoảng giá
    if (minPrice !== undefined || maxPrice !== undefined) {
      const priceFilter: Prisma.FloatFilter = {};

      if (minPrice !== undefined) priceFilter.gte = minPrice;
      if (maxPrice !== undefined) priceFilter.lte = maxPrice;

      AND.push({ price: priceFilter });
    }

    // Filter theo categoryId
    if (categoryId !== undefined) {
      AND.push({ categoryId });
    }

    // Hoặc filter theo tên category (liên kết sang bảng categories)
    if (categoryName) {
      AND.push({
        category: {
          name: {
            contains: categoryName,
          },
        },
      });
    }

    // Filter theo gender
    if (gender) {
      AND.push({ gender });
    }

    if (AND.length > 0) {
      where.AND = AND;
    }

    // Sort
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
        // nếu trong Prisma field là createdAt (map từ created_at)
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
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }
}

export const productService = new ProductService();
