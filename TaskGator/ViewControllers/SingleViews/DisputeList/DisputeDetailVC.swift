//
//  DisputeDetailVC.swift
//  TaskGator
//
//  Created by NCT 24 on 10/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import Photos

protocol DisputeDetailDelegate {
    func refreshDisputeList()
}

extension Notification.Name {
    static let canCallDisputeList = Notification.Name("canCallDisputeList")
}

class DisputeDetailVC: NewBaseViewController {
    
    //MARK: Properties
    
    static var storyboardInstance:DisputeDetailVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: DisputeDetailVC.identifier) as? DisputeDetailVC
    }
    
    //var disputeId:String?
    var disputeObj:Dispute?
    
    var disputeMsgObj:DisputeMsgCls?
    
    var disputeMsgList = [DisputeMsg]()
    
    var delegate:DisputeDetailDelegate?
    
    //@IBOutlet weak var btnAcceptHeight: NSLayoutConstraint!//32
    
    //@IBOutlet weak var btnAcceptTop: NSLayoutConstraint!//12
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblValSubject: UILabel!
    @IBOutlet weak var lblRaisedBy: UILabel!
    @IBOutlet weak var lblValRaisedBy: UILabel!
    
    @IBOutlet weak var btnAccept: UIButton!{
        didSet{
            btnAccept.underline()
        }
    }
    
    @IBOutlet weak var btnEscalate: UIButton!{
        didSet{
            btnEscalate.underline()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(ChatCell.nib, forCellReuseIdentifier: ChatCell.identifier)
            tableView.register(ChatReceiveCell.nib, forCellReuseIdentifier: ChatReceiveCell.identifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.placeholder = "Type a message here*".localized
            textView.border(side: .all, color: Color.grey.deviderColor, borderWidth: 1.0)
        }
    }
    @IBOutlet weak var btnAttachement: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var selectedUserImage:UIImage?
    var pickedImageName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        callDisputeDetailsAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
        
        //MARK: Attchment code is here
        AttachmentHandler.shared.imagePickedBlock = { (image, imageName) in
            /* get your image here */
            self.pickedImageName = imageName
            self.textView.isUserInteractionEnabled = false
            self.textView.text = ""
            self.textView.text = imageName
            self.textView.resetPlaceHolder()
            self.selectedUserImage = image
            
            let imageCropper = ImageCropper.storyboardInstance
            imageCropper.delegate = self
            imageCropper.image = image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.present(imageCropper, animated: false, completion: nil)
            }
        }
    }
    
    func setLang(){
        if let disputeObj = self.disputeObj, disputeObj.created_user == UserData.shared.getUser()!.user_id{
            btnAccept.setTitle("CANCEL DISPUTE".localized, for: .normal)
        }else{
            btnAccept.setTitle("ACCEPT DISPUTE".localized, for: .normal)
        }
        btnAccept.underline()
        lblSubject.text = "Subject : ".localized
        lblRaisedBy.text = "Raised By : ".localized
        btnEscalate.setTitle("ESCALATE TO ADMIN".localized, for: .normal)
        lblBottom.text = "Dispute has been escalated to admin".localized
    }
    
    @IBAction func onClickAttachements(_ sender: UIButton) {
        //        pickImage()
        AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self)
        
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        if !(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            callSendMsgAPI()
        }else{
            let alert = UIAlertController(title: "Error".localized, message: "Please enter a message".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        callAcceptdisputeAPI()
    }
    
    @IBAction func onClickEscalate(_ sender: UIButton) {
        callEscalatetoadminAPI()
    }
    
}

//MARK: Custom function
extension DisputeDetailVC {
    
