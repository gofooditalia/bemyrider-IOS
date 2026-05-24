//
//  CategoryDetaliPageVC.swift
//  TaskGator
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit
extension Notification.Name {
    static let categoryDetailMenuChange = Notification.Name("categoryDetailMenuChange")
}

class CategoryDetaliPageVC: UIPageViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .categoryDetailMenuChange, object: nil)
        
        dataSource = self
        delegate = self
        
        self.turnToPage(index: 0)
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.getViewController(withIdentifier: "CategoryServicesVC"),
                self.getViewController(withIdentifier: "CategoryTaskerVC")
        ]
    }()
    
    private func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
}

extension CategoryDetaliPageVC{
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["selectedTab"] as? Int else { return }
        turnToPage(index: index)
    }
    
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

extension CategoryDetaliPageVC : UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return orderedViewControllers[index-1]
            }
        }
        return nil//controllers.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index < orderedViewControllers.count - 1 {
                return orderedViewControllers[index + 1]
            }
        }
        return nil //controllers.first
    }
}

extension CategoryDetaliPageVC : UIPageViewControllerDelegate
{
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        for (index,vc) in  orderedViewControllers.enumerated(){
            if pendingViewControllers.first == orderedViewControllers[index] {
                print("index: \(index), vc: \(vc)")
                NotificationCenter.default.post(name: .categoryDetailMenuChange, object: ["PagevcService_index":index] as [String:Any])
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
                    NotificationCenter.default.post(name: .categoryDetailMenuChange, object: ["PagevcService_index":index] as [String:Any])
                    break
                }
            }
        }
    }
}
