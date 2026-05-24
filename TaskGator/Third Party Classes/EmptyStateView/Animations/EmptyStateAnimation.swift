//
//  EmptyStateAnimation.swift
//  StateView
//


import UIKit

public typealias FadeTimeInterval = TimeInterval
public typealias ScaleTimeInterval = TimeInterval

public enum EmptyStateAnimation {
    
    case fade(FadeTimeInterval, FadeTimeInterval)
    case scale(FadeTimeInterval, ScaleTimeInterval)
    case none
    
    var play: ((EmptyStateView) -> ())? {
        switch self {
        case .fade(let duration1, let duration2): return { $0.fade(duration1, duration2) }
        case .scale(let duration1, let duration2): return { $0.scale(duration1, duration2) }
        case .none: return nil
        }
    }
}
