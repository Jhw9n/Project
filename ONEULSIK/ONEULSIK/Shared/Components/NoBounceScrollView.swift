import SwiftUI
import UIKit

struct NoBounceScrollView<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let scrollToTopTrigger: Int

    init(
        scrollToTopTrigger: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.scrollToTopTrigger = scrollToTopTrigger
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(content: content, scrollToTopTrigger: scrollToTopTrigger)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let scrollView = UIScrollView()
        let hostingController = context.coordinator.hostingController

        viewController.view.backgroundColor = .clear
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        hostingController.sizingOptions = .intrinsicContentSize
        hostingController.safeAreaRegions = []
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        viewController.view.addSubview(scrollView)
        viewController.addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        hostingController.didMove(toParent: viewController)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        context.coordinator.scrollView = scrollView
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.hostingController.rootView = content
        context.coordinator.scrollView?.bounces = false

        guard context.coordinator.scrollToTopTrigger != scrollToTopTrigger else { return }
        context.coordinator.scrollToTopTrigger = scrollToTopTrigger
        context.coordinator.scrollView?.setContentOffset(.zero, animated: true)
    }

    final class Coordinator {
        let hostingController: UIHostingController<Content>
        weak var scrollView: UIScrollView?
        var scrollToTopTrigger: Int

        init(content: Content, scrollToTopTrigger: Int = 0) {
            hostingController = UIHostingController(rootView: content)
            self.scrollToTopTrigger = scrollToTopTrigger
        }
    }
}
