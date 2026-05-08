import Foundation

// MARK: - 10.1 Наследование

class Animal {
    let name: String
    init(name: String) { self.name = name }
    func sleep() { print("\(name) спит") }
    func describe() { print("Я \(name), животное") }
}

class Dog: Animal {
    func bark() { print("\(name) лает: Гав!") }
}

class Cat: Animal {
    func meow() { print("\(name) мяукает: Мяу!") }
}

let rex = Dog(name: "Рекс")
let kitty = Cat(name: "Мурка")
print("--- 10.1 Animal/Dog/Cat ---")
rex.sleep()
rex.bark()
kitty.sleep()
kitty.meow()

// MARK: - 10.2 super и override

class TalkingDog: Animal {
    override func describe() {
        super.describe()
        print("Гав!")
    }
}

class Robot: Animal {
    override func sleep() {
        // роботы не спят
    }
    override func describe() {
        super.describe()
        print("Я механический")
    }
}

print("--- 10.2 super/override ---")
let buddy = TalkingDog(name: "Бадди")
buddy.describe()

let r2d2 = Robot(name: "R2D2")
r2d2.sleep()         // ничего
r2d2.describe()

// MARK: - 10.3 Designated и convenience init

class Person {
    let nm: String
    let age: Int
    init(name: String, age: Int) {
        self.nm = name
        self.age = age
    }
    convenience init(name: String) {
        self.init(name: name, age: 0)
    }
}

print("--- 10.3 init ---")
let a1 = Person(name: "Айдос", age: 25)
let a2 = Person(name: "Бауыржан")
print(a1.nm, a1.age)
print(a2.nm, a2.age)

// Наследование с свойством
class DogBreed: Animal {
    let breed: String
    init(name: String, breed: String) {
        self.breed = breed
        super.init(name: name)
    }
}

let labrador = DogBreed(name: "Рекс", breed: "Лабрадор")
print(labrador.name, labrador.breed)

// MARK: - 10.4 final
final class FinalCounter {
    var n = 0
}
// class Sub: FinalCounter { } // ошибка

// MARK: - 10.6 Композиция вместо наследования

struct Discount {
    let percent: Int
}

struct ProductC {
    let title: String
    let price: Int
    let discount: Discount?
}

let regular = ProductC(title: "Латте", price: 1200, discount: nil)
let onSale = ProductC(title: "Раф", price: 1400, discount: Discount(percent: 20))

print("--- 10.6 Композиция ---")
print(regular.title, "—", regular.price, "₸, скидка:", regular.discount?.percent ?? 0)
print(onSale.title, "—", onSale.price, "₸, скидка:", onSale.discount?.percent ?? 0)

// MARK: - 10.7 Протокол

protocol Greetable {
    var name: String { get }
    func sayHello()
}

class PersonG: Greetable {
    let name: String
    init(name: String) { self.name = name }
    func sayHello() { print("Сәлем, я \(name)") }
}

struct RobotG: Greetable {
    let name: String
    func sayHello() { print("BEEP BOOP. I am \(name)") }
}

print("--- 10.7 Протокол ---")
let things: [any Greetable] = [
    PersonG(name: "Айгерим"),
    RobotG(name: "R2D2")
]
for thing in things {
    thing.sayHello()
}

// MARK: - 10.8 Свойства в протоколе get/set

protocol Identifiable {
    var id: String { get }
    var displayName: String { get set }
}

struct UserI: Identifiable {
    let id: String
    var displayName: String
}

print("--- 10.8 get/set ---")
var u = UserI(id: "u-1", displayName: "Айдос")
u.displayName = "Айдос С."
print(u.id, u.displayName)

// MARK: - 10.9 Default implementation

protocol Greeter2 {
    var nm: String { get }
    func sayHello()
}

extension Greeter2 {
    func sayHello() {
        print("Сәлем, я \(nm)")
    }
}

struct UserDef: Greeter2 {
    let nm: String
    // не пишем sayHello — берём из extension
}

struct CustomRobot: Greeter2 {
    let nm: String
    func sayHello() {
        print("BEEP. I am \(nm)")
    }
}

print("--- 10.9 default impl ---")
UserDef(nm: "Айгерим").sayHello()
CustomRobot(nm: "R2").sayHello()

// constrained extension
extension Sequence where Element: Numeric {
    var sum: Element { return reduce(0, +) }
}

print("[1,2,3].sum =", [1, 2, 3].sum)
print("[1.5, 2.5].sum =", [1.5, 2.5].sum)

// MARK: - 10.10 Builtin: Equatable, Comparable, Identifiable

struct Score: Comparable {
    let value: Int
    static func < (lhs: Score, rhs: Score) -> Bool {
        return lhs.value < rhs.value
    }
}

print("--- 10.10 Builtin ---")
let s1 = Score(value: 80)
let s2 = Score(value: 95)
print("s1 < s2:", s1 < s2)
print("s1 == s2:", s1 == s2)
print("min:", min(s1, s2).value)
print("sorted:", [s2, s1, Score(value: 50)].sorted().map { $0.value })

// CustomStringConvertible
struct PointD: CustomStringConvertible {
    let x, y: Int
    var description: String { return "(\(x), \(y))" }
}

print(PointD(x: 5, y: 10))     // (5, 10)

// MARK: - 10.11 any Protocol

