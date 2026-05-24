//
//  CustomColor.swift
//  Lifester
//
//  Created by Nirav Sapariya on 06/12/17.
//  Copyright © 2017 NMS. All rights reserved.
//
//  Shared colors now delegate to AppTheme (single source of truth).
//  UIKit-only colors that have no SwiftUI counterpart stay here.
//

import UIKit

class Color: UIColor {
    //Ref from 'Material' -> TextField
    //Ex: detailColor = Color.darkText.others

    //For generate code base on hex code follow this link: http://uicolor.xyz/#/hex-to-ui

    // dark text
    class darkText {
        static let primary = Color.black.withAlphaComponent(0.87)
        static let secondary = Color.black.withAlphaComponent(0.54)
        static let others = Color.black.withAlphaComponent(0.38)
        static let dividers = Color.black.withAlphaComponent(0.12)
    }

    // light text
    class lightText {
        static let primary = Color.white
        static let secondary = Color.white.withAlphaComponent(0.7)
        static let others = Color.white.withAlphaComponent(0.5)
        static let dividers = Color.white.withAlphaComponent(0.12)
    }

    //Black
    class Black {
        static let theam: UIColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        static let primary = UIColor.black
        static let secondaryColor: UIColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.7)
        static let otherColor: UIColor = UIColor(red: 0.31, green: 0.31, blue: 0.31, alpha: 1.00)
    }

    //Pink
    class pink {
        static let dark = UIColor(red: 0.76, green: 0.01, blue: 0.51, alpha: 1.0)
        static let light = UIColor(red: 0.99, green: 0.22, blue: 0.62, alpha: 1.0)
    }

    //Green — "theam" is actually brand purple (legacy naming)
    class green {
        static let theam: UIColor = AppTheme.UIColors.purple
        static let dark = UIColor(red: 0.05, green: 0.36, blue: 0.13, alpha: 1.0)
        static let light = UIColor(red: 0.01, green: 0.67, blue: 0.18, alpha: 1.0)
    }

    //Blue
    class blue {
        static let lightText = UIColor(red: 0.22, green: 0.45, blue: 0.84, alpha: 1.00)
    }

    //Orange
    class orange {
    }

    class purple {
        static let bgColor: UIColor = AppTheme.UIColors.purple
    }

    //Red
    class red {
        static let lightText: UIColor = UIColor(red: 0.92, green: 0.14, blue: 0.16, alpha: 1.00)
    }

    //Gray
    class grey {
        static let light = UIColor(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.0)
        static let dark = UIColor(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.0)
        static let lightText = UIColor(red: 0.33, green: 0.33, blue: 0.33, alpha: 1.0)
        static let textColor: UIColor = UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.00)
        static let deviderColor: UIColor = UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 1.00)
        static let lightDeviderColor: UIColor = UIColor(red: 0.01, green: 0.00, blue: 0.34, alpha: 0.1)
    }

    // Theme — shared brand colors delegate to AppTheme (single source of truth).
    // UIKit-only values that differ from SwiftUI stay here until VC migration (task 4.3).
    class Theme {
        // Delegated to AppTheme
        static let orange: UIColor = AppTheme.UIColors.orange
        static let charcolGrey: UIColor = AppTheme.UIColors.charcoalGrey
        static let lightGray: UIColor = AppTheme.UIColors.lightGrey
        static let extraLightGray: UIColor = AppTheme.UIColors.extraLightGrey
        static let purple: UIColor = AppTheme.UIColors.purple

        // UIKit-legacy values (slightly different from SwiftUI counterparts — will unify on VC migration)
        static let background: UIColor = UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
        static let lightOrange: UIColor = UIColor(red: 251.0 / 255.0, green: 245.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
        static let placeholder: UIColor = UIColor(red: 149.0 / 255.0, green: 152.0 / 255.0, blue: 156.0 / 255.0, alpha: 1.0)
        static let lightPurple: UIColor = UIColor(red: 220.0 / 255.0, green: 225.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
    }

}
