import { IsEmail, IsString, MinLength } from 'class-validator';

export class RegisterDto {
  @IsString()
  @MinLength(2, { message: 'Имя должно быть минимум 2 символа' })
  name: string;

  @IsEmail({}, { message: 'Неверный email' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'Пароль минимум 8 символов' })
  password: string;
}

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  password: string;
}
