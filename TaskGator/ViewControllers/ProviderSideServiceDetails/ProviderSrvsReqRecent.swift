//
//  ProviderSrvsReqRecent.swift
//  TaskGator
//
//  Created by NCT 24 on 10/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation

class ProviderSrvsReqRecent: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:ProviderSrvsReqRecent? {
        return StoryBoard.providerSideServiceDetails.instantiateViewController(withIdentifier: ProviderSrvsReqRecent.identifier) as? ProviderSrvsReqRecent
    }
    
    var pendingProposal: ProviderServicesCls.ProposalServiceData?
    
    //    @IBOutlet weak var imgUser: UIImageView!
    //    @IBOutlet weak var lblName: UILabel!
    //    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAdminFees: UILabel!
    @IBOutlet weak var lblPaymentPref: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblBookingDesc: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblServiceAddr: UILabel!
    @IBOutlet weak var lblContact: UILabel!
    @IBOutlet weak var lblDailyAvailability: UILabel!
    @IBOutlet weak var lblVehicleType: UILabel!
    @IBOutlet weak var lblHourlyAvailability: UILabel!
    
    @IBOutlet weak var lblValCategory: UILabel!
    @IBOutlet weak var lblValPrice: UILabel!
    @IBOutlet weak var lblValAdminFees: UILabel!
    @IBOutlet weak var lblValPaymentPref: UILabel!
    @IBOutlet weak var lblValStartTime: UILabel!
    @IBOutlet weak var lblValEndTime: UILabel!
    @IBOutlet weak var lblValBookingDesc: UILabel!
    @IBOutlet weak var lblValServiceDesc: UILabel!
    @IBOutlet weak var lblValServiceAddr: UILabel!
    @IBOutlet weak var lblValDailyAvailability: UILabel!
    @IBOutlet weak var lblValVehicleType: UILabel!
    @IBOutlet weak var lblValHourlyAvailability: UILabel!
    
    
    @IBOutlet weak var lblContactNum: UILabel!{
        didSet{
            lblContactNum.underline()
            lblContactNum.isUserInteractionEnabled = true
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickPhoneNumber(_:)))
            lblContactNum.addGestureRecognizer(tapGest)
        }
    }
    @IBOutlet weak var lblEmail: UILabel!{
        didSet{
            lblEmail.underline()
            lblEmail.isUserInteractionEnabled = true
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickEmail(_:)))
            lblEmail.addGestureRecognizer(tapGest)
        }
    }
    
    //@IBOutlet weak var stackViewPhoneNum: UIStackView!
    //@IBOutlet weak var stackViewEmail: UIStackView!
    @IBOutlet weak var stackViewProposalExtendService: UIStackView!
    @IBOutlet weak var stackViewContact: UIStackView!
    @IBOutlet weak var viewProposalMessages: UIView!
    @IBOutlet weak var viewExtendService: UIView!
    
    @IBOutlet weak var proposalMsgStackView: UIStackView!
    @IBOutlet weak var lblProposal: UILabel!
    @IBOutlet weak var lblProposalHours: UILabel!
    @IBOutlet weak var lblProposalMsgs: UILabel!
    @IBOutlet weak var lblProposalStatus: UILabel!
    @IBOutlet weak var proposalTableView: UITableView!{
        didSet{
            proposalTableView.register(ProposalMsgCell.nib, forCellReuseIdentifier: ProposalMsgCell.identifier)
            proposalTableView.dataSource = self
            proposalTableView.delegate = self
            proposalTableView.tableFooterView = UIView()
            proposalTableView.separatorStyle = .none
            proposalTableView.allowsSelection = false
        }
    }
    @IBOutlet weak var constProposalTableHeight: NSLayoutConstraint!
    var proposalServiceAry = [ProviderServicesCls.ProposalServiceData]()
    
    @IBOutlet weak var stackViewAcceptReject: UIStackView!{
        didSet{
            stackViewAcceptReject.isHidden = true
        }
    }
    
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.btnReject.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
            }
        }
    }
    
    @IBOutlet weak var btnAcceptForExtendServ: UIButton!
    @IBOutlet weak var btnRejectForExtendServ: UIButton!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.btnRejectForExtendServ.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var stackViewAccptRjctForExtendServ: UIStackView!
    
    @IBOutlet weak var lblExtendSerive: UILabel!
    @IBOutlet weak var lblExtendSeriveDuration: UILabel!
    @IBOutlet weak var lblExtendSeriveHours: UILabel!
    @IBOutlet weak var lblExtendSeriveCost: UILabel!
    @IBOutlet weak var lblExtendSeriveStatus: UILabel!
    @IBOutlet weak var btnOpenMap: UIButton!
    
    @IBOutlet weak var lblValExtendSeriveDuration: UILabel!
    @IBOutlet weak var lblValExtendSeriveHours: UILabel!
    @IBOutlet weak var lblValExtendSeriveCost: UILabel!
    @IBOutlet weak var lblValExtendSeriveStatus: UILabel!
    @IBOutlet weak var extendServiceStackView: UIStackView!
    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var spacingStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .reloadFirstServiceData, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
        setLang()
    }
    
    @objc func reloadData(){
        loadData()
    }
    
    @IBAction func onClickReject(_ sender: UIButton) {
        callAcceptedProposalAPI(isAccept: false)
        //        if let pendingProposal = pendingProposal{
        //            let parentVC = self
        //            guard let nextVC = ProposalPopUpVC.storyboardInstance else {return}
        //            nextVC.delegate = self
        //            nextVC.proposalId = pendingProposal.proposal_id
        //            nextVC.presentAsPopUp(parentVC: parentVC)
        //        }
    }
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        callAcceptedProposalAPI(isAccept: true)
    }
    
    @IBAction func onClickAcceptForExtendServ(_ sender: UIButton) {
        callExtenServiceAcceptRejectAPI(isAccept: true)
    }
    
    @IBAction func onClickRejectForExtendServ(_ sender: UIButton) {
        callExtenServiceAcceptRejectAPI(isAccept: false)
    }
    
    //    @IBAction func onClickSendMsg(_ sender: UIButton) {
    //    }
    //    @IBAction func onClickSRaiseDispute(_ sender: UIButton) {
    //    }
    
    @IBAction func onClickMap(_ sender: UIButton) {
        
        if let providerSide_ProviderDetails = providerSide_ProviderDetails {
            if !providerSide_ProviderDetails.service_latitude.isEmpty && providerSide_ProviderDetails.service_latitude != "0.0" {
//                UIApplication.shared.open(URL(string: "https://www.google.com/maps/@\(providerSide_ProviderDetails.service_latitude),\(providerSide_ProviderDetails.service_longitude)")!, options: [:], completionHandler: nil)
                if let urlDestination = URL(string: "https://www.google.com/maps/?daddr=\(providerSide_ProviderDetails.service_latitude),\(providerSide_ProviderDetails.service_longitude)&directionsmode=driving") {
                               UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
                           }
            }
        }
    }
    
    func openTrackerInBrowser(){
        if let latitude = providerSide_ProviderDetails?.service_latitude , let longitude = providerSide_ProviderDetails?.service_longitude {
            
            if let urlDestination = URL(string: "https://www.google.com/maps/?daddr=\(latitude),\(longitude)&directionsmode=driving") {
                UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
            }
        }
    }
}

