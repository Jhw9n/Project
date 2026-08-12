import SwiftUI

struct VerticalRulerPicker: View {
    @Binding var selection: Int

    let range: ClosedRange<Int>

    private let rowHeight: CGFloat = 24
    @State private var scrollPosition: Int?

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(range.reversed()), id: \.self) { value in
                        rulerMark(for: value)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .frame(height: rowHeight)
                            .id(value)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(
                .vertical,
                max(0, (proxy.size.height - rowHeight) / 2),
                for: .scrollContent
            )
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $scrollPosition, anchor: .center)
            .onAppear {
                scrollPosition = selection
            }
            .onChange(of: scrollPosition) { _, newValue in
                guard let newValue else { return }
                selection = newValue
            }
            .onChange(of: selection) { _, newValue in
                guard scrollPosition != newValue else { return }
                scrollPosition = newValue
            }
            .overlay(alignment: .trailing) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color("green03"))
                    .rotationEffect(.degrees(180))
                    .offset(x: -5)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("키")
        .accessibilityValue("\(selection) 센티미터")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                selection = min(selection + 1, range.upperBound)
            case .decrement:
                selection = max(selection - 1, range.lowerBound)
            @unknown default:
                break
            }
        }
    }

    private func rulerMark(for value: Int) -> some View {
        HStack(spacing: 6) {
            if value.isMultiple(of: 10) {
                Text("\(value)")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("black01"))
                    .frame(width: 28, alignment: .trailing)
            } else {
                Color.clear
                    .frame(width: 28)
            }

            Spacer(minLength: 0)

            Rectangle()
                .fill(Color("gray04"))
                .frame(width: tickWidth(for: value), height: 1)
        }
        .frame(width: 64)
    }

    private func tickWidth(for value: Int) -> CGFloat {
        if value.isMultiple(of: 10) {
            return 18
        }

        if value.isMultiple(of: 5) {
            return 12
        }

        return 6
    }
}
