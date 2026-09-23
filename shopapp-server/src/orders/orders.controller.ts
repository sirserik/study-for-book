import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';
import { OrdersService } from './orders.service.js';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Get()
  async getAll(@Req() req: any) {
    return this.ordersService.findAllFor(req.user.sub);
  }

  @Post()
  async create(@Req() req: any, @Body() dto: { items: { productId: number; quantity: number }[] }) {
    return this.ordersService.create(req.user.sub, dto.items);
  }
}
