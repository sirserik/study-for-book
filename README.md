# study-for-book

Учебный проект к книге **«ShopApp с нуля»** (beginner-уровень).
UIKit кодом, без Storyboard. **Swift 6, iOS 17+, Xcode 26.**

## Что здесь лежит

Три части.

**Плейграунды** — к теоретическим главам (1–16A). Открываешь
`Playgrounds/ChapterNN-*.playground`, жмёшь Run и смотришь, как
работают примеры из главы: переменные, опционалы, замыкания, ARC,
concurrency, Codable, иерархия UIKit, Logger.

**Приложение** — собирается по главам, начиная с 15-й. Каталог
товаров с сервера, картинки с кэшем, детальный экран, корзина с
сохранением между запусками, регистрация и вход с токеном в Keychain,
профиль, оформление заказа в три шага и юнит-тесты.

**Сервер** — папка `shopapp-server/` (главы 30–31): NestJS + Prisma +
PostgreSQL. До главы 27 приложение берёт товары с публичного
`dummyjson.com`, дальше переключается на свой сервер.

## Каждый коммит — один шаг урока

```bash
git log --oneline
git checkout <hash>      # посмотреть код после конкретного урока
git checkout main        # вернуться к актуальному
```

Сообщения помечены номером главы:

```
[Урок 15.3] SceneDelegate без Main.storyboard
[Урок 15.4] Кнопка по центру
...
[Урок 21] UITableView со списком товаров из dummyjson
[Урок 24] Корзина — UserDefaults + Codable + TabBar
[Урок 27] APIClient — единый шлюз сети
[Урок 32] Юнит-тесты — Cart, валидация формы, разбор JSON
```

Каждый коммит проверен сборкой: на любом из них проект открывается и
запускается.

## Как запустить

1. Открой `study-for-book.xcodeproj` в Xcode 26.
2. Выбери симулятор iPhone 16 (iOS 18) или новее.
3. Нажми **Run** (`⌘R`).

С главы 27 приложение ходит в свой сервер на `http://localhost:3000` —
подними его из `shopapp-server/` (инструкция там же в README). На
коммитах до 27-го интернет нужен для `https://dummyjson.com`.

Тесты — `⌘U` в Xcode или:

```bash
xcodebuild test -project study-for-book.xcodeproj -scheme study-for-book \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Структура приложения (на текущий момент)

```
study-for-book/
├── AppDelegate.swift              # точка входа процесса
├── SceneDelegate.swift            # окно и корневой контроллер — кодом
├── MainTabBarController.swift     # две вкладки: Товары и Корзина
├── Product.swift                  # модель товара
├── ProductsViewModel.swift        # состояние экрана + загрузка
├── ProductsViewController.swift   # список товаров
├── ProductCell.swift              # ячейка списка
├── ProductDetailViewController.swift  # детальный экран (UIScrollView)
├── CartStorage.swift              # корзина поверх UserDefaults
├── CartViewController.swift       # экран корзины
├── CartItemCell.swift             # ячейка корзины с +/-
├── ImageLoader.swift              # кэш картинок + UIImageView.setImage
├── APIClient.swift                # единственный шлюз сети (глава 27)
├── AuthService.swift              # токен, сессия, вход/регистрация
├── KeychainStorage.swift          # обёртка над Security framework
├── User.swift, Order.swift        # модели сервера
├── RegistrationViewController.swift, LoginViewController.swift
├── ProfileViewController.swift    # профиль + смена имени
├── Checkout.swift                 # координатор и три шага оформления
├── Money.swift                    # одно место, где форматируется цена
├── UIButton+Style.swift           # фабрика главной кнопки экрана
├── UITextField+Style.swift        # фабрика поля формы
└── Assets.xcassets, Info.plist, PrivacyInfo.xcprivacy
```

Рядом: `study-for-bookTests/` — 14 тестов, `shopapp-server/` — backend,
`.github/workflows/ios.yml` — сборка и тесты на каждый push.

`Main.storyboard` нет намеренно — интерфейс собирается кодом, это
разобрано в главе 15.2.

## Связь с книгой

Книга — `sirserik/alma-shop-ios-book-prod`, ветка `shopapp-beginner`:
полный текст глав в Markdown + собранный PDF.
