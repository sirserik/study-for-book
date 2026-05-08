# study-for-book

Учебный iOS-проект к книге **«ShopApp с нуля»** (beginner-уровень).
Storyboard + UIKit + Swift 5 (поверх Xcode 16, цель — iOS 17+).

## Зачем этот репозиторий

Каждый коммит здесь — это **один маленький шаг урока** из книги. Если
ты застрял или хочешь сравнить, как должно выглядеть после очередной
главы, открой соответствующий коммит:

```bash
git log --oneline
git checkout <hash>      # посмотреть код после конкретного урока
git checkout main        # вернуться к актуальному
```

Сообщения коммитов помечены номером урока:

```
[Урок 15.1] Создаём кнопку программно
[Урок 15.2] Подключаем кнопку к коду через @IBAction
```

## Как запустить

1. Открой `study-for-book.xcodeproj` в Xcode 16+.
2. Выбери симулятор iPhone 15 / iPhone 16 (iOS 17 или 18).
3. Нажми **Run** (`⌘R`).

## Структура

```
study-for-book/
├── study-for-book/
│   ├── AppDelegate.swift       # точка входа приложения
│   ├── SceneDelegate.swift     # сцена приложения (iOS 13+)
│   ├── ViewController.swift    # первый экран
│   ├── Base.lproj/
│   │   ├── Main.storyboard         # визуальный редактор экранов
│   │   └── LaunchScreen.storyboard # сплеш-скрин
│   ├── Assets.xcassets/        # цвета, иконка
│   └── Info.plist              # метаданные приложения
└── study-for-book.xcodeproj/   # сам Xcode-проект
```

## Связь с книгой

Книга — `sirserik/alma-shop-ios-book-prod`, ветка `shopapp-beginner`.
Полный текст всех 35 глав в формате Markdown + PDF.
