import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module.js';
import { AuthModule } from './auth/auth.module.js';
import { ProductsModule } from './products/products.module.js';
import { UsersModule } from './users/users.module.js';
import { OrdersModule } from './orders/orders.module.js';

@Module({
  imports: [PrismaModule, AuthModule, ProductsModule, UsersModule, OrdersModule],
})
export class AppModule {}
