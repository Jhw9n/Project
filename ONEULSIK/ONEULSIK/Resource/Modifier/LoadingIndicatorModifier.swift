//import SwiftUI
//
//struct LoadingIndicator: ViewModifier {
//    var isShowing: Bool
//
//    func body(content: Content) -> some View {
//        ZStack {
//            content
//            if isShowing {
//                loadingView
//            }
//        }
//    }
//
//    private var loadingView: some View {
//        GeometryReader { proxyReader in
//            ZStack(alignment: .center) {
//                Color.gray09.opacity(0.15)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                
//                ProgressView()
//                    .progressViewStyle(
//                        CircularProgressViewStyle(tint: .white)
//                    )
//                    .scaleEffect(x: 2, y: 2, anchor: .center)
//            }
//        }
//        .ignoresSafeArea()
//        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
//    }
//}
//
//extension View {
//    func loadingIndicator(_ isShowing: Bool) -> some View {
//        self.modifier(LoadingIndicator(isShowing: isShowing))
//    }
//}
//
//
//#Preview {
//    LoginView(container: .init())
//}
//
