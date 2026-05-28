//
//  AppTheme.swift
//  bemyrider
//
//  Design system for SwiftUI screens.
//  UIKit code continues to use CustomColor.swift / CustomFont.swift.
//

import SwiftUI

enum AppTheme {

    // MARK: - Colors
    // SwiftUI.Color qualified explicitly to avoid conflict with `class Color: UIColor` in CustomColor.swift

    enum Colors {

        // MARK: Brand

        /// Brand purple — rgb(62, 62, 112)
        static let purple = SwiftUI.Color(red: 62/255, green: 62/255, blue: 112/255)
        /// Brand orange — rgb(240, 139, 24)
        static let orange = SwiftUI.Color(red: 240/255, green: 139/255, blue: 24/255)

        // MARK: Legacy aliases (kept for backward compatibility)

        /// Charcoal grey — rgb(47, 53, 60)
        static let charcoalGrey = SwiftUI.Color(red: 47/255, green: 53/255, blue: 60/255)
        /// Light grey — rgb(68, 68, 68)
        static let lightGrey = SwiftUI.Color(red: 68/255, green: 68/255, blue: 68/255)
        /// Extra light grey — rgb(129, 129, 129)
        static let extraLightGrey = SwiftUI.Color(red: 129/255, green: 129/255, blue: 129/255)

        // MARK: Gradients

        /// Header gradient start — (0.16, 0.13, 0.40)
        static let gradientStart = SwiftUI.Color(red: 0.16, green: 0.13, blue: 0.40)
        /// Header gradient mid — (0.22, 0.20, 0.45)
        static let gradientMid = SwiftUI.Color(red: 0.22, green: 0.20, blue: 0.45)
        /// Header gradient end — (0.20, 0.22, 0.35)
        static let gradientEnd = SwiftUI.Color(red: 0.20, green: 0.22, blue: 0.35)

        // MARK: Backgrounds

        /// App background — (0.96, 0.96, 0.97)
        static let background = SwiftUI.Color(red: 0.96, green: 0.96, blue: 0.97)
        /// Card / section background — (0.96, 0.96, 0.98)
        static let cardBackground = SwiftUI.Color(red: 0.96, green: 0.96, blue: 0.98)
        /// Light section background — (0.95, 0.96, 0.97)
        static let sectionBackground = SwiftUI.Color(red: 0.95, green: 0.96, blue: 0.97)
        /// Subtle background — (0.94, 0.95, 0.96)
        static let subtleBackground = SwiftUI.Color(red: 0.94, green: 0.95, blue: 0.96)
        /// Light orange tint — (0.99, 0.94, 0.88)
        static let lightOrange = SwiftUI.Color(red: 0.99, green: 0.94, blue: 0.88)
        /// Warm background — (1.0, 0.97, 0.88)
        static let warmBackground = SwiftUI.Color(red: 1.0, green: 0.97, blue: 0.88)
        /// Light purple tint — (0.92, 0.92, 0.97)
        static let lightPurple = SwiftUI.Color(red: 0.92, green: 0.92, blue: 0.97)
        /// Success light background — (0.88, 0.96, 0.90)
        static let successLightBg = SwiftUI.Color(red: 0.88, green: 0.96, blue: 0.90)
        /// Info light background — (0.93, 0.94, 0.98)
        static let infoLightBg = SwiftUI.Color(red: 0.93, green: 0.94, blue: 0.98)

        // MARK: Text

        /// Primary text — (0.15, 0.15, 0.22)
        static let textPrimary = SwiftUI.Color(red: 0.15, green: 0.15, blue: 0.22)
        /// Dark text — (0.20, 0.20, 0.25)
        static let textDark = SwiftUI.Color(red: 0.20, green: 0.20, blue: 0.25)
        /// Secondary text — (0.40, 0.40, 0.45)
        static let textSecondary = SwiftUI.Color(red: 0.40, green: 0.40, blue: 0.45)
        /// Tertiary text — (0.42, 0.42, 0.47)
        static let textTertiary = SwiftUI.Color(red: 0.42, green: 0.42, blue: 0.47)
        /// Caption / muted text — (0.55, 0.55, 0.60)
        static let textCaption = SwiftUI.Color(red: 0.55, green: 0.55, blue: 0.60)
        /// Placeholder text — (0.65, 0.65, 0.68)
        static let placeholder = SwiftUI.Color(red: 0.65, green: 0.65, blue: 0.68)
        /// Disabled text — (0.50, 0.50, 0.55)
        static let textDisabled = SwiftUI.Color(red: 0.50, green: 0.50, blue: 0.55)

