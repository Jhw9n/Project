import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.green03
                    .ignoresSafeArea()

                AuthBrandView()
                    .padding(.top, proxy.size.height * 0.389 + 20)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    SplashView()
}
