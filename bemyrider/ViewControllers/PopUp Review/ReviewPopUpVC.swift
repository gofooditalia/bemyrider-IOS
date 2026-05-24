//
//  ReviewPopUpVC.swift
//  bemyrider
//
//  Created by NCT 24 on 16/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import Cosmos
import SkyFloatingLabelTextField

protocol SubmitReviews {
    func reviewSubmitted(isSuccess: Bool)
}

class ReviewPopUpVC: UIViewController {
    
    //MARK: Properties
    static var storyboardInstance:ReviewPopUpVC? {
        return StoryBoard.popUp.instantiateViewController(withIdentifier: ReviewPopUpVC.identifier) as? ReviewPopUpVC
    }
    
    var delegate:SubmitReviews?
    
    @IBOutlet weak var blackLayerView: UIView!
    @IBOutlet weak var containerView: UIView!{
        didSet{
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(onClickBlackLayer))
            containerView.addGestureRecognizer(tapGest)
        }
    }
    
    @IBOutlet weak var cosmosStarView: CosmosView!{
        didSet{
            cosmosStarView.didTouchCosmos = didTouchCosmos
            cosmosStarView.didFinishTouchingCosmos = didFinishTouchingCosmos
        }
    }
    
    @IBOutlet weak var txtReview: RobotoRegular14TextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    //var redeemHistoryData : RedeemHistory?
    var starRating:String = "0"
    var serviceRequestId:String?
    
    //MARK:  ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    func setLang() {
        txtReview.placeholder = "Enter Review*".localized
        btnSubmit.setTitle("SUBMIT".localized, for: .normal)
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        if isValidated(){
            callAddProviderReviewAPI()
        }
    }
    
}

//Mark: Custom functions
extension ReviewPopUpVC{
   
    @objc func onClickBlackLayer(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func callAddProviderReviewAPI() {
        if let serviceRequestId = serviceRequestId{
            let param: [String:Any] = [
                "user_id":UserData.shared.getUser()!.user_id,
                "service_id":serviceRequestId,
                "txt_ratting": starRating,
                "txt_description":txtReview.text!]
            Modal.shared.addProviderReview(vc: self, param: param) { (dic) in
                print(dic)
                self.dismiss(animated: true, completion: nil)
                if let delegate = self.delegate{
                    delegate.reviewSubmitted(isSuccess: true)
                }
            }
        }
    }
    
    func isValidated() -> Bool {
        var ErrorMsg = ""
        if (txtReview.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
            ErrorMsg = "Please provide review".localized
        }
        else if starRating <= "0" {
            ErrorMsg = "Please select rating".localized
        }
        if ErrorMsg != "" {
            let alert = UIAlertController(title: "Error".localized, message: ErrorMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
}

//Star View functions
extension ReviewPopUpVC{
    
    private func didTouchCosmos(_ rating: Double) {
        print(Float(rating))
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print(Float(rating))
        starRating = "\(Float(rating))"
    }
    
}
