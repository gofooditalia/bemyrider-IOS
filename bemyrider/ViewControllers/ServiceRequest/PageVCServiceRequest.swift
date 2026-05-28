//
//  PageVCServiceRequest.swift
//  bemyrider
//
//  Created by NCT 24 on 08/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let serviceRequestMenuChange = Notification.Name("serviceRequestMenuChange")
}

class PageVCServiceRequest: UIPageViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .serviceRequestMenuChange, object: nil)
        dataSource = self
        delegate = self
        self.turnToPage(index: 0)
    }

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.getViewController(withIdentifier: "ServiceRequestTableVC"),
                self.getViewController(withIdentifier: "ServiceRequestTableVC"),
                self.getViewController(withIdentifier: "ServiceRequestTableVC"),
                ]
    }()

    private func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "ServiceRequest", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

extension PageVCServiceRequest{

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

extension PageVCServiceRequest : UIPageViewControllerDataSource
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

extension PageVCServiceRequest : UIPageViewControllerDelegate
{
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        for (index,vc) in  orderedViewControllers.enumerated(){
            if pendingViewControllers.first == orderedViewControllers[index] {
                print("index: \(index), vc: \(vc)")
                NotificationCenter.default.post(name: .serviceRequestMenuChange, object: ["PagevcService_index":index] as [String:Any])
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
                    NotificationCenter.default.post(name: .serviceRequestMenuChange, object: ["PagevcService_index":index] as [String:Any])
                    break
                }
            }
        }
    }
}
