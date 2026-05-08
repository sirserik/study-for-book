import Foundation

// Этот Playground симулирует жизненный цикл AppDelegate/SceneDelegate/VC
// без UIKit (потому что в command-line script UIKit недоступен).
// Реальные методы UIKit вызываются iOS — здесь мы просто демонстрируем
// структуру и порядок ручным вызовом методов.

// MARK: - 12A.2/3 AppDelegate структура

class AppDelegateMock {
    func application_didFinishLaunchingWithOptions() -> Bool {
        print("[AppDelegate] didFinishLaunching")
        // глобальная инициализация
        setupAnalytics()
        setupCrashReporting()
        return true
    }

    func application_didRegisterForRemoteNotifications(token: String) {
        print("[AppDelegate] получили push token: \(token.prefix(8))...")
    }

    private func setupAnalytics() {
        print("  → analytics setup")
    }

    private func setupCrashReporting() {
        print("  → crash reporting setup")
    }
}

print("--- 12A.2 AppDelegate startup ---")
let appDelegate = AppDelegateMock()
_ = appDelegate.application_didFinishLaunchingWithOptions()
appDelegate.application_didRegisterForRemoteNotifications(token: "abc123def456")

// MARK: - 12A.4/6 SceneDelegate состояния

class SceneDelegateMock {
    var hasWindow = false

    func scene_willConnectTo() {
        print("[SceneDelegate] willConnectTo — создаём окно")
        hasWindow = true
        print("  → UIWindow + rootViewController = HomeVC")
    }

    func sceneDidBecomeActive() {
        print("[SceneDelegate] didBecomeActive — UI работает")
    }

    func sceneWillResignActive() {
        print("[SceneDelegate] willResignActive — потеря фокуса (звонок?)")
    }

    func sceneDidEnterBackground() {
        print("[SceneDelegate] didEnterBackground — сохраняем state")
    }

    func sceneWillEnterForeground() {
        print("[SceneDelegate] willEnterForeground — возвращаемся")
    }

    func sceneDidDisconnect() {
        print("[SceneDelegate] didDisconnect — окно закрыто")
    }
}

print("--- 12A.4 Scene lifecycle ---")
let scene = SceneDelegateMock()
scene.scene_willConnectTo()
scene.sceneDidBecomeActive()

print("\n--- 12A.6 Симуляция переходов состояний ---")
scene.sceneWillResignActive()    // звонок
scene.sceneDidEnterBackground()  // ушли в фон
scene.sceneWillEnterForeground() // возвращаемся
scene.sceneDidBecomeActive()     // снова активны
scene.sceneDidDisconnect()       // закрыли окно

// MARK: - 12A.8 ViewController lifecycle

class ViewControllerMock {
    let id: String
    var view_isLoaded = false

    init(id: String) {
        self.id = id
        log("init")
    }

    func loadView() {
        view_isLoaded = true
        log("loadView — создалась view")
    }

    func viewDidLoad() {
        log("viewDidLoad — настройка UI, подписки, начальная загрузка")
    }

    func viewWillAppear(_ animated: Bool) {
        log("viewWillAppear — обновить badges, перезагрузить данные")
    }

    func viewIsAppearing(_ animated: Bool) {
        log("viewIsAppearing — frame посчитан, focus, scroll")
    }

    func viewDidLayoutSubviews() {
        log("viewDidLayoutSubviews — frame готов, cornerRadius")
    }

    func viewDidAppear(_ animated: Bool) {
        log("viewDidAppear — экран виден, аналитика, анимации")
    }

    func viewWillDisappear(_ animated: Bool) {
        log("viewWillDisappear — сохранить черновик")
    }

    func viewDidDisappear(_ animated: Bool) {
        log("viewDidDisappear — отменить task, удалить observer")
    }

    deinit {
        print("[\(id)] deinit — финальная очистка")
    }

    private func log(_ method: String) {
        print("[\(id)] \(method)")
    }
}

print("\n--- 12A.8 ViewController полный lifecycle ---")
do {
    let vc = ViewControllerMock(id: "HomeVC")
    vc.loadView()
    vc.viewDidLoad()
    vc.viewWillAppear(true)
    vc.viewIsAppearing(true)
    vc.viewDidLayoutSubviews()
    vc.viewDidAppear(true)
    print("  --- VC активен ---")
    vc.viewWillDisappear(true)
    vc.viewDidDisappear(true)
}
// deinit вызовется здесь автоматически

// MARK: - 12A.15 Container — push дочернего

print("\n--- 12A.15 NavigationController push ---")
do {
    let homeVC = ViewControllerMock(id: "HomeVC")
    homeVC.loadView()
    homeVC.viewDidLoad()
    homeVC.viewWillAppear(true)
    homeVC.viewIsAppearing(true)
    homeVC.viewDidAppear(true)

    print("\n  [user тапнул товар → push DetailVC]\n")

    let detailVC = ViewControllerMock(id: "DetailVC")
    detailVC.loadView()
    detailVC.viewDidLoad()
    detailVC.viewWillAppear(true)
    homeVC.viewWillDisappear(true)
    detailVC.viewIsAppearing(true)
    detailVC.viewDidAppear(true)
    homeVC.viewDidDisappear(true)

    print("\n  [user тапнул back → pop DetailVC]\n")

    detailVC.viewWillDisappear(true)
    homeVC.viewWillAppear(true)
    homeVC.viewIsAppearing(true)
    homeVC.viewDidAppear(true)
    detailVC.viewDidDisappear(true)
    // detailVC уничтожится здесь
}

// MARK: - 12A.17 Bundle (попытка прочитать версию приложения)

print("\n--- 12A.17 Bundle.main ---")
if let info = Bundle.main.infoDictionary {
    print("Bundle keys (sample):", Array(info.keys.prefix(5)))
} else {
    print("Bundle.main.infoDictionary недоступно в скрипте")
}

// MARK: - Большое упражнение 12A.1: VC с реальным логированием

print("\n--- 12A.1 Полный VC lifecycle лог ---")

class LifecycleVC {
    var observerToken: NSObjectProtocol?
    var loadTask: Task<Void, Never>?

    init() {
        log("init")
    }

    func viewDidLoad() {
        log("viewDidLoad — подписка observer, старт async load")
        observerToken = NotificationCenter.default.addObserver(
            forName: Notification.Name("test"), object: nil, queue: .main
        ) { _ in }

        loadTask = Task {
            try? await Task.sleep(for: .milliseconds(100))
            await MainActor.run {
                print("  → данные пришли через 100мс")
            }
        }
    }

    func viewDidAppear(_ animated: Bool) {
        log("viewDidAppear")
    }

    func viewDidDisappear(_ animated: Bool) {
        log("viewDidDisappear — отменяем task")
        loadTask?.cancel()
    }

    deinit {
        log("deinit — удаляем observer")
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func log(_ method: String) {
        print("[LifecycleVC] \(method)")
    }
}

do {
    let vc = LifecycleVC()
    vc.viewDidLoad()
    vc.viewDidAppear(true)
    vc.viewDidDisappear(true)
}
// При выходе из do — vc уничтожается, deinit срабатывает
// loadTask отменяется

Thread.sleep(forTimeInterval: 0.2)
print("\n--- Done ---")
