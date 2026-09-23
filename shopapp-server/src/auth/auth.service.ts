import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  async register(data: { email: string; password: string; name: string }) {
    const exists = await this.prisma.user.findUnique({ where: { email: data.email } });
    if (exists) {
      throw new ConflictException('Пользователь с таким email уже есть');
    }

    const passwordHash = await bcrypt.hash(data.password, 10);
    const user = await this.prisma.user.create({
      data: { ...data, password: passwordHash },
    });
    return this.makeToken(user);
  }

  async login(data: { email: string; password: string }) {
    const user = await this.prisma.user.findUnique({ where: { email: data.email } });
    if (!user) {
      throw new UnauthorizedException('Неверный email или пароль');
    }

    const ok = await bcrypt.compare(data.password, user.password);
    if (!ok) {
      throw new UnauthorizedException('Неверный email или пароль');
    }

    return this.makeToken(user);
  }

  /// Ровно та форма, которую ждёт LoginResponse из главы 26.
  private makeToken(user: { id: number; name: string; email: string }) {
    return {
      token: this.jwt.sign({ sub: user.id, email: user.email }),
      userId: user.id,
      name: user.name,
      email: user.email,
    };
  }
}