        // MARK: Borders & Separators

        /// Light border — (0.75, 0.75, 0.78)
        static let border = SwiftUI.Color(red: 0.75, green: 0.75, blue: 0.78)
        /// Separator line — (0.90, 0.90, 0.92)
        static let separator = SwiftUI.Color(red: 0.90, green: 0.90, blue: 0.92)
        /// Subtle border — (0.88, 0.88, 0.90)
        static let borderSubtle = SwiftUI.Color(red: 0.88, green: 0.88, blue: 0.90)
        /// Medium border — (0.80, 0.80, 0.82)
        static let borderMedium = SwiftUI.Color(red: 0.80, green: 0.80, blue: 0.82)
        /// Light grey fill — (0.60, 0.60, blue: 0.65)
        static let greyLight = SwiftUI.Color(red: 0.60, green: 0.60, blue: 0.65)
        /// Mid grey — (0.68, 0.68, 0.72)
        static let greyMid = SwiftUI.Color(red: 0.68, green: 0.68, blue: 0.72)
        /// Dark grey — (0.35, 0.35, 0.40)
        static let greyDark = SwiftUI.Color(red: 0.35, green: 0.35, blue: 0.40)
        /// Faded grey — (0.45, 0.45, 0.50)
        static let greyFaded = SwiftUI.Color(red: 0.45, green: 0.45, blue: 0.50)
        /// Dim grey — (0.62, 0.62, 0.66)
        static let greyDim = SwiftUI.Color(red: 0.62, green: 0.62, blue: 0.66)
        /// Mist — (0.92, 0.92, 0.94)
        static let mist = SwiftUI.Color(red: 0.92, green: 0.92, blue: 0.94)

        // MARK: Accents & Status

        /// Star / rating yellow — (1.0, 0.78, 0.0)
        static let starYellow = SwiftUI.Color(red: 1.0, green: 0.78, blue: 0.0)
        /// Gold accent — (1.0, 0.75, 0.0)
        static let gold = SwiftUI.Color(red: 1.0, green: 0.75, blue: 0.0)
        /// Badge orange — (0.95, 0.55, 0.15)
        static let badgeOrange = SwiftUI.Color(red: 0.95, green: 0.55, blue: 0.15)
        /// Warm orange — (0.90, 0.55, 0.20)
        static let warmOrange = SwiftUI.Color(red: 0.90, green: 0.55, blue: 0.20)
        /// Alert orange — (0.95, 0.45, 0.08)
        static let alertOrange = SwiftUI.Color(red: 0.95, green: 0.45, blue: 0.08)
        /// Error / danger red — (1.0, 0.40, 0.45)
        static let error = SwiftUI.Color(red: 1.0, green: 0.40, blue: 0.45)
        /// Deep red — (0.85, 0.32, 0.28)
        static let deepRed = SwiftUI.Color(red: 0.85, green: 0.32, blue: 0.28)
        /// Warning red — (0.95, 0.40, 0.30)
        static let warningRed = SwiftUI.Color(red: 0.95, green: 0.40, blue: 0.30)
        /// Success green — (0.20, 0.75, 0.45)
        static let success = SwiftUI.Color(red: 0.20, green: 0.75, blue: 0.45)
        /// Teal green — (0.20, 0.60, 0.40)
        static let teal = SwiftUI.Color(red: 0.20, green: 0.60, blue: 0.40)
        /// Mint green — (0.20, 0.78, 0.60)
        static let mint = SwiftUI.Color(red: 0.20, green: 0.78, blue: 0.60)
        /// Sea green — (0.20, 0.78, 0.45)
        static let seaGreen = SwiftUI.Color(red: 0.20, green: 0.78, blue: 0.45)
        /// Aqua green — (0.15, 0.65, 0.60)
        static let aqua = SwiftUI.Color(red: 0.15, green: 0.65, blue: 0.60)
        /// Link blue — (0.24, 0.47, 0.96)
        static let link = SwiftUI.Color(red: 0.24, green: 0.47, blue: 0.96)
        /// Info blue — (0.30, 0.60, 0.95)
        static let infoBlue = SwiftUI.Color(red: 0.30, green: 0.60, blue: 0.95)
        /// Accent blue — (0.25, 0.45, 0.85)
        static let accentBlue = SwiftUI.Color(red: 0.25, green: 0.45, blue: 0.85)
        /// Soft blue — (0.24, 0.35, 0.85)
        static let softBlue = SwiftUI.Color(red: 0.24, green: 0.35, blue: 0.85)
        /// Navy blue — (0.23, 0.35, 0.60)
        static let navyBlue = SwiftUI.Color(red: 0.23, green: 0.35, blue: 0.60)
        /// Ocean blue — (0.0, 0.47, 0.71)
        static let oceanBlue = SwiftUI.Color(red: 0.0, green: 0.47, blue: 0.71)