protocol AnimalP {
    var name: String { get }
    func sound() -> String
}

struct DogP: AnimalP {
    let name: String
    func sound() -> String { return "Гав" }
}

struct CatP: AnimalP {
    let name: String
    func sound() -> String { return "Мяу" }
}

let zoo: [any AnimalP] = [
    DogP(name: "Рекс"),
    CatP(name: "Мурка"),
    DogP(name: "Барбос")
]

print("--- 10.11 any ---")
for animal in zoo {
    print("\(animal.name): \(animal.sound())")
}

// MARK: - 10.12 some Protocol

func makeAnimal() -> some AnimalP {
    return DogP(name: "Bobby")
}

let pet = makeAnimal()
print("--- 10.12 some ---")
print(pet.name, pet.sound())

// MARK: - 10.13 Composition

protocol Named { var name: String { get } }
protocol Aged { var age: Int { get } }

func describe(_ p: any Named & Aged) {
    print("\(p.name), \(p.age) лет")
}

struct UserNA: Named, Aged {
    let name: String
    let age: Int
}

print("--- 10.13 Composition ---")
describe(UserNA(name: "Айдос", age: 25))

// MARK: - 10.14 Associated types + 10.15 Primary

protocol Container<Element> {
    associatedtype Element
    var count: Int { get }
    func get(at index: Int) -> Element
}

struct IntBox: Container {
    let items: [Int]
    var count: Int { items.count }
    func get(at index: Int) -> Int { items[index] }
}

let intBox = IntBox(items: [10, 20, 30])
print("--- 10.14 Container<Int> ---")

func printContainer(_ c: any Container<Int>) {
    for i in 0..<c.count {
        print(c.get(at: i), terminator: " ")
    }
    print()
}
printContainer(intBox)

// MARK: - 10.16 Generic vs any

func greetGeneric<T: Greetable>(_ thing: T) {
    thing.sayHello()
}

func greetAny(_ thing: any Greetable) {
    thing.sayHello()
}

print("--- 10.16 Generic vs any ---")
greetGeneric(PersonG(name: "Generic Айдос"))
greetAny(PersonG(name: "Any Айдос"))

// MARK: - 10.17 Self в протоколе

protocol Cloneable {
    func clone() -> Self
}

struct PointCl: Cloneable {
    var x, y: Int
    func clone() -> PointCl {
        return PointCl(x: x, y: y)
    }
}

print("--- 10.17 Self ---")
let original = PointCl(x: 5, y: 10)
let copy = original.clone()
print("original:", original.x, original.y)
print("copy:", copy.x, copy.y)

// MARK: - 10.18 POP — Storage пример

protocol Storage {
    associatedtype Value
    func save(_ value: Value)
    func load() -> Value?
}

class InMemoryStorage<Value>: Storage {
    private var stored: Value?
    func save(_ value: Value) { stored = value }
    func load() -> Value? { stored }
}

print("--- 10.18 POP Storage ---")
let storage = InMemoryStorage<String>()
storage.save("token-abc-123")
print("loaded:", storage.load() ?? "nil")

// MARK: - 10.19 Extension

extension String {
    var isValidEmail: Bool {
        return self.contains("@") && self.contains(".")
    }
}

extension Int {
    var isEven: Bool { self % 2 == 0 }
    func times(_ block: () -> Void) {
        for _ in 0..<self { block() }
    }
    func factorial() -> Int {
        guard self >= 0 else { return 0 }
        if self == 0 { return 1 }
        return (1...self).reduce(1, *)
    }
}

print("--- 10.19 Extension ---")
print("aidos@example.kz".isValidEmail)
print("hello".isValidEmail)
print("4.isEven:", 4.isEven)
print("7.isEven:", 7.isEven)
print("3.times:")
3.times { print("  Hi") }
print("5.factorial():", 5.factorial())
print("0.factorial():", 0.factorial())

// MARK: - Большое упражнение 10.3 — Shape

print("--- 10.3 Shape ---")

protocol Shape {
    var area: Double { get }
    var perimeter: Double { get }
    func describe() -> String
}

extension Shape {
    func describe() -> String {
        let typeName = String(describing: type(of: self))
        let a = area.formatted(.number.precision(.fractionLength(2)))
        let p = perimeter.formatted(.number.precision(.fractionLength(2)))
        return "\(typeName), площадь: \(a), периметр: \(p)"
    }
}

struct Circle: Shape {
    let radius: Double
    var area: Double { return .pi * radius * radius }
    var perimeter: Double { return 2 * .pi * radius }
}

struct RectangleShape: Shape {
    let width: Double
    let height: Double
    var area: Double { return width * height }
    var perimeter: Double { return 2 * (width + height) }
}

struct Triangle: Shape {
    let side: Double
    var area: Double { return sqrt(3) / 4 * side * side }
    var perimeter: Double { return 3 * side }
}

func printAll(_ shapes: [any Shape]) {
    for shape in shapes {
        print(shape.describe())
    }
}

func totalArea(_ shapes: [any Shape]) -> Double {
    return shapes.reduce(0) { $0 + $1.area }
}

let shapes: [any Shape] = [
    Circle(radius: 5),
    RectangleShape(width: 3, height: 4),
    Triangle(side: 6)
]
printAll(shapes)
print("Сумма площадей:", totalArea(shapes).formatted(.number.precision(.fractionLength(2))))
