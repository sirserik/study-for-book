import Foundation

// MARK: - 7.1 / 7.3 — struct Book

struct Book {
    let title: String
    let author: String
    let year: Int
    let available: Bool
}

let book = Book(
    title: "Абай жолы",
    author: "Мухтар Әуезов",
    year: 1942,
    available: true
)

print("--- 7.1 Book ---")
print(book.title)
print(book.author)
print(book.year)

// MARK: - 7.4 Свой init с логикой

struct PhoneNumber {
    let raw: String
    let normalized: String

    init(_ rawNumber: String) {
        self.raw = rawNumber
        self.normalized = rawNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}

let p = PhoneNumber("+7 (701) 123-45-67")
print("--- 7.4 Свой init ---")
print("raw:", p.raw)
print("normalized:", p.normalized)

// MARK: - 7.5 Доступ + текущий год

let currentYear = Calendar.current.component(.year, from: .now)
let bookAge = currentYear - book.year
print("--- 7.5 Доступ ---")
print("Книге \(bookAge) лет")

// MARK: - 7.6 Состояние и поведение

struct Light {
    var isOn: Bool

    func describe() -> String {
        return self.isOn ? "Свет горит" : "Свет потушен"
    }
}

let lamp = Light(isOn: true)
let dark = Light(isOn: false)
print("--- 7.6 Метод describe ---")
print(lamp.describe())
print(dark.describe())

// MARK: - 7.7 Value semantics

struct Counter {
    var count: Int
}

var a = Counter(count: 0)
var b = a       // копия
b.count = 99
print("--- 7.7 Value semantics ---")
print("a.count =", a.count)        // 0
print("b.count =", b.count)        // 99

// MARK: - 7.8 Объект как обычное значение

let library = [
    Book(title: "Абай жолы", author: "Мухтар Әуезов", year: 1942, available: true),
    Book(title: "Война и мир", author: "Лев Толстой", year: 1869, available: false),
    Book(title: "Анна Каренина", author: "Лев Толстой", year: 1877, available: true)
]

print("--- 7.8 Массив ---")
for b in library {
    print(b.title)
}

let availableBooks = library.filter { $0.available }
print("Доступно:", availableBooks.count)

let titles = library.map { $0.title }
print("Все:", titles)

// MARK: - 7.9 Вложенные struct

struct Address {
    let street: String
    let city: String
    let zipCode: String
}

struct User {
    let id: Int
    let name: String
    let address: Address?
}

let userWithAddr = User(
    id: 1,
    name: "Айдос",
    address: Address(street: "Толе би 15", city: "Алматы", zipCode: "050000")
)

let userNoAddr = User(id: 2, name: "Айгерим", address: nil)

print("--- 7.9 Вложенные ---")
print(userWithAddr.address?.city ?? "—")
print(userNoAddr.address?.city ?? "—")

// MARK: - 7.10 Equatable

struct BookEq: Equatable {
    let title: String
    let author: String
    let year: Int
    let available: Bool
}

let a1 = BookEq(title: "X", author: "Y", year: 2020, available: true)
let a2 = BookEq(title: "X", author: "Y", year: 2020, available: true)
let a3 = BookEq(title: "X", author: "Y", year: 2021, available: true)

print("--- 7.10 Equatable ---")
print("a1 == a2:", a1 == a2)
print("a1 == a3:", a1 == a3)

// MARK: - 7.11 Hashable

struct Product: Hashable {
    let id: Int
    let name: String
}

var stock: Set<Product> = []
stock.insert(Product(id: 1, name: "Латте"))
stock.insert(Product(id: 1, name: "Латте"))    // дубль не добавится
stock.insert(Product(id: 2, name: "Раф"))

print("--- 7.11 Hashable ---")
print("stock count:", stock.count)              // 2

struct UserKey: Hashable {
    let id: Int
    let region: String
}

var cache: [UserKey: User] = [:]
cache[UserKey(id: 1, region: "kz")] = userWithAddr
print("cache count:", cache.count)

// MARK: - 7.13 Reference vs value (preview)

struct PointStruct {
    var x: Int
    var y: Int
}

class PointClass {
    var x: Int
    var y: Int
    init(x: Int, y: Int) { self.x = x; self.y = y }
}

print("--- 7.13 struct vs class ---")
var s1 = PointStruct(x: 0, y: 0)
var s2 = s1
s2.x = 99
print("s1.x =", s1.x, "s2.x =", s2.x)        // 0, 99

let c1 = PointClass(x: 0, y: 0)
let c2 = c1
c2.x = 99
print("c1.x =", c1.x, "c2.x =", c2.x)        // 99, 99

// MARK: - Большое упражнение 7.6 — Каталог фильмов

print("--- 7.6 Каталог фильмов ---")

struct Genre: Hashable {
    let name: String
}

struct Movie: Hashable {
    let title: String
    let year: Int
    let rating: Double
    let genre: Genre
    let posterURL: URL?
}

let movies = [
    Movie(title: "Қыз Жiбек", year: 1970, rating: 8.5,
          genre: Genre(name: "drama"),
          posterURL: URL(string: "https://example.kz/qiz-zhibek.jpg")),
    Movie(title: "Брат", year: 1997, rating: 8.4,
          genre: Genre(name: "drama"),
          posterURL: URL(string: "https://example.kz/brat.jpg")),
    Movie(title: "Тёмный рыцарь", year: 2008, rating: 9.0,
          genre: Genre(name: "action"),
          posterURL: nil),
    Movie(title: "Интерстеллар", year: 2014, rating: 8.6,
          genre: Genre(name: "sci-fi"),
          posterURL: nil),
    Movie(title: "Матрица", year: 1999, rating: 8.7,
          genre: Genre(name: "sci-fi"),
          posterURL: nil)
]

func printMovie(_ movie: Movie) {
    let rating = movie.rating.formatted(.number.precision(.fractionLength(1)))
    print("\(movie.title) (\(movie.year)) — \(rating)/10, \(movie.genre.name)")
}

func topRated(_ movies: [Movie]) -> Movie? {
    return movies.max(by: { $0.rating < $1.rating })
}

func moviesOfGenre(_ movies: [Movie], genre: Genre) -> [Movie] {
    return movies.filter { $0.genre == genre }
}

func uniqueGenres(_ movies: [Movie]) -> Set<Genre> {
    return Set(movies.map { $0.genre })
}

print("--- Все фильмы ---")
for m in movies { printMovie(m) }

print("\n--- Лучший ---")
if let top = topRated(movies) { printMovie(top) }

print("\n--- Sci-Fi ---")
for m in moviesOfGenre(movies, genre: Genre(name: "sci-fi")) {
    printMovie(m)
}

print("\n--- Все жанры ---")
let genres = uniqueGenres(movies).map { $0.name }.sorted()
print(genres)