    func callSendMsgAPI() {
        let param = [
            "dispute_id":disputeMsgObj!.dispute_id,
            "message_text":textView.text!,
            "user_id":UserData.shared.getUser()!.user_id
            //attachment:
        ]
        Modal.shared.sendDisputeMessage(vc: self, param: param, postImage: nil, imageName: nil) { (dic) in
            print(dic)
            self.textView.text = nil
            
            let message = DisputeMsg(dictionary:(ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)))
            self.disputeMsgList.insert(message, at: 0)
            self.textView.isUserInteractionEnabled = true
            
            self.tableView.beginUpdates()
            
            let indexPath:IndexPath = IndexPath(row:0, section:0)
            self.tableView.insertRows(at: [indexPath], with: .top)
            self.tableView.endUpdates()
            
            self.delegate?.refreshDisputeList()
            //            NotificationCenter.default.post(name: .canCallDisputeList, object: ["canCallDisputeList":true] as [String:Any])
        }
    }
    
    func scrollToLastRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func isHideMsgView(isHide:Bool = true) {
        lblBottom.isHidden = !isHide
        textView.isHidden = isHide
        btnAttachement.isHidden = isHide
        btnSend.isHidden = isHide
        textViewHeight.constant = ( isHide ? 0.0 : 60.0 )
        
        textViewHeight.constant = 30.0
        //btnAcceptTop.constant = 0.0
        //btnAcceptHeight.constant = 0.0
        btnAccept.isHidden = isHide
        btnEscalate.isHidden = isHide
        
        self.view.layoutIfNeeded()
    }
    
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Dispute Detail".localized, action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: "Resolution Detail".localized, isBack: true, rightButton: false)
        
        
        lblBottom.isHidden = true
        if let disputeObj = self.disputeObj{
            lblValSubject.text = disputeObj.dispute_title
            if Modal.sharedAppdelegate.isCustomerLogin {
                if disputeObj.created_user == UserData.shared.getUser()!.user_id{
                    lblValRaisedBy.text = disputeObj.customer_firstname + " " + disputeObj.customer_lastname
                }
                else{
                    lblValRaisedBy.text = disputeObj.provider_firstname + " " + disputeObj.provider_lastname
                }
            }
            else {//Provider login
                if disputeObj.created_user == UserData.shared.getUser()!.user_id{
                    lblValRaisedBy.text = disputeObj.provider_firstname + " " + disputeObj.provider_lastname
                }
                else{
                    lblValRaisedBy.text = disputeObj.customer_firstname + " " + disputeObj.customer_lastname
                }
            }
        }
        else{
            lblValSubject.text = ""
            lblValRaisedBy.text = ""
        }
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func callDisputeDetailsAPI() {
        if let disputeObj = self.disputeObj{
            let nextPage = (disputeMsgObj?.pagination?.currentPage ?? 0 ) + 1
            var param:[String:Any] = ["dispute_id":disputeObj.dispute_id,"page":nextPage]
            if nextPage > 1 {
                param["last_message_id"] = self.disputeMsgList.last?.message_id
            }
            Modal.shared.getDisputedetails(vc: self, param: param) { (dic) in
                
                self.disputeMsgObj = DisputeMsgCls(dictionary: dic)
                if self.disputeMsgList.count > 0{
                    self.disputeMsgList += self.disputeMsgObj!.disputeMsgList
                }
                else
                {
                    self.disputeMsgList = self.disputeMsgObj!.disputeMsgList
                }
                self.tableView.reloadData()
                //                               if self.disputeMsgObj?.isactive.lowercased() == "du" {
                //                                   self.messageStackView.isHidden = true
                //                               }
                
                if self.disputeMsgObj!.escalate_admin == "y"{
                    self.isHideMsgView()
                }
                else if self.disputeMsgObj!.dispute_create_userid == UserData.shared.getUser()?.user_id {
                    self.btnAccept.isHidden = true
                    self.btnEscalate.isHidden = true
                }
            }
        }
    }
    
    func callAcceptdisputeAPI() {
        if let disputeObj = self.disputeMsgObj{
            let param = [
                "user_id":UserData.shared.getUser()!.user_id,
                "service_id":disputeObj.service_request_id
            ]
            Modal.shared.acceptDispute(vc: self, param: param) { (dic) in
                print(dic)
                //                NotificationCenter.default.post(name: .canCallDisputeList, object: ["canCallDisputeList":true] as [String:Any])
                self.delegate?.refreshDisputeList()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func callEscalatetoadminAPI() {
        if let disputeObj = self.disputeMsgObj{
            let param = [
                "user_id":UserData.shared.getUser()!.user_id,
                "service_id":disputeObj.service_request_id
            ]
            Modal.shared.escalatetoadmin(vc: self, param: param) { (dic) in
                print(dic)
                //                NotificationCenter.default.post(name: .canCallDisputeList, object: ["canCallDisputeList":true] as [String:Any])
                self.delegate?.refreshDisputeList()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

extension DisputeDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        reloadMoreData(indexPath: indexPath)
        if disputeMsgList[indexPath.row].created_user == UserData.shared.getUser()!.user_id{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier) as? ChatCell else {
                fatalError("Cell can't be dequeue")
            }
            //cell.isReceiver = false
            cell.disputeMsgObj = self.disputeMsgObj
            cell.cellData = disputeMsgList[indexPath.row]
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatReceiveCell.identifier) as? ChatReceiveCell else {
                fatalError("Cell can't be dequeue")
            }
            //cell.isReceiver = true
            cell.disputeMsgObj = self.disputeMsgObj
            cell.cellData = disputeMsgList[indexPath.row]
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disputeMsgList.count
    }
    
 
    func reloadMoreData(indexPath: IndexPath) {
        if disputeMsgList.count > 0 {
            if disputeMsgList.count - 1 == indexPath.row &&
                (disputeMsgObj!.pagination!.currentPage < disputeMsgObj!.pagination!.total_pages) {
                self.callDisputeDetailsAPI()
            }
        }
    }
    
}

//MARK: ImageCropper Class
extension DisputeDetailVC: ImageCropperDelegate{
    
    func didCropImage(originalImage: UIImage, cropImage: UIImage) {
        //        self.selectedUserImage = cropImage
        self.selectedUserImage = cropImage.resizedImageWith(targetSize: CGSize(width: 800, height: 800))  ?? cropImage
        
    }
    
    func didCancel() {
        print("Cancel Crop Image")
        self.selectedUserImage = nil
        self.textView.text = ""
    }
    
}

