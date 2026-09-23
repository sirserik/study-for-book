import UIKit

@MainActor
final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    /// Синхронный заглянуть-в-кэш: если картинка уже скачана, отдаём сразу.
    func cachedImage(for urlString: String) -> UIImage? {
        cache.object(forKey: urlString as NSString)
    }

    func loadImage(from urlString: String) async -> UIImage? {
        if let cached = cache.object(forKey: urlString as NSString) {
            return cached
        }
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: urlString as NSString)
            return image
        } catch {
            return nil
        }
    }
}

extension UIImageView {
    func setImage(from urlString: String?, placeholder: UIImage? = nil) {
        guard let urlString = urlString else {
            image = placeholder
            return
        }

        // Уже скачана — ставим мгновенно, без мигания заглушкой.
        if let cached = ImageLoader.shared.cachedImage(for: urlString) {
            image = cached
            return
        }

        image = placeholder

        let token = urlString
        objc_setAssociatedObject(self, &AssociatedKeys.token, token, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        Task {
            let loaded = await ImageLoader.shared.loadImage(from: urlString)

            let currentToken = objc_getAssociatedObject(self, &AssociatedKeys.token) as? String
            guard currentToken == urlString else { return }

            self.image = loaded ?? placeholder
        }
    }
}

private enum AssociatedKeys {
    nonisolated(unsafe) static var token: UInt8 = 0
}