        // MARK: Purple variants

        /// Deep purple — (0.26, 0.23, 0.58)
        static let deepPurple = SwiftUI.Color(red: 0.26, green: 0.23, blue: 0.58)
        /// Medium purple — (0.30, 0.28, 0.58)
        static let mediumPurple = SwiftUI.Color(red: 0.30, green: 0.28, blue: 0.58)
        /// Rich purple — (0.30, 0.27, 0.62)
        static let richPurple = SwiftUI.Color(red: 0.30, green: 0.27, blue: 0.62)
        /// Dark purple — (0.22, 0.20, 0.50)
        static let darkPurple = SwiftUI.Color(red: 0.22, green: 0.20, blue: 0.50)
        /// Violet — (0.55, 0.30, 0.75)
        static let violet = SwiftUI.Color(red: 0.55, green: 0.30, blue: 0.75)
        /// Berry — (0.38, 0.35, 0.85)
        static let berry = SwiftUI.Color(red: 0.38, green: 0.35, blue: 0.85)
        /// Plum — (0.85, 0.30, 0.50)
        static let plum = SwiftUI.Color(red: 0.85, green: 0.30, blue: 0.50)
        /// Magenta — (0.70, 0.25, 0.55)
        static let magenta = SwiftUI.Color(red: 0.70, green: 0.25, blue: 0.55)

        // MARK: Legacy (golden tone)

        /// Legacy golden — rgb(232, 168, 56)
        static let golden = SwiftUI.Color(red: 0.910, green: 0.659, blue: 0.220)
        /// Legacy purple alt — rgb(61, 59, 107)
        static let purpleAlt = SwiftUI.Color(red: 0.239, green: 0.231, blue: 0.420)
    }

    // MARK: - UIColors
    // UIColor counterparts so UIKit code (CustomColor, VCs) can reference AppTheme as single source of truth.
    // Uses UIColor(SwiftUI.Color) available on iOS 14+.

    enum UIColors {

        // MARK: Brand
        static let purple = UIColor(Colors.purple)
        static let orange = UIColor(Colors.orange)

        // MARK: Legacy text
        static let charcoalGrey = UIColor(Colors.charcoalGrey)
        static let lightGrey = UIColor(Colors.lightGrey)
        static let extraLightGrey = UIColor(Colors.extraLightGrey)

        // MARK: Text
        static let textPrimary = UIColor(Colors.textPrimary)
        static let textSecondary = UIColor(Colors.textSecondary)

        // MARK: Borders
        static let border = UIColor(Colors.border)
        static let separator = UIColor(Colors.separator)

        // MARK: Status
        static let error = UIColor(Colors.error)
        static let success = UIColor(Colors.success)
        static let starYellow = UIColor(Colors.starYellow)
    }

    // MARK: - Fonts
    // SwiftUI.Font qualified explicitly to avoid conflict with `public struct Font` in CustomFont.swift

    enum Fonts {
        static func thin(_ size: CGFloat) -> SwiftUI.Font { .custom("Roboto-Thin", size: size) }
        static func regular(_ size: CGFloat) -> SwiftUI.Font { .custom("Roboto-Regular", size: size) }
        static func medium(_ size: CGFloat) -> SwiftUI.Font { .custom("Roboto-Medium", size: size) }
        static func bold(_ size: CGFloat) -> SwiftUI.Font { .custom("Roboto-Bold", size: size) }
    }
}

struct PresentationDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium, .large])
        } else {
            content
        }
    }
}
