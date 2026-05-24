import UIKit

class AnimatedTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBarAppearance()
    }
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = Color.Theme.purple
        tabBar.unselectedItemTintColor = .gray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

extension AnimatedTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return true }
        
        // Se è lo stesso tab, ricarica ma senza animazione
        if index == selectedIndex {
            if let nav = viewController as? UINavigationController,
               let rootVC = nav.viewControllers.first {
                nav.popToRootViewController(animated: false)
            }
            return false
        }
        
        return true
    }
}
