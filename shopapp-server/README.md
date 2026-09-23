# shopapp-server

Учебный backend к книге «ShopApp с нуля» — главы 30 и 31.
NestJS 12 + Prisma 7 + PostgreSQL.

## Запуск

```bash
cp .env.example .env
docker compose up -d          # поднимет PostgreSQL на порту 5433
npm install --legacy-peer-deps
npx prisma migrate dev --name init
npm run start:dev             # http://localhost:3000
```

`--legacy-peer-deps` нужен из-за бага npm 10.9 на графе зависимостей
vitest; с npm 11+ обходится без него.

Порт базы — **5433**, а не 5432: на маке часто уже крутится свой
PostgreSQL, и Prisma уходила бы не в тот сервер (см. главу 31.3).

## Эндпойнты

| Метод | Путь | Токен | Что делает |
|---|---|---|---|
| GET | `/products` | — | список товаров (массив) |
| GET | `/products/:id` | — | один товар |
| POST | `/products` | — | создать товар |
| POST | `/auth/register` | — | регистрация → `{token, userId, name, email}` |
| POST | `/auth/login` | — | вход → то же самое |
| GET | `/users/me` | нужен | профиль |
| PATCH | `/users/me` | нужен | сменить имя/email |
| GET | `/orders` | нужен | заказы пользователя |
| POST | `/orders` | нужен | оформить заказ |

Форма ответов подогнана под модели iOS-приложения из глав 26–29:
`LoginResponse`, `User`, `Order`.

## Проверка одной командой

```bash
curl -s -X POST localhost:3000/products -H "Content-Type: application/json" \
  -d '{"title":"iPhone 15","price":999.99,"description":"Самый новый"}'
curl -s localhost:3000/products
```
