import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ProductsService } from './products.service.js';

@Controller('products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  async getAll() {
    return this.productsService.findAll();
  }

  @Get(':id')
  async getOne(@Param('id') id: string) {
    return this.productsService.findOne(+id);
  }

  @Post()
  async create(@Body() dto: { title: string; price: number; description?: string; thumbnail?: string }) {
    return this.productsService.create(dto);
  }
}
