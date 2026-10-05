import SwiftUI

struct AIWeeklyReportCard: View {
    let message: String
    var isLoading = false

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                Image("healthFeedbackCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)

                Text("AI")
                    .font(.pretendardSemiBold(10))
                    .foregroundStyle(Color.gray04)
            }

            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(Color.green03)
                }

                Text(message)
                    .font(.pretendardSemiBold(14))
                    .foregroundStyle(Color.black01)
                    .lineSpacing(4)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 102)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
