//
//  SnapshotView.swift
//  Camera
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct SnapshotConstants {
    static var checkStartTrim = CGFloat(0.675) /// I guessed this number - it's the percentage where the circle becomes the checkmark
}

struct SnapshotView: View {
    @ObservedObject var model: CameraViewModel
    @Binding var isOn: Bool
    @Binding var isEnabled: Bool

    @State var scaleAnimationActive = false /// scale up/down animation flag

    var body: some View {
        Button {
            scale(scaleAnimationActive: $scaleAnimationActive)
            if !isOn {
                isOn = true
                model.snapshotPressed?()
            }
        } label: {
            Image("CameraRim") /// rim of camera
                .foregroundColor(isOn ? Color(Constants.activeIconColor) : .white)
                .overlay(
                    Color(isOn ? Constants.activeIconColor : .white)

                        /// prevent animation glitches
                        .mask(
                            CameraInnerShape()
                                .trim(from: startTrim(), to: endTrim())
                                .stroke(
                                    .black,
                                    style: .init(
                                        lineWidth: 1.5,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .padding(EdgeInsets(top: 6, leading: 6, bottom: 4, trailing: 6))
                        )
                )
                .frame(width: 40, height: 40)
                .enabledModifier(isEnabled: isEnabled, linePadding: 11)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground()
        }
        .disabled(!isEnabled)
    }

    func startTrim() -> CGFloat {
        return isOn ? SnapshotConstants.checkStartTrim : 0
    }

    func endTrim() -> CGFloat {
        return isOn ? 1 : SnapshotConstants.checkStartTrim
    }

    func toggle() {
        withAnimation {
            isOn.toggle()
        }
    }
}

struct CameraInnerShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let circleRadius = CGFloat(4)
        let circleCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)

        path.addArc(
            center: circleCenter,
            radius: circleRadius,
            startAngle: .degrees(179.999999),
            endAngle: .degrees(180),
            clockwise: true
        )

        let checkStartX = rect.width / 2 - 4
        let checkMidX = rect.width / 2 - 0.95
        let checkEndX = rect.width / 2 + 4
        path.move(to: CGPoint(x: checkStartX, y: rect.midY))
        path.addLine(to: CGPoint(x: checkMidX, y: rect.maxY - 1.2))
        path.addLine(to: CGPoint(x: checkEndX, y: rect.minY + 0.5))
        return path
    }
}

struct SnapshotViewTester: View {
    @State var isOn = false
    var body: some View {
        SnapshotView(model: CameraViewModel(), isOn: $isOn, isEnabled: .constant(true))
    }
}

struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotViewTester()
            .padding()
            .background(Color.blue)
            .scaleEffect(4)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
