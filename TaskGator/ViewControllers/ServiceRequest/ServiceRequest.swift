//
//  ServiceRequest.swift
//  TaskGator
//
//  Created by NCT 24 on 07/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit

var selectedTab = 0

class ServiceRequest: NewBaseViewController {

    static var storyboardInstance:ServiceRequest? {
        return StoryBoard.serviceRequest.instantiateViewController(withIdentifier: ServiceRequest.identifier) as? ServiceRequest
    }
    
    @IBOutlet weak var greenStripe: UIView!
    @IBOutlet weak var btnCalender: UIButton!
    @IBOutlet weak var btnDispute: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    
    var isFromNotification: Bool = false
    
    deinit {
        selectedTab = 0
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    @IBAction func onClickCalender(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        animationOnView(center: sender.center)
        selectedTab = 1
        NotificationCenter.default.post(name: .serviceRequestMenuChange, object: ["selectedTab":selectedTab] as [String:Any])
            btnCalender.setTitleColor(Color.Theme.purple, for: .normal)
            btnDispute.setTitleColor(.black, for: .normal)
            btnHistory.setTitleColor(.black, for: .normal)

        
    }
    
    @IBAction func onClickDispute(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        animationOnView(center: sender.center)
        selectedTab = 0
        NotificationCenter.default.post(name: .serviceRequestMenuChange, object: ["selectedTab":selectedTab] as [String:Any])
    
            btnCalender.setTitleColor(.black, for: .normal)
            btnDispute.setTitleColor(Color.Theme.purple, for: .normal)
            btnHistory.setTitleColor(.black, for: .normal)

    }
    
    @IBAction func onClickHistory(_ sender: UIButton) {
        if self.greenStripe.center.x == sender.center.x {
            return
        }
        animationOnView(center: sender.center)
        selectedTab = 2
        NotificationCenter.default.post(name: .serviceRequestMenuChange, object: ["selectedTab":selectedTab] as [String:Any])
        
            btnCalender.setTitleColor(.black, for: .normal)
            btnDispute.setTitleColor(.black, for: .normal)
            btnHistory.setTitleColor(Color.Theme.purple, for: .normal)

    }
}

//MARK: Custom function
extension ServiceRequest {
    
    func setUpUI() {
        
//        setUpNavigation(vc: self, isBackButton: false, btnTitle: "", navigationTitle: "Service Request".localized, action: #selector(onClickMenu(_:)))
        
        self.setupNavigationBar(title: "Service Requests".localized, isBack: false, rightButton: false)
        self.applyStatusbar(color: Color.Theme.purple)

        btnDispute.setTitle("UPCOMING".localized, for: .normal)
        btnCalender.setTitle("ON GOING".localized, for: .normal)
        btnHistory.setTitle("PAST".localized, for: .normal)
        //TODO: only listen the notification which fires from PageVCServiceRequest
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .serviceRequestMenuChange, object: nil)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        if isFromNotification {
            
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["PagevcService_index"] as? Int else { return }
        
        //selectedTab = index
        
        switch index {
        case 0:
            print("onClickCalender")
            onClickDispute(btnDispute)
        case 1:
            print("onClickDispute")
            onClickCalender(btnCalender)
        case 2:
            print("onClickHistory")
            onClickHistory(btnHistory)
        default:
            break
        }
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        
//        switch selectedTab {
//        case 0:
//            btnCalender.setTitleColor(Color.Theme.orange, for: .normal)
//            btnDispute.setTitleColor(.black, for: .normal)
//            btnHistory.setTitleColor(.black, for: .normal)
////            btnCalender.setImage(#imageLiteral(resourceName: "tab_calender"), for: .normal)
//        case 1:
//            btnCalender.setTitleColor(.black, for: .normal)
//            btnDispute.setTitleColor(Color.Theme.orange, for: .normal)
//            btnHistory.setTitleColor(.black, for: .normal)
////            btnDispute.setImage(#imageLiteral(resourceName: "ic_ongoing"), for: .normal)
//        case 2:
//            btnCalender.setTitleColor(.black, for: .normal)
//            btnDispute.setTitleColor(.black, for: .normal)
//            btnHistory.setTitleColor(Color.Theme.orange, for: .normal)
////            btnHistory.setImage(#imageLiteral(resourceName: "tab_clock"), for: .normal)
//        default:
//            break
//        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.greenStripe.center.x = point.x
        }, completion: nil)
        
    }
    
}
