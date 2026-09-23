import Foundation

enum Money {
    /// Единственное место в приложении, где решается, как выглядит цена.
    static func text(_ amount: Double) -> String {
        amount.formatted(.currency(code: "USD"))
    }
}
