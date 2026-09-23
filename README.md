# study-for-book

Учебный проект к книге **«ShopApp с нуля»** (beginner-уровень).
UIKit кодом, без Storyboard. **Swift 6, iOS 17+, Xcode 26.**

## Что здесь лежит

Две части.

**Плейграунды** — к теоретическим главам (1–16A). Открываешь
`Playgrounds/ChapterNN-*.playground`, жмёшь Run и смотришь, как
работают примеры из главы: переменные, опционалы, замыкания, ARC,
concurrency, Codable, иерархия UIKit, Logger.

**Приложение** — собирается по главам, начиная с 15-й. Каталог
товаров с сервера, картинки с кэшем, детальный экран, корзина с
сохранением между запусками и таб-бар с бейджем.

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
```

Каждый коммит проверен сборкой: на любом из них проект открывается и
запускается.

## Как запустить

1. Открой `study-for-book.xcodeproj` в Xcode 26.
2. Выбери симулятор iPhone 16 (iOS 18) или новее.
3. Нажми **Run** (`⌘R`).

Интернет нужен: список товаров приходит с `https://dummyjson.com`.

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
├── Money.swift                    # одно место, где форматируется цена
├── UIButton+Style.swift           # фабрика главной кнопки экрана
└── Assets.xcassets, Info.plist
```

`Main.storyboard` нет намеренно — интерфейс собирается кодом, это
разобрано в главе 15.2.

## Связь с книгой

Книга — `sirserik/alma-shop-ios-book-prod`, ветка `shopapp-beginner`:
полный текст глав в Markdown + собранный PDF.
