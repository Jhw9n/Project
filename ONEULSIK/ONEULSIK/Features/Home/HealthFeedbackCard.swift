import SwiftUI

struct HealthFeedbackCard: View {
    let message: String

    var body: some View {
        HStack(spacing: 16) {
            Image("healthFeedbackCharacter")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)

            Text(message)
                .font(.pretendardMedium(16))
                .foregroundStyle(Color(red: 33 / 255, green: 33 / 255, blue: 47 / 255))
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
