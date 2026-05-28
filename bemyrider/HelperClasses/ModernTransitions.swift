//
//  ModernTransitions.swift
//  bemyrider
//
//  Modern transition animations with Spring effects for smoother UX.
//

import UIKit

// MARK: - Transition Types

enum TransitionType {
    case push
    case pop
    case modalPresent
    case modalDismiss
    case tabSwitch
}

enum TransitionStyle {
    case spring
    case easeInOut
    case smooth
}

// MARK: - Modern Transition Helper

final class ModernTransitions {
    
    // Singleton
    static let shared = ModernTransitions()
    private init() {}
    
    // MARK: - Tab Bar Transitions (Login ↔ Home)
    
    /// Animate root view controller change with smooth cross-dissolve + scale
    func animateRootTransition(to newRoot: UIViewController, in window: UIWindow?, completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        // Prepare new root
        newRoot.view.alpha = 0
        newRoot.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        window.rootViewController = newRoot
        
        // Animate with spring effect
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut]
        ) {
            newRoot.view.alpha = 1
            newRoot.view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    // MARK: - Navigation Push Transitions
    
    /// Custom push animation with slide + fade
    func animatePush(in navigationController: UINavigationController?, to viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let nav = navigationController else {
            nav?.pushViewController(viewController, animated: true)
            completion?()
            return
        }
        
        // Setup initial state
        viewController.view.alpha = 0
        viewController.view.transform = CGAffineTransform(translationX: nav.view.bounds.width, y: 0)
        
        nav.pushViewController(viewController, animated: false)
        
        // Animate in
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            viewController.view.alpha = 1
            viewController.view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    /// Custom pop animation with slide + fade
    func animatePop(in navigationController: UINavigationController?, completion: (() -> Void)? = nil) {
        guard let nav = navigationController,
              let topVC = nav.viewControllers.last,
              nav.viewControllers.count > 1 else {
            nav?.popViewController(animated: true)
            completion?()
            return
        }
        
        // Store reference before pop
        let poppedVC = topVC
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: [.curveEaseIn]
        ) {
            poppedVC.view.alpha = 0
            poppedVC.view.transform = CGAffineTransform(translationX: -nav.view.bounds.width * 0.3, y: 0)
        } completion: { _ in
            nav.popViewController(animated: false)
            completion?()
        }
    }
    
    // MARK: - Modal Transitions
    
    /// Present modal with slide up + backdrop blur
    func animateModalPresent(to viewController: UIViewController, from parentVC: UIViewController, withBlur: Bool = true, completion: (() -> Void)? = nil) {
        
        // Create backdrop
        let backdropView = UIView(frame: parentVC.view.bounds)
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backdropView.alpha = 0
        parentVC.view.addSubview(backdropView)
        
        // Blur effect if requested
        if withBlur {
            let blurEffect = UIBlurEffect(style: .systemMaterialDark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = backdropView.bounds
            blurView.alpha = 0
            backdropView.addSubview(blurView)
        }
        
        // Setup modal
        viewController.view.frame = parentVC.view.bounds
        viewController.view.transform = CGAffineTransform(translationX: 0, y: parentVC.view.bounds.height)
        viewController.view.alpha = 0
        
        parentVC.addChild(viewController)
        parentVC.view.addSubview(viewController.view)
        
        // Animate
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            backdropView.alpha = 1
            viewController.view.transform = .identity
            viewController.view.alpha = 1
        } completion: { _ in
            viewController.didMove(toParent: parentVC)
            
            // Store backdrop for removal
            viewController.view.tag = 999999
            backdropView.tag = 999998
            objc_setAssociatedObject(viewController, "backdropView", backdropView, .OBJC_ASSOCIATION_RETAIN)
            
            completion?()
        }
    }
    
    /// Dismiss modal with slide down + fade
    func animateModalDismiss(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let parentVC = viewController.parent else {
            viewController.dismiss(animated: true, completion: completion)
            return
        }
        
        // Get backdrop
        var backdropView: UIView? = nil
        if let found = objc_getAssociatedObject(viewController, "backdropView") as? UIView {
            backdropView = found
        } else {
            // Fallback: find by tag
            backdropView = parentVC.view.viewWithTag(999998)
        }
        
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.3,
            options: [.curveEaseIn]
        ) {
            backdropView?.alpha = 0
            viewController.view.transform = CGAffineTransform(translationX: 0, y: parentVC.view.bounds.height)
            viewController.view.alpha = 0
        } completion: { _ in
            backdropView?.removeFromSuperview()
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            completion?()
        }
    }
    
    // MARK: - SwiftUI-style View Transitions
    
    /// Fade in with scale animation (for SwiftUI views)
    func fadeInScale(_ view: UIView, delay: TimeInterval = 0, duration: TimeInterval = 0.3) {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    /// Fade out with scale animation (for SwiftUI views)
    func fadeOutScale(_ view: UIView, delay: TimeInterval = 0, duration: TimeInterval = 0.25, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [.curveEaseIn]
        ) {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            completion?()
        }
    }
    
    // MARK: - Hero/Scale Transitions (for detail views)
    
    /// Scale up transition for detail views
    func heroScaleIn(_ view: UIView, from rect: CGRect, delay: TimeInterval = 0) {
        view.frame = rect
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        if let superview = view.superview {
            superview.bringSubviewToFront(view)
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: delay,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.6,
            options: []
        ) {
            view.alpha = 1
            view.transform = .identity
        }
    }
    
    /// Scale down transition for detail views
    func heroScaleOut(_ view: UIView, to rect: CGRect, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.4,
            options: [.curveEaseIn]
        ) {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            view.frame = rect
            completion?()
        }
    }
}

// MARK: - UIViewController Extension for Easy Transitions

extension UIViewController {
    
    /// Push with modern spring animation
    func modernPush(_ viewController: UIViewController) {
        ModernTransitions.shared.animatePush(in: navigationController, to: viewController)
    }
    
    /// Pop with modern spring animation
    func modernPop() {
        ModernTransitions.shared.animatePop(in: navigationController)
    }
    
    /// Present modal with modern animation
    func modernPresent(_ viewController: UIViewController, withBlur: Bool = true) {
        ModernTransitions.shared.animateModalPresent(to: viewController, from: self, withBlur: withBlur)
    }
    
    /// Dismiss modal with modern animation
    func modernDismiss(completion: (() -> Void)? = nil) {
        ModernTransitions.shared.animateModalDismiss(from: self, completion: completion)
    }
}
