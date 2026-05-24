//
//  SplashAnimationView.swift
//  bemyrider
//
//  Faithful SwiftUI recreation of remotion/src/BootAnimation.tsx
//  120 frames @ 30fps = 4 seconds total
//  Uses the original bemyrider_logo.svg from Remotion

import SwiftUI

// MARK: - Splash Animation

struct SplashAnimationView: View {
    let onFinished: () -> Void

    // Animation state — matches Remotion variables 1:1
    @State private var logoScale: CGFloat = 0      // spring → 1
    @State private var pulseScale: CGFloat = 1     // 1 → 1.05 → 1
    @State private var ringScale: CGFloat = 0      // spring → 1
    @State private var ringOpacity: Double = 0     // 0 → 0.3 → 0.2 → 0
    @State private var slideUp: CGFloat = 0        // 0 → -60
    @State private var textOpacity: Double = 0     // 0 → 1
    @State private var textSlide: CGFloat = 25     // 25 → 0
    @State private var fadeOut: Double = 1         // 1 → 0

    // Remotion colors: backgroundColor "#3D3B6B", accentColor "#E8A838"
    private let bgColor = AppTheme.Colors.purpleAlt
    private let accent  = AppTheme.Colors.golden

    var body: some View {
        GeometryReader { geo in
            // Remotion: logoSize = width * 0.45
            let logoSize = geo.size.width * 0.45

            ZStack {
                bgColor.ignoresSafeArea()

                // Expanding ring behind logo
                // Remotion: width/height = logoSize * 2, border 3px solid accentColor
                Circle()
                    .strokeBorder(accent, lineWidth: 3)
                    .frame(width: logoSize * 2, height: logoSize * 2)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
                    .offset(y: slideUp)

                // Glow effect
                // Remotion: radial-gradient accentColor 20% opacity → transparent at 70%
                RadialGradient(
                    colors: [accent.opacity(0.12), SwiftUI.Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: logoSize * 0.8
                )
                .frame(width: logoSize * 1.6, height: logoSize * 1.6)
                .scaleEffect(logoScale * pulseScale)
                .offset(y: slideUp)

                // Logo — original bemyrider_logo.svg from Remotion
                SwiftUI.Image("bemyrider_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: logoSize, height: logoSize)
                    .scaleEffect(logoScale * pulseScale)
                    .offset(y: slideUp)

                // App name "bemyrider"
                // Remotion: fontSize 88 (at 1080w), fontWeight 700, letterSpacing 1
                // Scaled: 88/1080 ≈ 0.081 of screen width
                Text("bemyrider")
                    .font(.system(size: geo.size.width * 0.08, weight: .bold))
                    .foregroundColor(accent)
                    .tracking(1)
                    .opacity(textOpacity)
                    // Remotion: top = 50% + logoSize*0.55 + slideUp, then translateY(textSlide)
                    .offset(y: logoSize * 0.55 + slideUp + textSlide)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .opacity(fadeOut)
        }
        .onAppear {
            runAnimation()
        }
    }

    // All timings derived from Remotion frame numbers at 30fps
    private func runAnimation() {

        // ── Phase 1: Logo springs in ──
        // Remotion: spring(frame, fps=30, damping=8, stiffness=80, delay=5)
        // delay = 5/30 = 0.17s
        withAnimation(.spring(response: 0.55, dampingFraction: 0.55).delay(0.17)) {
            logoScale = 1
        }

        // ── Ring springs in ──
        // Remotion: spring(frame, fps=30, damping=200, stiffness=40, delay=8)
        // delay = 8/30 = 0.27s, critically damped
        withAnimation(.spring(response: 0.9, dampingFraction: 1.0).delay(0.27)) {
            ringScale = 1
        }
        // Ring opacity: frames [8,25] → [0, 0.3]
        withAnimation(.easeIn(duration: 0.57).delay(0.27)) {
            ringOpacity = 0.3
        }

        // ── Phase 2: Pulse ──
        // Remotion: frames [45,58,70] → [1, 1.05, 1]
        // 45/30=1.5s, duration up = (58-45)/30=0.43s, duration down = (70-58)/30=0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.43)) {
                pulseScale = 1.05
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.93) {
            withAnimation(.easeInOut(duration: 0.4)) {
                pulseScale = 1.0
            }
        }

        // ── Phase 3: Slide up + ring fade ──
        // Remotion: spring(frame-50, fps=30, damping=200) → interpolate [0,1] → [0,-60]
        // 50/30 = 1.67s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.67) {
            withAnimation(.spring(response: 0.5, dampingFraction: 1.0)) {
                slideUp = -60
            }
            // Ring opacity: frames [55,70] → [0.2, 0]
            withAnimation(.easeOut(duration: 0.5)) {
                ringOpacity = 0
            }
        }

        // ── Phase 4: Text entrance ──
        // Remotion: spring(frame-55, fps=30, damping=15, stiffness=100)
        // 55/30 = 1.83s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.83) {
            // textSlide: interpolate(textProgress, [0,1], [25, 0])
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                textSlide = 0
            }
            // textOpacity: frames [55,72] → [0,1], duration = 17/30 = 0.57s
            withAnimation(.easeIn(duration: 0.57)) {
                textOpacity = 1
            }
        }

        // ── Phase 5: Fade out ──
        // Remotion: frames [durationInFrames-15, durationInFrames-3] = [105, 117] → [1, 0]
        // 105/30 = 3.5s, duration = 12/30 = 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                fadeOut = 0
            }
        }

        // ── Done: trigger redirect ──
        // 120/30 = 4.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            onFinished()
        }
    }
}
