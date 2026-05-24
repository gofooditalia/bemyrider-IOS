//
//  ProviderSideServicePageVC.swift
//  TaskGator
//
//  Created by NCT 24 on 11/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

class ProviderSideServicePageVC: UIPageViewController {

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
        if let providerSide_ProviderDetails = providerSide_ProviderDetails,
            providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.completed.rawValue){
            return [self.getViewController(withIdentifier: "ProviderSrvsReqRecent"),
                    self.getViewController(withIdentifier: "InnerInvoiceTabVC"),
            ]
        }
        else{
            return [self.getViewController(withIdentifier: "ProviderSrvsReqRecent"),]
        }
    }()

    private func getViewController(withIdentifier identifier: String) -> UIViewController
    {
        return UIStoryboard(name: "ProviderSideServiceDetails", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

extension ProviderSideServicePageVC{

    func turnToPage(index: Int){
        if orderedViewControllers.count > 0{
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
}

// MARK: - UIPageViewControllerDataSource

extension ProviderSideServicePageVC : UIPageViewControllerDataSource
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

extension ProviderSideServicePageVC : UIPageViewControllerDelegate
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
