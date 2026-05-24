////
////  SendInviteVC.swift
////  TaskGator
////
////  Created by NCT 24 on 20/04/18.
////  Copyright © 2018 NCT 24. All rights reserved.
////
//

import UIKit

//import HTagView
//import SkyFloatingLabelTextField
//

class SendInviteVC: NewBaseViewController{ //BaseViewController {
//
//    //MARK: Properties
//
//    static var storyboardInstance:SendInviteVC? {
//        return StoryBoard.singleViews.instantiateViewController(withIdentifier: SendInviteVC.identifier) as? SendInviteVC
//    }
//
//    @IBOutlet weak var txtAddEmail: SkyFloatingLabelTextField!
//    @IBOutlet weak var txtMsg: SkyFloatingLabelTextField!
//
//    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var constScrollViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var hTagScrollview: UIScrollView!{
//        didSet{
//            hTagScrollview.isScrollEnabled = false
//            hTagScrollview.showsVerticalScrollIndicator = false
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpUI()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        constScrollViewHeight.constant = tagView1.bounds.height
//    }
//
//    @IBAction func onClickAdd(_ sender: UIButton){
//        if !(txtAddEmail.text?.isEmpty)!, (txtAddEmail.text?.isValidEmailId)! {
//            tagView1_data.append(txtAddEmail.text!)
//            constScrollViewHeight.constant = tagView1.bounds.height
//            containerView.setNeedsLayout()
//            containerView.layoutIfNeeded()
//            reloadHTagView()
//            txtAddEmail.text = nil
//        }else{
//            self.alert(title: "Error", message: "email Id is not valid!")
//        }
//
//        //containerView.layoutSubviews()
//    }
//
//    @IBAction func onClickSendInvites(_ sender: UIButton) {
//        callSendInvitesAPI()
//    }
//
//
//    @IBOutlet weak var tagView1: HTagView!{
//        didSet{
//            tagView1.delegate = self
//            tagView1.dataSource = self
//
//            tagView1.multiselect = false
//            tagView1.marg = 20
//            tagView1.btwTags = 12
//            tagView1.btwLines = 18
//            tagView1.tagFont = RobotoFont.regular(with: 21)
//            tagView1.tagSecondBackColor = Color.Black.secondaryColor
//            tagView1.tagSecondTextColor = Color.white
//            tagView1.tagBorderColor = Color.grey.lightText.cgColor
//            tagView1.tagContentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//            tagView1.tagCornerRadiusToHeightRatio = 0.5
//            //            tagView1.tagCancelIconRightMargin
//            //tagView1.selectTagAtIndex(3)
//        }
//    }
//
//    var tagView1_data = [String]()
//
//
}
//
////MARK: Custom function
//extension SendInviteVC {
//
//    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Invite Friends", action: #selector(onClickMenu(_:)))
//
//        print(tagView1.frame.height)
//
//    }
//
//    @objc func onClickMenu(_ sender: UIButton){
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    func callSendInvitesAPI() {
//        var para = ["user_id":UserData.shared.getUser()!.user_id, "email":tagView1_data.joined(separator: ","),]
//        if !(txtMsg.text?.isEmpty)!{
//            para["message"] = txtMsg.text!
//        }
//        Modal.shared.inviteFriends(vc: self, param: para) { (dic) in
//            print(dic)
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//}
//
//extension SendInviteVC: HTagViewDelegate, HTagViewDataSource{
//    // MARK: - HTagViewDataSource
//    func numberOfTags(_ tagView: HTagView) -> Int {
//        return tagView1_data.count
//    }
//
//    func tagView(_ tagView: HTagView, titleOfTagAtIndex index: Int) -> String {
//        return tagView1_data[index]
//    }
//
//    func tagView(_ tagView: HTagView, tagTypeAtIndex index: Int) -> HTagType {
//        return .cancel
//    }
//
//    func tagView(_ tagView: HTagView, tagWidthAtIndex index: Int) -> CGFloat {
//        return .HTagAutoWidth
//    }
//
//    // MARK: - HTagViewDelegate
//    func tagView(_ tagView: HTagView, tagSelectionDidChange selectedIndices: [Int]) {
//        print("tag with indices \(selectedIndices) are selected")
//    }
//
//    func tagView(_ tagView: HTagView, didCancelTagAtIndex index: Int) {
//        print("tag with index: '\(index)' has to be removed from tagView")
//        tagView1_data.remove(at: index)
//        reloadHTagView()
//    }
//
//    func reloadHTagView() {
//        tagView1.reloadData()
//        constScrollViewHeight.constant = tagView1.bounds.height
//    }
//}
