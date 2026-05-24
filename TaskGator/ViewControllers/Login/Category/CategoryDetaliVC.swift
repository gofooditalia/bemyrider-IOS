//
//  CategoryDetaliVC.swift
//  TaskGator
//
//  Created by admin on 8/19/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit

var newDeliveryProvider:DeliveryProivderList?

class CategoryDetaliVC: NewBaseViewController {

    static var storyboardInstance:CategoryDetaliVC? {
        return StoryBoard.main.instantiateViewController(withIdentifier: CategoryDetaliVC.identifier) as? CategoryDetaliVC
    }
    deinit {
        selectedTab = 0
        NotificationCenter.default.removeObserver(self)
    }
    @IBOutlet weak var btnService: UIButton!{
        didSet{
            DispatchQueue.main.async {
                self.btnService.border(side: .bottom, color: Color.green.theam, borderWidth: 2)
                self.btnService.border(side: .right, color: Color.darkGray, borderWidth: 2)
            }
        }
    }
    @IBOutlet weak var btnTasker: UIButton!{
        didSet{
            DispatchQueue.main.async {
                self.btnTasker.border(side: .bottom, color: Color.darkGray, borderWidth: 2)
            }
        }
    }
    
    var subCategory:Category?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    @IBAction func onClickServices(_ sender: UIButton) {
        selectedTab = 0
        animationOnView(center: sender.center)
        NotificationCenter.default.post(name: .categoryDetailMenuChange, object: ["selectedTab":selectedTab] as [String:Any])
    }
    @IBAction func onClickTaskers(_ sender: UIButton) {
        selectedTab = 1
        animationOnView(center: sender.center)
        NotificationCenter.default.post(name: .categoryDetailMenuChange, object: ["selectedTab":selectedTab] as [String:Any])
    }
    

}
//MARK: Custom function
extension CategoryDetaliVC {
    
    func setUpUI() {
        
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: subCategory?.category_name ?? "", action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
             self.setupNavigationBar(title: subCategory?.category_name ?? "", isBack: true, rightButton: false)
        
        //TODO: only listen the notification which fires from PageVCServiceRequest
        NotificationCenter.default.addObserver(self, selector: #selector(menuChange(notification:)), name: .categoryDetailMenuChange, object: nil)
        
    }
    func setLang(){
        btnService.setTitle("SERVICES".localized, for: .normal)
        btnTasker.setTitle("TASKERS".localized, for: .normal)
        
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func menuChange(notification: Notification) {
        let data = notification.object as! [String: Any]
        guard let index = data["PagevcService_index"] as? Int else { return }
        
        //selectedTab = index
        
        switch index {
        case 0:
            print("onClickServices")
            onClickServices(btnService)
        case 1:
            print("onClickDispute")
            onClickTaskers(btnTasker)
        default:
            break
        }
        
    }
    
    func animationOnView(center point:CGPoint,vcWithIdentifier id:String = "") {
        
        switch selectedTab {
        case 0:
            btnService.isSelected = true
            btnTasker.isSelected = false
            btnService.border(side: .bottom, color: Color.green.theam, borderWidth: 2)
            btnTasker.border(side: .bottom, color: Color.darkGray, borderWidth: 2)
        case 1:
            btnService.isSelected = false
            btnTasker.isSelected = true
            btnTasker.border(side: .bottom, color: Color.green.theam, borderWidth: 2)
            btnService.border(side: .bottom, color: Color.darkGray, borderWidth: 2)
        default:
            break
        }
        
    }
    
}
