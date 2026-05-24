//
//  PageViewController.swift
//  TaskGator
//
//  Created by NCT 24 on 02/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let menuChange = Notification.Name("menuChange")
    static let onboardingChange = Notification.Name("onboardingChange")

}

class PageViewController: UIPageViewController {

    var currentPage = 0
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["selectedMenu"] as? Int else { return }
        turnToPage(index: index)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .menuChange, object: nil)

        dataSource = self
        delegate = self
        
        self.turnToPage(index: 0)
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        if is_from_myservices{
            return [self.getViewController(withIdentifier: "innerServiceTabForEditService"),
                    self.getViewController(withIdentifier: "innerStarTabVC"),
                    self.getViewController(withIdentifier: "innerGalleryTabVC"),
            ]
        }
        else{
            return [self.getViewController(withIdentifier: "innerServiceTabVC"),
                    self.getViewController(withIdentifier: "innerUserTabVC"),
                    self.getViewController(withIdentifier: "innerStarTabVC"),
                    self.getViewController(withIdentifier: "innerGalleryTabVC"),
            ]
        }
    }()
    
    private func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "ServiceProviderDetail", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
}

extension PageViewController{
    
    func turnToPage(index: Int)
    {
        let controller = orderedViewControllers[index]
        var direction = UIPageViewControllerNavigationDirection.forward
        
        if let currentVC = viewControllers?.first {
            let currentIndex = orderedViewControllers.firstIndex(of: currentVC)!
            if currentIndex > index {
                direction = .reverse
            }
        }
        
        setViewControllers([controller], direction: direction, animated: true, completion: nil)
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension PageViewController : UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return orderedViewControllers[index-1]
            }
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index < orderedViewControllers.count - 1 {
                return orderedViewControllers[index + 1]
            }
        }
        return nil
    }
}

extension PageViewController : UIPageViewControllerDelegate
{
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        
        for (index,vc) in  orderedViewControllers.enumerated(){
            if pendingViewControllers.first == orderedViewControllers[index] {
                print("index: \(index), vc: \(vc)")
                NotificationCenter.default.post(name: .menuChange, object: ["Pagevc_index":index] as [String:Any])
                break
            }
        }
        

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if !completed {
            for (index,vc) in  orderedViewControllers.enumerated(){
                if previousViewControllers.first == orderedViewControllers[index] {
                    print("index: \(index), vc: \(vc)")
                    NotificationCenter.default.post(name: .menuChange, object: ["Pagevc_index":index] as [String:Any])
                    break
                }
            }
        }
    }
}


