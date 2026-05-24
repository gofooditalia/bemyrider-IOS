import UIKit

class InteractivePopNavigationController: UINavigationController {
    
    var isPushingViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = true
        navigationBar.barStyle = UIBarStyle.black
        navigationBar.tintColor = Color.Theme.purple
        navigationBar.barTintColor = Color.Theme.purple
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font : RobotoFont.medium(with: 16),
                                             NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : RobotoFont.medium(with: 16),
                                                   NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Color.Theme.purple
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            navigationBarAppearance.backgroundColor = Color.Theme.purple
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.isHidden = true
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        isPushingViewController = true
        super.pushViewController(viewController, animated: animated)
    }
}

extension InteractivePopNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIScreenEdgePanGestureRecognizer else { return true }
        return viewControllers.count > 1 && !isPushingViewController
    }
}

extension InteractivePopNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isPushingViewController = false
    }
}
