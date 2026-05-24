//
//  ModernLoader.swift
//  bemyrider
//
//  Created by Kilo Code - Modern Loading Indicator
//

import UIKit

class ModernLoader {

    static let shared = ModernLoader()
    
    private var containerView: UIView?
    private var loaderView: UIView?
    private let containerTag = 987654
    private let loaderTag = 987655
    
    private init() {}
    
    // MARK: - Show Loader
    func show(in view: UIView, message: String = "") {
        hide() // Remove any existing loader first
        
        // Container with blur effect
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        container.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        container.center = view.center
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        container.tag = containerTag
        
        // Make it center in view
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 120),
            container.heightAnchor.constraint(equalToConstant: 120),
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Custom animated loader
        let loaderContainer = UIView()
        loaderContainer.tag = loaderTag
        container.contentView.addSubview(loaderContainer)
        loaderContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loaderContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loaderContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -10),
            loaderContainer.widthAnchor.constraint(equalToConstant: 50),
            loaderContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Create three animated circles
        let circles = createAnimatedCircles()
        for (index, circle) in circles.enumerated() {
            loaderContainer.addSubview(circle)
            circle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                circle.widthAnchor.constraint(equalToConstant: 12),
                circle.heightAnchor.constraint(equalToConstant: 12),
                circle.centerYAnchor.constraint(equalTo: loaderContainer.centerYAnchor)
            ])
            
            if index == 0 {
                circle.centerXAnchor.constraint(equalTo: loaderContainer.leadingAnchor).isActive = true
            } else if index == 1 {
                circle.centerXAnchor.constraint(equalTo: loaderContainer.centerXAnchor).isActive = true
            } else {
                circle.centerXAnchor.constraint(equalTo: loaderContainer.trailingAnchor).isActive = true
            }
            
            // Animate
            animateCircle(circle, delay: Double(index) * 0.15)
        }
        
        // Message label (optional)
        if !message.isEmpty {
            let label = UILabel()
            label.text = message
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            container.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: loaderContainer.bottomAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
            ])
        }
        
        // Scale in animation
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        container.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            container.transform = .identity
            container.alpha = 1
        }
        
        self.containerView = container
    }
    
    // MARK: - Hide Loader
    func hide() {
        guard let container = containerView ?? UIApplication.shared.windows.first?.viewWithTag(containerTag) else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            container.alpha = 0
        }) { _ in
            container.removeFromSuperview()
        }
        
        containerView = nil
    }
    
    // MARK: - Helper Methods
    private func createAnimatedCircles() -> [UIView] {
        var circles: [UIView] = []
        for _ in 0..<3 {
            let circle = UIView()
            circle.backgroundColor = Color.Theme.purple
            circle.layer.cornerRadius = 6
            circles.append(circle)
        }
        return circles
    }
    
    private func animateCircle(_ circle: UIView, delay: TimeInterval) {
        UIView.animate(
            withDuration: 0.6,
            delay: delay,
            options: [.repeat, .autoreverse],
            animations: {
                circle.alpha = 0.3
                circle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }
        )
    }
}

// MARK: - Window Extension for Easy Access
extension ModernLoader {
    
    static func show(message: String = "") {
        guard let window = UIApplication.shared.windows.first else { return }
        ModernLoader.shared.show(in: window, message: message)
    }
    
    static func hide() {
        ModernLoader.shared.hide()
    }
}

// MARK: - Alternative: Pulsing Dots Loader
class PulsingDotLoader {
    
    private let containerTag = 555666
    private var animationLayers: [CALayer] = []
    
    func show(in view: UIView) {
        hide(in: view)
        
        let container = UIView()
        container.tag = containerTag
        container.backgroundColor = .clear
        
        let dotSize: CGFloat = 14
        let spacing: CGFloat = 8
        let totalWidth = dotSize * 3 + spacing * 2
        container.frame = CGRect(x: 0, y: 0, width: totalWidth, height: dotSize)
        container.center = view.center
        
        for i in 0..<3 {
            let dot = CALayer()
            dot.frame = CGRect(x: CGFloat(i) * (dotSize + spacing), y: 0, width: dotSize, height: dotSize)
            dot.cornerRadius = dotSize / 2
            dot.backgroundColor = Color.Theme.purple.cgColor
            container.layer.addSublayer(dot)
            animationLayers.append(dot)
            
            // Pulsing animation
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.fromValue = 1.0
            animation.toValue = 0.5
            animation.duration = 0.5
            animation.beginTime = CACurrentMediaTime() + Double(i) * 0.15
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            dot.add(animation, forKey: "pulse")
        }
        
        view.addSubview(container)
        
        // Fade in
        container.alpha = 0
        UIView.animate(withDuration: 0.2) {
            container.alpha = 1
        }
    }
    
    func hide(in view: UIView) {
        if let container = view.viewWithTag(containerTag) {
            UIView.animate(withDuration: 0.2, animations: {
                container.alpha = 0
            }) { _ in
                container.removeFromSuperview()
            }
        }
        animationLayers.removeAll()
    }
}
