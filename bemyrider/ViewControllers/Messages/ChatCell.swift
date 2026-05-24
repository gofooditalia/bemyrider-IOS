//
//  ChatCell.swift
//  bemyrider
//
//  Created by NCT 24 on 26/04/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SafariServices

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var lblProviderName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnViewAttach: UIButton!{
        didSet{
            btnViewAttach.underline()
        }
    }
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!{
        didSet{
            imgUser.setRadius(color: Color.grey.lightDeviderColor)
        }
    }
    
    @IBOutlet weak var btnAttachmentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnAttachmnetTop: NSLayoutConstraint!
    @IBOutlet weak var btnAttachmnetBottom: NSLayoutConstraint!
    
    var indexPath: IndexPath!
    
    var isReceiver : Bool = false {
        didSet{
            changeImage()
        }
    }
    
    var disputeMsgObj:DisputeMsgCls?

    
    var cellData: DisputeMsg? {
        didSet{
            loadData()
        }
    }
    
    var chatCellData: Message?{
        didSet{
            loadMsgs()
        }
    }
    
    var messageObj:MessageCls?

    
    func loadMsgs() {
        if let chatCellData = self.chatCellData{
            //sender
            if chatCellData.from_user == UserData.shared.getUser()!.user_id{
                imgUser.downLoadImage(url: messageObj!.my_profile_img)
                lblProviderName.text = messageObj!.my_user_name
            }
            //receiver
            else{
                imgUser.downLoadImage(url: messageObj!.to_profile_img)
                lblProviderName.text = messageObj!.to_user_name
            }
            lblMessage.text = chatCellData.message_text.strippingHTML()
            lblDate.text = chatCellData.created_date
            
            //View attachment
            if chatCellData.appAttUrl.isEmpty{
                btnAttachmnetTop.constant = 0.0
                btnAttachmnetBottom.constant = 0.0
                btnAttachmentHeight.constant = 0.0
                btnViewAttach.isHidden = true
            }
            else{
                btnAttachmnetTop.constant = 8.0
                btnAttachmnetBottom.constant = 8.0
                btnAttachmentHeight.constant = 20.0
                btnViewAttach.isHidden = false
            }
        }
        else{
            lblMessage.text = ""
            lblDate.text = ""
            lblProviderName.text = ""
        }
    }
    
    
    func loadData() {
        if let cellData = self.cellData{
            if cellData.created_user_type == "c"{
                imgUser.downLoadImage(url: disputeMsgObj!.customer_image)
                lblProviderName.text = disputeMsgObj!.customer_firstname + " " + disputeMsgObj!.customer_lastname
            }
            else{
                imgUser.downLoadImage(url: disputeMsgObj!.provider_image)
                lblProviderName.text = disputeMsgObj!.provider_firstname + " " + disputeMsgObj!.provider_lastname
            }
            lblMessage.text = cellData.dispute_message
            lblDate.text = cellData.createdDate
            
            //View attachment
            if cellData.downloadUrl.isEmpty{
                btnAttachmnetTop.constant = 0.0
                btnAttachmnetBottom.constant = 0.0
                btnAttachmentHeight.constant = 0.0
                btnViewAttach.isHidden = true
            }
            else{
                btnAttachmnetTop.constant = 8.0
                btnAttachmnetBottom.constant = 8.0
                btnAttachmentHeight.constant = 20.0
                btnViewAttach.isHidden = false
            }
        }
        else{
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeImage() {
        bubbleImageView.image = ( isReceiver ? #imageLiteral(resourceName: "ic_background_left") : #imageLiteral(resourceName: "ic_background_right"))
            .resizableImage(withCapInsets:
                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                            resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
    }
    
    @IBAction func onClickAttachment(_ sender: UIButton) {
        if let cellData = self.cellData{
            if !(cellData.appAttUrl.isEmpty),let url = URL(string: cellData.appAttUrl){
                DispatchQueue.main.async {
                    let vc = SFSafariViewController(url: url, configuration: .init())
                    vc.delegate = self
                    self.viewController?.present(vc, animated: true, completion: nil)
                }
            }
        }
        //For char messages attachments
        else if let chatCellData = self.chatCellData{
            if !(chatCellData.appAttUrl.isEmpty),let url = URL(string: chatCellData.appAttUrl){
                DispatchQueue.main.async {
                    let vc = SFSafariViewController(url: url, configuration: .init())
                    vc.delegate = self
                    self.viewController?.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension ChatCell:SFSafariViewControllerDelegate {
    
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true, completion: nil)
        }

}
