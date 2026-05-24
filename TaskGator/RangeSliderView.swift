//
//  RangeSliderView.swift
//  TaskGator
//
//  Custom Range Slider - sostituisce RangeSeekSlider incompatibile con iOS 26
//

import SwiftUI

struct RangeSliderView: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    var onChanged: ((Double, Double) -> Void)?

    @State private var isDraggingMin = false
    @State private var isDraggingMax = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - 40
            let rangeWidth = range.upperBound - range.lowerBound
            let minPosition = (minValue - range.lowerBound) / rangeWidth * width
            let maxPosition = (maxValue - range.lowerBound) / rangeWidth * width

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)

                // Selected range
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue)
                    .frame(width: maxPosition - minPosition, height: 8)
                    .offset(x: minPosition + 20)

                // Min thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: minPosition + 8)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingMin = true
                                let newValue = range.lowerBound + (value.location.x / width) * rangeWidth
                                minValue = min(max(newValue, range.lowerBound), maxValue - step)
                                minValue = (minValue / step).rounded() * step
                                onChanged?(minValue, maxValue)
                            }
                            .onEnded { _ in
                                isDraggingMin = false
                            }
                    )

                // Max thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: maxPosition + 8)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingMax = true
                                let newValue = range.lowerBound + (value.location.x / width) * rangeWidth
                                maxValue = max(min(newValue, range.upperBound), minValue + step)
                                maxValue = (maxValue / step).rounded() * step
                                onChanged?(minValue, maxValue)
                            }
                            .onEnded { _ in
                                isDraggingMax = false
                            }
                    )
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 40)
    }
}

// Coordinator for UIKit bridge
class RangeSliderCoordinator: NSObject, RangeSeekSliderDelegate {
    var onChange: ((CGFloat, CGFloat) -> Void)?

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        onChange?(minValue, maxValue)
    }
}

// SwiftUI wrapper for UIKit RangeSeekSlider (fallback)
struct RangeSeekSliderUIKitWrapper: UIViewRepresentable {
    var minValue: CGFloat
    var maxValue: CGFloat
    var range: ClosedRange<CGFloat>
    var onChange: ((CGFloat, CGFloat) -> Void)?

    func makeUIView(context: Context) -> RangeSeekSlider {
        let slider = RangeSeekSlider()
        slider.minValue = minValue
        slider.maxValue = maxValue
        slider.selectedMinValue = minValue
        slider.selectedMaxValue = maxValue
        slider.delegate = context.coordinator
        return slider
    }

    func updateUIView(_ uiView: RangeSeekSlider, context: Context) {
        uiView.minValue = minValue
        uiView.maxValue = maxValue
    }

    func makeCoordinator() -> RangeSliderCoordinator {
        let coordinator = RangeSliderCoordinator()
        coordinator.onChange = onChange
        return coordinator
    }
}
