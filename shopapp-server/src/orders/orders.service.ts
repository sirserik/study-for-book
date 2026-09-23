import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

type NewOrderItem = { productId: number; quantity: number };

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async create(userId: number, items: NewOrderItem[]) {
    if (!items?.length) {
      throw new BadRequestException('Корзина пуста');
    }

    const products = await this.prisma.product.findMany({
      where: { id: { in: items.map((i) => i.productId) } },
    });

    const total = items.reduce((sum, item) => {
      const product = products.find((p) => p.id === item.productId);
      if (!product) {
        throw new BadRequestException(`Товар ${item.productId} не найден`);
      }
      return sum + product.price * item.quantity;
    }, 0);

    const order = await this.prisma.order.create({
      data: {
        userId,
        total,
        items: {
          create: items.map((item) => ({
            productId: item.productId,
            quantity: item.quantity,
            price: products.find((p) => p.id === item.productId)!.price,
          })),
        },
      },
      include: { items: true },
    });

    return this.toResponse(order);
  }

  async findAllFor(userId: number) {
    const orders = await this.prisma.order.findMany({
      where: { userId },
      include: { items: true },
      orderBy: { createdAt: 'desc' },
    });
    return orders.map((o) => this.toResponse(o));
  }

  /// Форма ответа ровно такая, какую ждёт struct Order из главы 27.
  private toResponse(order: any) {
    return {
      id: order.id,
      items: order.items.map((i: any) => ({ productId: i.productId, quantity: i.quantity })),
      total: order.total,
      status: order.status,
      createdAt: order.createdAt,
    };
  }
}
