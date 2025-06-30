import express from 'express';
import { z } from 'zod';
import { prisma } from '../index';
import logger from '../config/logger';

const router = express.Router();

// Validation schemas
const ProductImportSchema = z.object({
  sourceProductId: z.string(),
  sourceSite: z.string(),
  title: z.string(),
  description: z.string().optional(),
  sourcePrice: z.number(),
  currency: z.string().default('CAD'),
  images: z.array(z.string()).default([]),
  category: z.string(),
  availability: z.boolean().default(true),
  supplierInfo: z.record(z.any()).default({}),
  specifications: z.record(z.any()).default({}),
  shippingInfo: z.record(z.any()).default({}),
  reviewsCount: z.number().default(0),
  rating: z.number().default(0),
  inventoryLevel: z.string().default('In Stock'),
});

// GET /api/products - Get all active products
router.get('/', async (req, res) => {
  try {
    const products = await prisma.product.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });

    res.json(products);
  } catch (error) {
    logger.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// GET /api/products/:id - Get single product
router.get('/:id', async (req, res) => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
    });

    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json(product);
  } catch (error) {
    logger.error('Error fetching product:', error);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// POST /api/products/bulk-import - Bulk import products
router.post('/bulk-import', async (req, res) => {
  try {
    const productDtos = z.array(ProductImportSchema).parse(req.body);
    
    logger.info(`Bulk importing ${productDtos.length} products`);
    
    const results = {
      newProducts: 0,
      updatedProducts: 0,
      errors: 0,
    };

    for (const dto of productDtos) {
      try {
        const existingProduct = await prisma.product.findUnique({
          where: {
            sourceProductId_sourceSite: {
              sourceProductId: dto.sourceProductId,
              sourceSite: dto.sourceSite,
            },
          },
        });

        if (existingProduct) {
          await prisma.product.update({
            where: { id: existingProduct.id },
            data: {
              title: dto.title,
              description: dto.description,
              sourcePrice: dto.sourcePrice,
              marketPrice: dto.sourcePrice * 1.2, // 20% markup
              images: dto.images,
              category: dto.category,
              availability: dto.availability,
              supplierInfo: dto.supplierInfo,
              specifications: dto.specifications,
              shippingInfo: dto.shippingInfo,
              reviewsCount: dto.reviewsCount,
              rating: dto.rating,
              inventoryLevel: dto.inventoryLevel,
              updatedAt: new Date(),
            },
          });
          results.updatedProducts++;
        } else {
          await prisma.product.create({
            data: {
              sourceProductId: dto.sourceProductId,
              sourceSite: dto.sourceSite,
              title: dto.title,
              description: dto.description,
              sourcePrice: dto.sourcePrice,
              marketPrice: dto.sourcePrice * 1.2, // 20% markup
              currency: dto.currency,
              images: dto.images,
              category: dto.category,
              availability: dto.availability,
              supplierInfo: dto.supplierInfo,
              specifications: dto.specifications,
              shippingInfo: dto.shippingInfo,
              reviewsCount: dto.reviewsCount,
              rating: dto.rating,
              inventoryLevel: dto.inventoryLevel,
              isActive: true,
            },
          });
          results.newProducts++;
        }
      } catch (error) {
        logger.error(`Error processing product ${dto.sourceProductId}:`, error);
        results.errors++;
      }
    }

    logger.info(`Successfully imported ${results.newProducts} new products and updated ${results.updatedProducts} existing products`);

    res.json({
      message: 'Products imported successfully',
      results,
    });
  } catch (error) {
    logger.error('Error importing products:', error);
    res.status(500).json({ error: 'Error importing products' });
  }
});

export default router;
