//
//  innerServiceTabVC.swift
//  TaskGator
//
//  Created by NCT 24 on 03/05/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import GooglePlaces

extension Notification.Name {
    static let reloadPicker = Notification.Name("reloadPicker")
}

class innerServiceTabVC: UIViewController {
    
    //MARK: Properties
    
    
    static var storyboardInstance:innerServiceTabVC? {
        return StoryBoard.serviceProviderDetail.instantiateViewController(withIdentifier: innerServiceTabVC.identifier) as? innerServiceTabVC
    }
    
    
    var hoursList = [String]()
    var selectedHours: String?
    var latitude:CLLocationDegrees?
    var longitude:CLLocationDegrees?
    let pickerView =  UIDatePicker()
    let hoursPickerView = UIPickerView()
    //var paramPass:[String:Any] = [:]
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblServiceHours: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblAdminCom: UILabel!
    @IBOutlet weak var lblPaymentPref: UILabel!
    @IBOutlet weak var lblServiceDesc: UILabel!
    @IBOutlet weak var lblWorkingDays: UILabel!
    @IBOutlet weak var lblWorkingTimings: UILabel!
    @IBOutlet weak var lblDeliveyType: UILabel!
    
    @IBOutlet weak var lblValCategory: UILabel!
    @IBOutlet weak var lblValServiceHours: UILabel!
    @IBOutlet weak var lblValPrice: UILabel!
    @IBOutlet weak var lblValAdminCom: UILabel!
    @IBOutlet weak var lblValPaymentPref: UILabel!
    @IBOutlet weak var lblValServiceDesc: UILabel!
    @IBOutlet weak var lblValWorkingDays: UILabel!
    @IBOutlet weak var lblValWorkingTimings: UILabel!
    @IBOutlet weak var lblValDeliveryType: UILabel!
    
    @IBOutlet weak var hoursstc1: UIStackView!
    @IBOutlet weak var hoursstc2: UIStackView!
    @IBOutlet weak var serviceHoursbottomStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtDeliveryType: RightViewArrowTextField!{
        didSet{
            
            //            pickerView.addTarget(self, action: #selector(startTimeDiveChanged), for: .valueChanged)
            txtDeliveryType.inputView = pickerView
            txtDeliveryType.delegate = self
            txtDeliveryType.rightViewImage = #imageLiteral(resourceName: "dropdown")
            txtDeliveryType.isHidden = false
            txtDeliveryType.text = "Quick"
            txtDeliveryType.isHidden = true
        }
    }
    