//MARK: Custom function
extension ProviderSrvsReqRecent {
    func setLang(){
        lblCategory.text = "Category".localized
        lblPrice.text = "Rate".localized
        lblAdminFees.text = "Admin Fees".localized
        lblPaymentPref.text = "Payment Preference".localized
        lblStartTime.text = "Start Time".localized
        lblEndTime.text = "End Time".localized
        lblBookingDesc.text = "Booking Description".localized
        lblServiceDesc.text = "Vehicle Model and Equipment".localized
        lblServiceAddr.text = "Service Address".localized
        lblContact.text = "Contact".localized
        lblProposal.text = "Proposal Messages".localized
        lblProposalHours.text = "Hours".localized
        lblProposalMsgs.text = "Messages".localized
        lblProposalStatus.text = "    Status".localized
        btnAccept.setTitle("ACCEPT".localized, for: .normal)
        btnReject.setTitle("REJECT".localized, for: .normal)
        lblExtendSerive.text = "Extend Service Messages".localized
        lblExtendSeriveDuration.text = "Duration".localized
        lblExtendSeriveHours.text = "Hours".localized
        lblExtendSeriveCost.text = "Cost".localized
        lblExtendSeriveStatus.text = "Status".localized
        btnAcceptForExtendServ.setTitle("ACCEPT".localized, for: .normal)
        btnRejectForExtendServ.setTitle("REJECT".localized, for: .normal)
        
        lblDailyAvailability.text = "Daily availability".localized
        lblVehicleType.text = "Vehicle Type".localized
        lblHourlyAvailability.text = "Hourly availability".localized
        

    }
    
