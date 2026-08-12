import SwiftUI

struct RadialRulerPicker: View {
    @Binding var selection: Int

    let range: ClosedRange<Int>

    @State private var dragStartSelection: Int?

    private let anglePerKilogram = 3.0
    private let pointsPerStep: CGFloat = 2.7

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Canvas { context, size in
                    drawRuler(in: &context, size: size)
                }

                Image(systemName: "play.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color("green03"))
                    .rotationEffect(.degrees(90))
                    .position(
                        x: proxy.size.width / 2,
                        y: rulerTop(for: proxy.size) - 1
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("몸무게")
        .accessibilityValue("\(formattedWeight) 킬로그램")
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

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStartSelection == nil {
                    dragStartSelection = selection
                }

                guard let dragStartSelection else { return }
                let stepOffset = Int(
                    (-value.translation.width / pointsPerStep).rounded()
                )
                selection = min(
                    max(dragStartSelection + stepOffset, range.lowerBound),
                    range.upperBound
                )
            }
            .onEnded { _ in
                dragStartSelection = nil
            }
    }

    private var formattedWeight: String {
        if selection.isMultiple(of: 10) {
            return "\(selection / 10)"
        }

        return String(format: "%.1f", Double(selection) / 10)
    }

    private func drawRuler(in context: inout GraphicsContext, size: CGSize) {
        let radius = max(size.width * 0.8, 300)
        let center = CGPoint(
            x: size.width / 2,
            y: rulerTop(for: size) + radius
        )
        let visibleAngles = -132.0 ... -48.0

        drawArc(
            in: &context,
            center: center,
            radius: radius,
            angles: visibleAngles
        )
        drawArc(
            in: &context,
            center: center,
            radius: radius - 82,
            angles: visibleAngles
        )

        let selectedKilograms = Double(selection) / 10
        let minimumVisibleValue = max(
            range.lowerBound / 10,
            Int(floor(selectedKilograms - 15))
        )
        let maximumVisibleValue = min(
            range.upperBound / 10,
            Int(ceil(selectedKilograms + 15))
        )

        for value in minimumVisibleValue...maximumVisibleValue {
            let angle = -90 + (Double(value) - selectedKilograms) * anglePerKilogram
            guard visibleAngles.contains(angle) else { continue }

            drawTick(
                for: value,
                angle: angle,
                center: center,
                radius: radius,
                in: &context
            )
        }
    }

    private func drawArc(
        in context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat,
        angles: ClosedRange<Double>
    ) {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(angles.lowerBound),
            endAngle: .degrees(angles.upperBound),
            clockwise: false
        )
        context.stroke(path, with: .color(Color("gray02")), lineWidth: 1)
    }

    private func drawTick(
        for value: Int,
        angle: Double,
        center: CGPoint,
        radius: CGFloat,
        in context: inout GraphicsContext
    ) {
        let tickLength: CGFloat
        if value.isMultiple(of: 10) {
            tickLength = 24
        } else if value.isMultiple(of: 5) {
            tickLength = 17
        } else {
            tickLength = 10
        }

        var path = Path()
        path.move(to: point(center: center, radius: radius, angle: angle))
        path.addLine(
            to: point(
                center: center,
                radius: radius - tickLength,
                angle: angle
            )
        )
        context.stroke(path, with: .color(Color("gray04")), lineWidth: 1)

        guard value.isMultiple(of: 10) else { return }

        let label = context.resolve(
            Text("\(value)")
                .font(.pretendardMedium(12))
                .foregroundStyle(Color("black01"))
        )
        context.draw(
            label,
            at: point(
                center: center,
                radius: radius - 42,
                angle: angle
            ),
            anchor: .center
        )
    }

    private func point(
        center: CGPoint,
        radius: CGFloat,
        angle: Double
    ) -> CGPoint {
        let radians = CGFloat(angle * .pi / 180)
        return CGPoint(
            x: center.x + radius * cos(radians),
            y: center.y + radius * sin(radians)
        )
    }

    private func rulerTop(for size: CGSize) -> CGFloat {
        size.height * 0.55
    }
}
