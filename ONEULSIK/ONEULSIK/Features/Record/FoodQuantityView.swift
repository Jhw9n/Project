import SwiftUI

struct FoodQuantityView: View {
    let food: FoodCatalogItem
    let onCancel: () -> Void
    let onComplete: (Double) -> Void

    @State private var servingCount = 1.0

    var body: some View {
        VStack(spacing: 0) {
            header

            foodInformation
                .padding(.top, 12)

            quantityControl
                .padding(.top, 34)

            Spacer(minLength: 16)

            Button {
                onComplete(servingCount)
            } label: {
                Text("완료")
                    .font(.pretendardSemiBold(16))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.green03, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .background(Color.gray01)
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.black01)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(height: 56)
    }

    private var foodInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(food.name)
                    .font(.pretendardSemiBold(18))

                Spacer()

                Text(calories, format: .number.precision(.fractionLength(0)))
                    .font(.pretendardMedium(16))
                + Text("kcal")
                    .font(.pretendardMedium(16))
            }

            Text(food.servingDescription(for: servingCount))
                .font(.pretendardMedium(12))
                .foregroundStyle(Color.gray03)
        }
        .foregroundStyle(Color.black01)
        .padding(.horizontal, 16)
    }

    private var quantityControl: some View {
        HStack(spacing: 0) {
            quantityButton(systemName: "minus", isEnabled: servingCount > 0.5) {
                servingCount = max(0.5, servingCount - 0.5)
            }

            Text(formattedServingCount)
                .font(.pretendardSemiBold(16))
                .foregroundStyle(Color.black01)
                .frame(maxWidth: .infinity)

            quantityButton(systemName: "plus", isEnabled: true) {
                servingCount += 0.5
            }
        }
        .frame(height: 40)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 243 / 255), in: Capsule())
        .padding(.horizontal, 16)
    }

    private func quantityButton(
        systemName: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 104, height: 40)
                .background(Color(red: 123 / 255, green: 123 / 255, blue: 123 / 255), in: Capsule())
                .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var calories: Double {
        food.nutrition.calories * servingCount
    }

    private var formattedServingCount: String {
        servingCount.formatted(
            .number.precision(.fractionLength(servingCount.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1))
        )
    }
}

#Preview {
    FoodQuantityView(
        food: FoodCatalogService().foods[0],
        onCancel: {},
        onComplete: { _ in }
    )
        .frame(height: 262)
}