    func callAcceptedProposalAPI(isAccept:Bool) {
        if let pendingProposal = pendingProposal{
            let param = [
                "status_type": ( isAccept ? "accepted" : "rejected"),
                "proposal_id":pendingProposal.proposal_id,
                "user_id":UserData.shared.getUser()!.user_id
            ]
            Modal.shared.acceptProposal(vc: self, param: param) { (dic) in
                print(dic)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func callExtenServiceAcceptRejectAPI(isAccept:Bool) {
        if let providerSide_ProviderDetails = providerSide_ProviderDetails, providerSide_ProviderDetails.extend_service_data.count > 0{
            let param = ["status_type": (isAccept ? "accepted" : "rejected"),
                         "extend_id":providerSide_ProviderDetails.extend_service_data.first!.extend_id
            ]
            Modal.shared.acceptExtendservice(vc: self, param: param) { (dic) in
                print(dic)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setUpUI() {
        //setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Service Name", action: #selector(onClickMenu(_:)))
        //lblStatus.text?.addSpaceTrainlingAndLeading(spaceNum: 2)
    }
    
    //    @objc func onClickMenu(_ sender: UIButton){
    //        self.navigationController?.popViewController(animated: true)
    //    }
    
    func loadData() {
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            lblValCategory.text = providerSide_ProviderDetails.category_name
            lblValStartTime.text = providerSide_ProviderDetails.booking_start_time
            lblValEndTime.text = providerSide_ProviderDetails.booking_end_time
            lblValAdminFees.text = "\(UserData.shared.currency) \(providerSide_ProviderDetails.provider_commission_amount)"
            //lblValAdminCom.text = providerSide_ProviderDetails.customer_commission + "%"
            let paymentMode = providerSide_ProviderDetails.payment_mode.capitalizingFirstLetter()
            lblValPaymentPref.text = paymentMode.localized
            lblValBookingDesc.text = providerSide_ProviderDetails.booking_details
            lblValServiceDesc.text = providerSide_ProviderDetails.description
            lblValServiceAddr.text = providerSide_ProviderDetails.booking_address
            
            //TODO: service_type based on that $ 5 ($ 5/hour)
            if providerSide_ProviderDetails.service_type == "hourly"{
                lblValPrice.text = "\(UserData.shared.currency)\(providerSide_ProviderDetails.booking_amount) (\(UserData.shared.currency)\(providerSide_ProviderDetails.service_price) / \("Hour".localized))"
                //lblValTakeHours.text = providerSide_ProviderDetails.booking_hours + " Hours"
                //lblValPrice.text = "\(UserData.shared.currency) \(providerSide_ProviderDetails.booking_amount) (\(UserData.shared.currency) \(providerServiceDetail!.price)/hours)"
                //lblValServiceHours.text = providerServiceDetail!.hours + " Hours"
                //constTopOfTakeHours.constant = 12.0
                
                
            }
            else{//fixed
                //lblValServiceHours.text = providerSide_ProviderDetails.booking_hours + " Hours"
                lblValPrice.text = "\(UserData.shared.currency) \(providerSide_ProviderDetails.booking_amount)"
                //lblValTakeHours.isHidden = true
                //lblTakeHours.isHidden = true
                //constTopOfTakeHours.constant = 0.0
            }
            
            if providerSide_ProviderDetails.isactive.lowercased() != "du" {
                lblContactNum.text = providerSide_ProviderDetails.customer_contact_number
                lblEmail.text = providerSide_ProviderDetails.customer_email
                lblContactNum.underline()
                lblEmail.underline()
                setVisibleViews()
            }else{
                lblContactNum.isHidden = true
                lblEmail.isHidden = true
                lblContact.isHidden = true
                addressStackView.isHidden = true
                
                stackViewContact.isHidden = true
                btnOpenMap.isHidden = true
                viewExtendService.isHidden = true
                proposalMsgStackView.isHidden = true
                viewProposalMessages.isHidden = true
                stackViewAccptRjctForExtendServ.isHidden = true
                spacingStackView.spacing = 0
                spacingStackView.updateConstraints()
            }
            
            lblValVehicleType.text = providerSide_ProviderDetails.delivery_type.localized
            
            self.lblValDailyAvailability.text = providerSide_ProviderDetails.available_days_list.isEmpty ? "N/A" :  providerSide_ProviderDetails.available_days_list
            if !providerSide_ProviderDetails.available_time_start.isEmpty && !providerSide_ProviderDetails.available_time_end.isEmpty {
                self.lblValHourlyAvailability.text = providerSide_ProviderDetails.available_time_start + " - " + providerSide_ProviderDetails.available_time_end
            }else{
                self.lblValHourlyAvailability.text = "N/A"
            }
        }
        
    }
    
    func setVisibleViews() {
        viewExtendService.isHidden = true
        proposalMsgStackView.isHidden = true
        viewProposalMessages.isHidden = true
        stackViewContact.isHidden = true
        stackViewAccptRjctForExtendServ.isHidden = true
        spacingStackView.spacing = 0
        if let providerSide_ProviderDetails = providerSide_ProviderDetails{
            
            
            //Customer contact details(email-PhoneNum) display
            if providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.hired.rawValue) ||
                providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.completed.rawValue) ||
                providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.onGoing.rawValue){
                stackViewContact.isHidden = false
                spacingStackView.spacing = 12
            }
            
            let isExtendService = providerSide_ProviderDetails.extend_service_data.count > 0
            if isExtendService {
                viewExtendService.isHidden = false
                let extendService = providerSide_ProviderDetails.extend_service_data.first!
                lblValExtendSeriveDuration.text = extendService.booking_start_time + " to " + extendService.booking_end_time
                lblValExtendSeriveHours.text = extendService.extend_hours
                lblValExtendSeriveCost.text = extendService.booking_amount
                lblValExtendSeriveStatus.text = extendService.extend_status.capitalized + "    "
                lblValExtendSeriveStatus.backgroundColor = StatusState.setStatusColor(status: extendService.extend_status)
                
                //TODO: Set Accept & Reject buttons visibility on if status type is pending
                if providerSide_ProviderDetails.extend_service_data.first!.extend_status.caseInsensitiveCompare(string: StatusState.StatusType.pending.rawValue){
                    stackViewAccptRjctForExtendServ.isHidden = false
                }
            }else{
                viewExtendService.isHidden = true
            }
            
            let isProposal = providerSide_ProviderDetails.proposal_service_data.count > 0
            if isProposal  && providerSide_ProviderDetails.service_status.lowercased() == "pending" {
                /* if !providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue)*/
                if !providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.onGoing.rawValue){
                    //above condition for prevent visibility in expired status
                    proposalMsgStackView.isHidden = false
                    viewProposalMessages.isHidden = false
                    proposalServiceAry = providerSide_ProviderDetails.proposal_service_data
                    proposalTableView.reloadData()
                    autoDynamicHeight()
                    
                    //Set Accept Reject buttons
                    if !providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue){
                        pendingProposal = providerSide_ProviderDetails.proposal_service_data.filter({$0.status.caseInsensitiveCompare(string: StatusState.StatusType.pending.rawValue)}).last
                        if let pendingProposal = pendingProposal, pendingProposal.created_by != UserData.shared.getUser()!.user_id &&
                            !(providerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.accepted.rawValue)){
                            stackViewAcceptReject.isHidden = false
                        }
                    }
                    autoDynamicHeight()
                }
            }else{
                viewProposalMessages.isHidden = true
                
            }
            
        }
    }
    
    @objc func onClickEmail(_ sender: UITapGestureRecognizer){
        sendEmail(emails: [(sender.view as! UILabel).text!])
    }
    
    @objc func onClickPhoneNumber(_ sender: UITapGestureRecognizer){
        self.callOn(PhoneNumber: (sender.view as! UILabel).text!)
    }
}

//MARK: mail compose delegate
extension ProviderSrvsReqRecent: MFMailComposeViewControllerDelegate{
    
    func sendEmail(emails:[String]) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(emails)
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            // show failure alert
            self.alert(title: "Error".localized, message: "Can't send mail".localized)
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        }
        
        controller.dismiss(animated: true)
    }
    
}

extension ProviderSrvsReqRecent: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProposalMsgCell.identifier) as? ProposalMsgCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellDataProviderSide = proposalServiceAry[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proposalServiceAry.count
    }
    
    func autoDynamicHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.constProposalTableHeight.constant = self.proposalTableView.contentSize.height
            self.view.layoutIfNeeded()
        }
    }
    
}

extension ProviderSrvsReqRecent: SendProposalProtocol{
    func sendProposalComplete(isSuccess: Bool) {
        if isSuccess{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func sendProposalStripeConnect() {
        let controller = StripeConnectWebVC.storyboardInstance
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
