import UIKit

// MARK: - UI Effects Manager

final class Effects {
    
    // MARK: - Button Tap Animation
    
    static func addTapAnimation(to view: UIView, completion: (() -> Void)? = nil) {
        view.isUserInteractionEnabled = true
        view.tag = view.tag == 0 ? 1000 : view.tag
        
        let tap = UITapGestureRecognizer(target: Effects.self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        if let completion = completion {
            objc_setAssociatedObject(view, &AssociatedKeys.completion, completion, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private static func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                view.transform = .identity
            } completion: { _ in
                if let completion = objc_getAssociatedObject(view, &AssociatedKeys.completion) as? () -> Void {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Pulse Animation
    
    static func pulse(_ view: UIView, scale: CGFloat = 1.1, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration / 2, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration / 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                view.transform = .identity
            }
        }
    }
    
    // MARK: - Shake Animation
    
    static func shake(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.duration = 0.5
        animation.values = [-10, 10, -8, 8, -5, 5, -2, 2, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
    // MARK: - Fade Animations
    
    static func fadeIn(_ view: UIView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        view.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }) { _ in
            completion?()
        }
    }
    
    static func fadeOut(_ view: UIView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    // MARK: - Slide Animations
    
    static func slideIn(from direction: SlideDirection, view: UIView, duration: TimeInterval = 0.4, completion: (() -> Void)? = nil) {
        let offset: CGAffineTransform
        switch direction {
        case .top:
            offset = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        case .bottom:
            offset = CGAffineTransform(translationX: 0, y: view.bounds.height)
        case .left:
            offset = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        case .right:
            offset = CGAffineTransform(translationX: view.bounds.width, y: 0)
        }
        
        view.transform = offset
        view.alpha = 0
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            view.transform = .identity
            view.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
    
    static func slideOut(to direction: SlideDirection, view: UIView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let offset: CGAffineTransform
        switch direction {
        case .top:
            offset = CGAffineTransform(translationX: 0, y: -view.bounds.height)
        case .bottom:
            offset = CGAffineTransform(translationX: 0, y: view.bounds.height)
        case .left:
            offset = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        case .right:
            offset = CGAffineTransform(translationX: view.bounds.width, y: 0)
        }
        
        UIView.animate(withDuration: duration, animations: {
            view.transform = offset
            view.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    // MARK: - Loading Spinner
    
    static func addLoadingSpinner(to view: UIView, color: UIColor = Color.Theme.purple) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.color = color
        spinner.frame = view.bounds
        spinner.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        spinner.startAnimating()
        view.addSubview(spinner)
        return spinner
    }
}

// MARK: - Supporting Types

enum SlideDirection {
    case top, bottom, left, right
}

private struct AssociatedKeys {
    static var completion = "tapCompletion"
}