    @IBOutlet weak var txtServiceStartTime: RightViewArrowTextField!{
        didSet{
            
            pickerView.date = Date()
            pickerView.minimumDate = Date()
            pickerView.minuteInterval = 15
            
            if #available(iOS 13.4, *) {
                pickerView.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            
            //            refreshDatePicker()
            //pickerView.datePickerMode = .time
            // For 24 Hrs
            //pickerView.locale = Locale(identifier: "en_GB")
            //For 12 Hrs
            //pickerView.locale = Locale(identifier: "en_US")
            pickerView.addTarget(self, action: #selector(startTimeDiveChanged), for: .valueChanged)
            txtServiceStartTime.inputView = pickerView
            txtServiceStartTime.delegate = self
            //            txtServiceStartTime.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "txt_calendar"))
            txtServiceStartTime.rightViewImage = #imageLiteral(resourceName: "txt_calendar")
            
        }
    }
    
    @IBOutlet weak var txtHours: RightViewArrowTextField!{
        didSet{
            hoursPickerView.delegate = self
            txtHours.inputView = hoursPickerView
            txtHours.delegate = self
            //            txtHours.rightView(frame: CGRect(x: 0, y: 0, width: 10, height: 10), image: #imageLiteral(resourceName: "dropdown"))
            txtHours.rightViewImage = #imageLiteral(resourceName: "dropdown")
            
            //txtHours.border(side: .bottom, color: Color.Black.theam, borderWidth: 1.0)
            //            txtHours.setPlaceHolderColor(color: Color.Black.theam)
        }
    }
    
    @IBOutlet weak var txtAddress: RobotoRegular14TextField!{
        didSet{
            txtAddress.delegate = self
        }
    }
    @IBOutlet weak var txtDescription: RobotoRegular14TextField!{
        didSet{
            txtDescription.delegate = self
        }
    }
    
    
    
    
    func setLang() {
        lblCategory.text = "Category".localized
        lblServiceHours.text = "Service Hours".localized
        lblPrice.text = "Rate".localized
        lblAdminCom.text = "Admin Commission".localized
        lblPaymentPref.text = "Payment Preference".localized
        lblServiceDesc.text = "Vehicle Model and Equipment".localized
        txtServiceStartTime.placeholder = "Service Start Time*".localized
        txtHours.placeholder = "Select Hours*".localized
        txtAddress.placeholder = "Address*".localized
        txtDescription.placeholder = "Description*".localized
        
        lblWorkingDays.text = "Daily availability".localized
        lblDeliveyType.text = "Vehicle Type".localized
        lblWorkingTimings.text = "Hourly availability".localized
        
        if #available(iOS 13.4, *) {
            pickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLang()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
}
extension innerServiceTabVC{
    
    @objc func startTimeDiveChanged(_ sender: UIDatePicker) {
        
        let formatter = DateFormatter()
        //        formatter.timeStyle = .short
        //        formatter.dateStyle = .medium
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        txtServiceStartTime.text = formatter.string(from: sender.date)
        //timePicker.removeFromSuperview() // if you want to remove time picker
        //Jul 26, 2018 at 2:45
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss" //"yyyy-MM-dd"
        let selectedDate = formatter2.string(from: sender.date)
        requestDic["service_start_time"] = selectedDate
        print(requestDic["service_start_time"] as! String)
        //2018-07-26 14:45:00
    }
    
    func loadUI()  {
        lblValCategory.text = providerServiceDetail?.category_name
        
        self.lblValDeliveryType.text =   providerServiceDetail!.delivery_type.isBlank ? deliveryType.localized : providerServiceDetail?.delivery_type
        self.lblValWorkingDays.text = providerServiceDetail?.available_days_list ?? "N/A"
        if let start = providerServiceDetail?.available_time_start, let end = providerServiceDetail?.available_time_end {
            self.lblValWorkingTimings.text = start + " - " + end
        }else{
            self.lblValWorkingTimings.text = "N/A"
        }
        
        if let  hours = providerServiceDetail?.hours {
            if hours == "1" {
                lblValServiceHours.text = providerServiceDetail!.hours + " " + "Hour".localized
            }else{
                lblValServiceHours.text = providerServiceDetail!.hours + " " + "Hours".localized
                
            }
        }
        
        lblValAdminCom.text = (providerServiceDetail?.customer_commission ?? "N/A")! + "%"
        //TODO: Get payment data from user default
        if providerServiceDetail?.payment_preference.lowercased() == "c" {
            lblValPaymentPref.text = "Cash".localized
        }else{
            lblValPaymentPref.text = "Wallet".localized
        }
        
        //lblValPaymentPref.text = providerServiceDetail?.payment_preference ?? UserData.shared.paymentPref
        lblValServiceDesc.text = providerServiceDetail!._description
        txtAddress.text = searchAddrDic["search_location"] as? String//providerDetails?.address
        
        //        txtAddress.isUserInteractionEnabled = false
        
        
        if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "hourly" {
            txtHours.isHidden = false
            lblValPrice.text = "\(UserData.shared.currency)" + providerServiceDetail!.price + " / \("Hour".localized)"
        }
        else{
            txtHours.isHidden = true
            lblValPrice.text =  UserData.shared.currency + providerServiceDetail!.price
        }
        
        //hoursList fillUp
        for i in 1...2{
            hoursList.append("\(i)")
        }
        
        //selectedHours = hoursList[0]
        //let str = "\(hoursList[0]) Hour"
        //txtHours.text = str
        
        
        //Change pass dictionary
        if let service_master_type = providerServiceDetail?.service_master_type, service_master_type == "fixed" {
            requestDic["provider_service_hours"] = providerServiceDetail!.provider_service_hours
        }
        else{
            requestDic["sel_hours"] = selectedHours
            hoursstc1.isHidden = true
            hoursstc2.isHidden = true
            //            serviceHoursbottomStackViewConstraint.constant = 0
        }
        print("=>requestDic:\(requestDic)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDatePicker), name: .reloadPicker, object: nil)
        
    }
    
    @objc func refreshDatePicker(){
        var isNextDate:Bool = false
        if pickerView.date.minute % 15 != 0 {
            if pickerView.date.minute > 45 {
                pickerView.date += 60*60
                isNextDate = true
            }
            pickerView.date = pickerView.date.nextHourQuarter
            pickerView.minimumDate = pickerView.date
        }
        
        if !isNextDate{
            pickerView.date = Date().nextHourQuarter
            pickerView.minimumDate = pickerView.date
        }
        txtServiceStartTime.inputView = pickerView
        pickerView.reloadInputViews()
        
    }
    
    
}

extension innerServiceTabVC: UITextFieldDelegate {
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == txtDescription{
            requestDic["service_details"] = textField.text
        }
        if textField == txtServiceStartTime{
            let formatter = DateFormatter()
            //                   formatter.timeStyle = .short
            formatter.dateFormat = "dd-MMM-yyyy HH:mm"
            //                   formatter.dateStyle = .medium
            txtServiceStartTime.text = formatter.string(from: pickerView.date)
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "yyyy-MM-dd HH:mm:ss" //"yyyy-MM-dd"
            let selectedDate = formatter2.string(from: pickerView.date)
            requestDic["service_start_time"] = selectedDate
            print(requestDic["service_start_time"] as! String)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtAddress {
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { [weak self] address, lat, lng in
                guard let self = self else { return }
                self.latitude  = lat
                self.longitude = lng
                self.txtAddress.text = address
                requestDic["service_address"] = address
                requestDic["search_location"] = address
                requestDic["bookingLat"]  = lat
                requestDic["bookingLong"] = lng
                searchAddrDic["search_location"] = address
                searchAddrDic["service_address"] = address
                searchAddrDic["bookingLat"]  = String(lat)
                searchAddrDic["bookingLong"] = String(lng)
            }
            present(UINavigationController(rootViewController: ac), animated: true)
            return false
        }
        if textField == self.txtServiceStartTime{
            refreshDatePicker()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtServiceStartTime || textField == txtHours{
            return false
        }else if txtAddress == textField {
            txtAddress.text = nil
            //https://developers.google.com/places/ios-api/
            //TODO: Display google place picker
            //let acController = GMSAutocompleteViewController()
            /*
             let filter = GMSAutocompleteFilter()
             filter.country = "HR"
             acController.autocompleteFilter = filter
             */
            //acController.delegate = self
            // present(acController, animated: true, completion: nil)
            return false
        }
        else if textField == txtDescription{
            requestDic["service_details"] = textField.writingTimeGetTextFieldString(string: string)
            print(requestDic["service_details"] as! String)
            return true
        }
        else {
            print("textField: \(String(describing: textField.text))")
            print("replacementString: \(string)")
            return true
        }
    }
    
}



extension innerServiceTabVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == hoursPickerView{
            return hoursList.count + 1
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == hoursPickerView{
            if hoursList.count > 0{
                if row > 0 {
                    selectedHours = hoursList[row - 1]
                    requestDic["sel_hours"] = selectedHours
                    if row == 1 {
                        let str = "\(hoursList[row - 1]) \("Hour".localized)"
                        txtHours.text = str
                    }else{
                        let str = "\(hoursList[row - 1]) \("Hours".localized)"
                        txtHours.text = str
                    }
                }
                else{
                    txtHours.text = ""//"Select Hour"
                }
            }
        }
        else{
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        label.textAlignment = .center
        label.font = RobotoFont.regular(with: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        if pickerView == hoursPickerView{
            if row == 0 {
                label.text = "Select Hours".localized
            }else if row == 1 {
                label.text = "\(hoursList[row - 1]) \("Hour".localized)"
            }else{
                label.text = "\(hoursList[row - 1]) \("Hours".localized)"
            }
        }
        else{
        }
        return label
    }
}

extension Date {
    var hour: Int { return Calendar.current.component(.hour, from: self) }
    var minute: Int { return Calendar.current.component(.minute, from: self) }
    var nextHourQuarter: Date {
        return  Calendar.current.date(bySettingHour: hour, minute: minute.nextHourQuarter, second: 0, of: self)!
    }
}

extension Int {
    var nextHourQuarter: Int {
        return (self - self % 15 + 15) % 60
    }
}
