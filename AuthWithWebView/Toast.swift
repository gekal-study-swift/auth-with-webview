import UIKit

/// 画面の操作を妨げずに短いメッセージを出す（Android の Toast 相当）。
///
/// `UIAlertController` と違って操作を妨げず、SFSafariViewController などの上にも出せるよう
/// 専用のウィンドウに載せる。
@MainActor
enum Toast {
    nonisolated static let shortDuration: TimeInterval = 2
    nonisolated static let longDuration: TimeInterval = 3.5

    private static var window: UIWindow?
    private static var dismissal: DispatchWorkItem?

    static func show(_ message: String, duration: TimeInterval, in scene: UIWindowScene) {
        // 直前のものは置き換える
        hide()

        // rootViewController を持たない UIWindow は表示されないため、空のものを載せる
        let root = UIViewController()
        root.view.backgroundColor = .clear

        let window = PassthroughWindow(windowScene: scene)
        window.windowLevel = .alert
        window.backgroundColor = .clear
        window.rootViewController = root
        window.isHidden = false
        self.window = window

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        container.layer.cornerRadius = 20
        container.alpha = 0
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        root.view.addSubview(container)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            container.centerXAnchor.constraint(equalTo: root.view.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: root.view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: root.view.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(lessThanOrEqualTo: root.view.trailingAnchor, constant: -24),
        ])

        UIView.animate(withDuration: 0.2) { container.alpha = 1 }

        let dismissal = DispatchWorkItem { hide(animated: true) }
        self.dismissal = dismissal
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: dismissal)
    }

    private static func hide(animated: Bool = false) {
        dismissal?.cancel()
        dismissal = nil

        guard let window else { return }
        self.window = nil

        guard animated else {
            window.isHidden = true
            return
        }

        UIView.animate(withDuration: 0.2) {
            window.rootViewController?.view.alpha = 0
        } completion: { _ in
            window.isHidden = true
        }
    }
}

/// 触ってもアプリ側に届くようにする。トーストは操作対象ではない。
private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { nil }
}

extension UIViewController {
    func showToast(message: String, duration: TimeInterval = Toast.shortDuration) {
        guard let scene = view.window?.windowScene else { return }
        Toast.show(message, duration: duration, in: scene)
    }
}
