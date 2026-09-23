import { Body, Controller, Get, Patch, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private prisma: PrismaService) {}

  @Get('me')
  async me(@Req() req: any) {
    const user = await this.prisma.user.findUnique({ where: { id: req.user.sub } });
    return { id: user!.id, name: user!.name, email: user!.email };
  }

  @Patch('me')
  async update(@Req() req: any, @Body() dto: { name?: string; email?: string }) {
    const user = await this.prisma.user.update({
      where: { id: req.user.sub },
      data: { ...(dto.name ? { name: dto.name } : {}), ...(dto.email ? { email: dto.email } : {}) },
    });
    return { id: user.id, name: user.name, email: user.email };
  }
}
