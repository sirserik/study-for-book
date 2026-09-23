import XCTest
@testable import study_for_book

@MainActor
final class RegistrationFormTests: XCTestCase {

    func test_валиднаяФорма_безОшибок() {
        let form = RegistrationForm(name: "Айдос", email: "aidos@example.kz", password: "supersecret")
        XCTAssertTrue(form.validate().isEmpty)
    }

    func test_короткоеИмя() {
        let form = RegistrationForm(name: "А", email: "aidos@example.kz", password: "supersecret")
        XCTAssertEqual(form.validate(), [.nameTooShort])
    }

    func test_кривойEmail() {
        for email in ["aidos", "aidos@", "aidos@example", "@example.kz", "aidos example@kz"] {
            let form = RegistrationForm(name: "Айдос", email: email, password: "supersecret")
            XCTAssertTrue(form.validate().contains(.invalidEmail), "email «\(email)» должен быть отклонён")
        }
    }

    func test_короткийПароль() {
        let form = RegistrationForm(name: "Айдос", email: "aidos@example.kz", password: "1234567")
        XCTAssertEqual(form.validate(), [.passwordTooShort])
    }

    func test_всёСразуНеверно_триОшибки() {
        let form = RegistrationForm(name: "", email: "нет", password: "123")
        XCTAssertEqual(form.validate().count, 3)
    }
}
