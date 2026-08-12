import SwiftUI

struct RecordView: View {
    var body: some View {
        ZStack {
            Color.gray01
                .ignoresSafeArea()

            Text("기록")
                .font(.pretendardBold(24))
                .foregroundStyle(Color.black01)
        }
    }
}

#Preview {
    RecordView()
}
