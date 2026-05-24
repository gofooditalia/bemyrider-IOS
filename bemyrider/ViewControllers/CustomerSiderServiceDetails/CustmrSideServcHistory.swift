//
//  CustmrSideServcHistory.swift
//  bemyrider
//
//  Created by NCT 24 on 09/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import CoreLocation

class CustmrSideServcHistory: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:CustmrSideServcHistory? {
        return StoryBoard.customerSideServiceDetails.instantiateViewController(withIdentifier: CustmrSideServcHistory.identifier) as? CustmrSideServcHistory
    }
    var pendingProposal: ProposalServiceData?
    
    //    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblServiceHours: UILabel!
    @IBOutlet weak var lblTakeHours: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAdminFees: UILabel!
    @IBOutlet weak var lblAdminCom: UILabel!
    //    @IBOutlet weak var lblPaymentPref: UILabel!
    @IBOutlet weak var lblBookingDesc: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblServiceAddr: UILabel!
    @IBOutlet weak var lblDeliveryType: UILabel!
    //    @IBOutlet weak var lblRequestType: UILabel!
    @IBOutlet weak var lblWorkingDays: UILabel!
    @IBOutlet weak var lblWorkingTimings: UILabel!
    
    //    @IBOutlet weak var lblValCategory: UILabel!
    @IBOutlet weak var lblValStartTime: UILabel!
    @IBOutlet weak var lblValEndTime: UILabel!
    @IBOutlet weak var lblValServiceHours: UILabel!
    @IBOutlet weak var lblValTakeHours: UILabel!
    @IBOutlet weak var lblValPrice: UILabel!
    @IBOutlet weak var lblValAdminFees: UILabel!
    @IBOutlet weak var lblValAdminCom: UILabel!
    //    @IBOutlet weak var lblValPaymentPref: UILabel!
    @IBOutlet weak var lblValBookingDesc: UILabel!
    @IBOutlet weak var lblValServiceDesc: UILabel!
    @IBOutlet weak var lblValServiceAddr: UILabel!
    @IBOutlet weak var lblValDeliveryType: UILabel!
    //    @IBOutlet weak var lblValRequestType: UILabel!
    @IBOutlet weak var lblValWorkingDays: UILabel!
    @IBOutlet weak var lblValWorkingTimings: UILabel!
    
    @IBOutlet weak var constTopOfTakeHours: NSLayoutConstraint!
    @IBOutlet weak var constProposalTableHeight: NSLayoutConstraint!
    @IBOutlet weak var constTopOfPrice: NSLayoutConstraint!
    
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
    var proposalServiceAry = [ProposalServiceData]()
    
    @IBOutlet weak var lblExtendSerive: UILabel!
    @IBOutlet weak var lblExtendSeriveDuration: UILabel!
    @IBOutlet weak var lblExtendSeriveHours: UILabel!
    @IBOutlet weak var lblExtendSeriveCost: UILabel!
    @IBOutlet weak var lblExtendSeriveStatus: UILabel!
    
    @IBOutlet weak var lblValExtendSeriveDuration: UILabel!
    @IBOutlet weak var lblValExtendSeriveHours: UILabel!
    @IBOutlet weak var lblValExtendSeriveCost: UILabel!
    @IBOutlet weak var lblValExtendSeriveStatus: UILabel!
    @IBOutlet weak var extendServiceStackView: UIStackView!
    
    @IBOutlet weak var stackViewAcceptReject: UIStackView!{
        didSet{
            stackViewAcceptReject.isHidden = true
        }
    }
    @IBOutlet weak var btnReject: UIButton!{
        didSet{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.btnReject.border(side: .all, color: Color.green.theam, borderWidth: 1.0)
            }
        }
    }
    @IBOutlet weak var btnAccept: UIButton!
    
    
    @IBAction func onClickReject(_ sender: UIButton) {
        
        if let pendingProposal = pendingProposal{
            self.alert(title: "", message: "Are you sure you want to reject this proposal?".localized, actions: ["Ok".localized,"Cancel".localized]) { (btnNo) in
                if btnNo == 0 {
                    let param = [
                        "status_type": "rejected",
                        "proposal_id":pendingProposal.id,
                        "user_id":UserData.shared.getUser()!.user_id
                    ]
                    Modal.shared.acceptProposal(vc: self, param: param) { (dic) in
                        print(dic)
                        NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    //Do nothing
                }
            }
        }
            // OLD Counter request flow
//        if let pendingProposal = pendingProposal{
//            let parentVC = self
//            guard let nextVC = ProposalPopUpVC.storyboardInstance else {return}
//            nextVC.delegate = self
//            nextVC.proposalId = pendingProposal.id
//            nextVC.presentAsPopUp(parentVC: parentVC)
         
//        }
    }
    
    @IBAction func onClickAccept(_ sender: UIButton) {
        callAcceptedProposalAPI()
    }
    
    @IBAction func onClickMap(_ sender: UIButton) {
        //        if let customerSide_ProviderDetails = providerServiceDetail {
        //            if !customerSide_ProviderDetails.service_latitude.isEmpty && customerSide_ProviderDetails.service_latitude != "0.0" {
        //                UIApplication.shared.open(URL(string: "https://www.google.com/maps/@\(customerSide_ProviderDetails.service_latitude),\(customerSide_ProviderDetails.service_longitude)")!, options: [:], completionHandler: nil)
        //            }
        //        }
        if let providerSide_ProviderDetails = providerServiceDetail {
            if !providerSide_ProviderDetails.service_latitude.isEmpty && providerSide_ProviderDetails.service_latitude != "0.0" {
                //                UIApplication.shared.open(URL(string: "https://www.google.com/maps/@\(providerSide_ProviderDetails.service_latitude),\(providerSide_ProviderDetails.service_longitude)")!, options: [:], completionHandler: nil)
                if let urlDestination = URL(string: "https://www.google.com/maps/?daddr=\(providerSide_ProviderDetails.service_latitude),\(providerSide_ProviderDetails.service_longitude)&directionsmode=driving") {
                    UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .reloadFirstServiceData, object: nil)
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang(){
        //        lblCategory.text = "Category".localized
        lblStartTime.text = "Start Time".localized
        lblEndTime.text = "End Time".localized
        lblServiceHours.text = "Service Hours".localized
        lblTakeHours.text = "Task Hours".localized
        lblPrice.text = "Rate".localized
        lblAdminFees.text = "Fees".localized //"Admin Fees".localized
        lblAdminCom.text = "Admin Commision".localized
        //        lblPaymentPref.text = "Payment Preference".localized
        lblBookingDesc.text = "Booking Description".localized
        lblServiceDesc.text = "Vehicle Model and Equipment".localized
        lblServiceAddr.text = "Service Address".localized
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
        
        lblWorkingDays.text = "Daily Availability".localized
        lblWorkingTimings.text = "Hourly Availability".localized
        lblDeliveryType.text = "Vehicle Type".localized
        
    }
}

//Custom function
extension CustmrSideServcHistory{
    
    func callAcceptedProposalAPI() {
        if let pendingProposal = pendingProposal{
            let param = [
                "status_type":"accepted",
                "proposal_id":pendingProposal.id,
                "user_id":UserData.shared.getUser()!.user_id            ]
            Modal.shared.acceptProposal(vc: self, param: param) { (dic) in
                print(dic)
                NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func setVisibleViews() {
        viewExtendService.isHidden = true
        viewProposalMessages.isHidden = true
        
        if let customerSide_ProviderDetails = providerServiceDetail{
            let isExtendService = customerSide_ProviderDetails.extend_service_data.count > 0
            if isExtendService {
                viewExtendService.isHidden = false
                let extendService = customerSide_ProviderDetails.extend_service_data.first!
                lblValExtendSeriveDuration.text = extendService.booking_start_time + " to " + extendService.booking_end_time
                lblValExtendSeriveHours.text = extendService.extend_hours
                lblValExtendSeriveCost.text = extendService.booking_amt
                lblValExtendSeriveStatus.text = extendService.serviceStatus
                lblValExtendSeriveStatus.text = extendService.serviceStatus.capitalized + "    "
                lblValExtendSeriveStatus.backgroundColor = StatusState.setStatusColor(status: extendService.serviceStatus)
                lblValDeliveryType.text = customerSide_ProviderDetails.delivery_type.capitalized
                //                lblValRequestType.text = customerSide_ProviderDetails.request_type.capitalized
                
            }
            let isProposal = customerSide_ProviderDetails.proposal_service_data.count > 0
            if isProposal  && customerSide_ProviderDetails.service_status.lowercased() == "pending"  {
                if /*!customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue) &&*/
                    !customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.onGoing.rawValue){
                    //above condition for prevent visibility in expired status
                    viewProposalMessages.isHidden = false
                    proposalServiceAry = customerSide_ProviderDetails.proposal_service_data
                    proposalTableView.reloadData()
                    autoDynamicHeight()
                    
                    //Set Accept Reject buttons
                    if !customerSide_ProviderDetails.service_status.caseInsensitiveCompare(string: StatusState.StatusType.expired.rawValue){
                        pendingProposal = customerSide_ProviderDetails.proposal_service_data.filter({$0.status.caseInsensitiveCompare(string: StatusState.StatusType.pending.rawValue)}).last
                        if let pendingProposal = pendingProposal, pendingProposal.created_by != UserData.shared.getUser()!.user_id{
                            stackViewAcceptReject.isHidden = false
                        }
                    }
                    autoDynamicHeight()
                }
            }
            
            
        }
    }
    
    func loadData() {
        if let providerServiceDetail = providerServiceDetail{
            //            lblValCategory.text = providerServiceDetail.category_name
            lblValStartTime.text = providerServiceDetail.start_time
            lblValEndTime.text = providerServiceDetail.end_time
            lblValAdminFees.text = "\(UserData.shared.currency)\(providerServiceDetail.total_fees )"
            lblValAdminCom.text = providerServiceDetail.customer_commission + "%"
            //            let paymentMode = providerServiceDetail.payment_preference.capitalizingFirstLetter()
            //            lblValPaymentPref.text = paymentMode.localized
            lblValBookingDesc.text = providerServiceDetail.service_description
            lblValServiceDesc.text = providerServiceDetail._description
            lblValServiceAddr.text = providerServiceDetail.service_address
            lblValDeliveryType.text = providerServiceDetail.delivery_type.capitalized
            //            lblValRequestType.text = providerServiceDetail.request_type.capitalized
            
            self.lblValWorkingDays.text = providerServiceDetail.available_days_list.isEmpty ? "N/A" :  providerServiceDetail.available_days_list
            if !providerServiceDetail.available_time_start.isEmpty && !providerServiceDetail.available_time_end.isEmpty {
                self.lblValWorkingTimings.text = providerServiceDetail.available_time_start + " - " + providerServiceDetail.available_time_end
            }else{
                self.lblValWorkingTimings.text = "N/A"
            }
            
            //TODO: service_type based on that $ 5 ($ 5/hour)
            if providerServiceDetail.service_master_type == "hourly"{
                lblValPrice.text = "\(UserData.shared.currency)\(providerServiceDetail.booking_amt) (\(UserData.shared.currency)\(providerServiceDetail.price) / \("Hour".localized))"
                lblValTakeHours.text = providerServiceDetail.booking_hours
                //                constTopOfPrice.constant = 0
                //                constTopOfTakeHours.constant = 0
                lblValServiceHours.isHidden = true
                lblServiceHours.isHidden =  true
                self.view.layoutIfNeeded()
            }
            else{//fixed
                
                if providerServiceDetail.provider_service_hours == "1" {
                    lblValServiceHours.text = providerServiceDetail.provider_service_hours + " " + "Hour".localized
                }else{
                    lblValServiceHours.text = providerServiceDetail.provider_service_hours + " " + "Hours".localized
                    
                }
                
                if providerServiceDetail.hours == "1" {
                    lblValTakeHours.text = providerServiceDetail.hours + " " + "Hour".localized
                }else{
                    lblValTakeHours.text = providerServiceDetail.hours + " " + "Hours".localized
                    
                }
                
                lblValPrice.text = "\(UserData.shared.currency)\(providerServiceDetail.price)"
                lblTakeHours.isHidden = false
                lblValTakeHours.isHidden = false
                lblValServiceHours.isHidden = false
                lblServiceHours.isHidden =  false
                self.view.layoutIfNeeded()
            }
            setVisibleViews()
        }
        
    }
    
    @objc func reloadData(){
        loadData()
    }
}

extension CustmrSideServcHistory: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProposalMsgCell.identifier) as? ProposalMsgCell else {
            fatalError("Cell can't be dequeue")
        }
        cell.cellData = proposalServiceAry[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proposalServiceAry.count
    }
    
    func autoDynamicHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.constProposalTableHeight.constant = self.proposalTableView.contentSize.height + 50
            self.proposalTableView.layoutIfNeeded()
        }
    }
}

extension CustmrSideServcHistory: SendProposalProtocol{
    func sendProposalComplete(isSuccess: Bool) {
        if isSuccess{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
