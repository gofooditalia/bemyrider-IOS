//
//  Extenstions.swift
//
//  Created by Nirav Sapariya
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit
import CoreGraphics

enum BorderSide: Int {
    case all = 0, top, bottom, left, right, customRight, customBottom
}
extension UIView {
    //https://stackoverflow.com/questions/37903124/set-background-gradient-on-button-in-swift
    typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)
    
    enum GradientOrientation {
        case topRightBottomLeft
        case topLeftBottomRight
        case horizontal
        case vertical
        
        var startPoint : CGPoint {
            return points.startPoint
        }
        
        var endPoint : CGPoint {
            return points.endPoint
        }
        
        var points : GradientPoints {
            get {
                switch(self) {
                case .topRightBottomLeft:
                    return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
                case .topLeftBottomRight:
                    return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
                case .horizontal:
                    return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
                case .vertical:
                    return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
                }
            }
        }
    }
    
    func applyGradient(withColours colours: [UIColor], locations: [NSNumber]? = nil) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func border(side: BorderSide = .all, color:UIColor = UIColor.black, borderWidth:CGFloat = 1.0) {
        
        let border = CALayer()
        border.borderColor = color.cgColor
        border.borderWidth = borderWidth
        
        switch side {
        case .all:
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = color.cgColor
        case .top:
            border.frame = CGRect(x: 0, y: 0, width:self.frame.size.width ,height: borderWidth)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width:self.frame.size.width ,height: borderWidth)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.size.height)
        case .right:
            border.frame = CGRect(x: self.frame.size.width - borderWidth, y: 0, width: borderWidth, height: self.frame.size.height)
        case .customRight:
            border.frame = CGRect(x: self.frame.size.width - borderWidth - 8, y: 8, width: borderWidth, height: self.frame.size.height - 16)
        case .customBottom:
            border.frame = CGRect(x: 8, y: self.frame.size.height - borderWidth , width:self.frame.size.width - 16 ,height: borderWidth)
        }
        if side.rawValue != 0 {
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
    }
    
    func removeBorder() {
        self.layer.sublayers?.first?.removeFromSuperlayer()
    }
    
    func shadow(Offset: CGSize = CGSize(width: 0, height: 0), redius: CGFloat = 2, opacity:Float = 0.5, color:UIColor = .black) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = Offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = redius
        layer.masksToBounds = false
    }
    
    func setRadius(_ radius: CGFloat? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
    func setRadius(_ radius: CGFloat? = nil, borderWidth:CGFloat = 1.0, color:UIColor) {
        self.layer.cornerRadius = radius ?? self.frame.height / 2
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = true
    }
    
    func setRadiusWithShadow(_ radius: CGFloat? = nil,color:UIColor? = nil) {
        self.layer.cornerRadius = radius ?? self.frame.width / 2
        self.layer.shadowColor = color?.cgColor ?? UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
    func shadow() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = <scale> ? UIScreen.main.scale : 1
    }
    
    //    func parentView<T: UIView>(of type: T.Type) -> T? {
    //        guard let view = self.superview else {
    //            return nil
    //        }
    //        return (view as? T) ?? view.parentView(of: T.self)
    //    }
    
    func viewController(forView view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        repeat {
            responder = responder?.next
            if let vc = responder as? UIViewController {
                return vc
            }
        } while responder != nil
        return nil
    }
    
    func bringToFront() {
        self.superview?.bringSubview(toFront: self)
    }
    
    func sendToBack(view: UIView) {
        self.sendSubview(toBack: view)
    }
    
}

enum AnimationDirection: Int {
    case topToBottom = 0, bottomToTop, rightToLeft, leftToRight
}
extension UIView {
    func swipeAnimation(direction: AnimationDirection, duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition object
        let leftToRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            leftToRightTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        switch direction {
        case .topToBottom:
            leftToRightTransition.subtype =  kCATransitionFromTop
        case .bottomToTop:
            leftToRightTransition.subtype =  kCATransitionFromBottom
        case .rightToLeft:
            leftToRightTransition.subtype =  kCATransitionFromRight
        case .leftToRight:
            leftToRightTransition.subtype =  kCATransitionFromLeft
        }
        leftToRightTransition.type = kCATransitionPush
        leftToRightTransition.duration = duration
        leftToRightTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        leftToRightTransition.fillMode = kCAFillModeRemoved
        
        // Add the animation to the View's layer
        self.layer.add(leftToRightTransition, forKey: "leftToRightTransition")
        //print("count:\(self.layer.sublayers!.count)")
    }
    
}

//https://stackoverflow.com/questions/31232689/how-to-set-cornerradius-for-only-bottom-left-bottom-right-and-top-left-corner-te/41217791
extension UIView {
    enum CornerBorderSide {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    @available(iOS 11.0, *)
    func setCornerRadious(withRadious radius: CGFloat = 10.0, cornerBorderSides: [CornerBorderSide]){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        var cornerMask: CACornerMask = [.layerMinXMaxYCorner]
        cornerMask.remove(.layerMinXMinYCorner)
        forLoop: for side in cornerBorderSides{
            switch side{
            case .bottomLeft:
                cornerMask.insert(.layerMinXMaxYCorner)
            case .bottomRight:
                cornerMask.insert(.layerMaxXMaxYCorner)
            case .topLeft:
                cornerMask.insert(.layerMinXMinYCorner)
            case .topRight:
                cornerMask.insert(.layerMaxXMinYCorner)
            }
        }
        self.layer.maskedCorners = cornerMask
    }
    //If not iOS 11 then apply below code
    //    let rectShape = CAShapeLayer()
    //    rectShape.bounds = self.gradientView.frame
    //    rectShape.position = self.gradientView.center
    //    rectShape.path = UIBezierPath(roundedRect: self.gradientView.bounds, byRoundingCorners: [.bottomRight , .topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
    //    self.gradientView.layer.mask = rectShape
    
}

extension UIViewController {
    //MARK:- UIAlertController
    func alert(title: String, message : String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok".localized, style: .cancel, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message : String, completion:@escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK".localized, style: .default) {
            (action: UIAlertAction) in
            print("You've pressed OK Button")
            completion()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message : String, actions:[String], completion:@escaping (_ index:Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for i in 0..<actions.count {
            let act = UIAlertAction(title: actions[i], style: .default, handler: { (actionn) in
                let indexx = actions.firstIndex(of: actionn.title!)
                completion(indexx!)
            })
            alertController.addAction(act)
        }

        self.present(alertController, animated: true, completion: nil)
    }

    func alert(title: String, message : String, actions:[String], style: [UIAlertAction.Style], completion:@escaping (_ index:Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for i in 0..<actions.count {
            let act = UIAlertAction(title: actions[i], style: style[i], handler: { (actionn) in
                let indexx = actions.firstIndex(of: actionn.title!)
                completion(indexx!)
            })
            alertController.addAction(act)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message : String, actions:[UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension String {
    //This is used for shouldChangeCharactersIn() method to prevent other alphabetss entery
    var isStringContainsOnlyDigit: Bool {
        get{
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: self)
            return allowedCharacters.isSuperset(of: characterSet)
        }
    }
    
    func exclude(find:String) -> String {
        return self.replacingOccurrences(of: find, with: "", options: .caseInsensitive, range: nil)
    }
    
    func replaceAll(find:String, with:String) -> String {
        return self.replacingOccurrences(of: find, with: with, options: .caseInsensitive, range: nil)
    }
    
    mutating func removeSpecificCharFromString(find:String) {
        self = self.replacingOccurrences(of: find, with: "", options: .caseInsensitive, range: nil)
    }
    
    mutating func replaceSpecificCharFromString(find:String, with:String) {
        self = self.replacingOccurrences(of: find, with: with, options: .caseInsensitive, range: nil)
    }
    
    mutating func addSpaceTrainlingAndLeading(char: Character = " ", spaceNum: Int = 1) {
        for _ in 1...spaceNum {
            self.insert(char, at: self.endIndex)
            self.insert(char, at: self.startIndex)
        }
    }
    
    func digitsOnly() -> String{
        let newString = components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined(separator: "")
        return newString
    }
    
    //Prevent to accept only spaces in text fields
    var isBlank: Bool {
        get{
            return self.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    var isValidAmount: Bool {
        get{
            return Int(self)! > 0
        }
    }
    
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.stringWithoutWhitespaces.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    //^[2-9]{2}[0-9]{8}$
    //    var isphoneNumber: Bool{
    //        get{
    //            let REGEX: String
    //            REGEX = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{2,4}$"
    //            //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    //            //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    //            return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: self)
    //        }
    
    var stringWithoutWhitespaces: String {
        return self.replacingOccurrences(of: " ", with: "")
        //let isValid = string.stringWithoutWhitespaces.isNumber
    }
    
    var isValidEmailId: Bool{
        get{
            //            let REGEX: String
            //            REGEX = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{2,4}$"
            //            //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            //            //"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            //            return NSPredicate(format: "SELF MATCHES %@", REGEX).evaluate(with: self)
            let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
            let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
            let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
            let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
            return __emailPredicate.evaluate(with: self)
        }
    }
    
    var length : Int {
        return self.count
    }
    
    func contains(string: String) -> Bool {
        return self.lowercased().contains(string.lowercased()) ? true : false
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func fileNameOnly() -> String {
        let fileNameWithoutExtension = URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
        if !fileNameWithoutExtension.isEmpty{
            return fileNameWithoutExtension
        } else {
            return ""
        }
        //        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
        //            return fileNameWithoutExtension
        //        } else {
        //            return ""
        //        }
    }
    
    func fileExtensionOnly() -> String {
        let fileExtension = URL(fileURLWithPath: self).pathExtension
        if !fileExtension.isEmpty{
            return fileExtension
        } else {
            return ""
        }
        //        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
        //            return fileExtension
        //        } else {
        //            return ""
        //        }
    }
    
    func fileNameWithExtension() -> String {
        let fileNameWithoutExtension = URL(fileURLWithPath: self).lastPathComponent
        if !fileNameWithoutExtension.isEmpty {
            return fileNameWithoutExtension
        } else {
            return ""
        }
        //        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).lastPathComponent {
        //            return fileNameWithoutExtension
        //        } else {
        //            return ""
        //        }
    }
    /*
     //Usage
     let file = "image.png"
     let fileNameWithoutExtension = file.fileName()
     let fileExtension = file.fileExtension()
     */
    
    
    func caseInsensitiveCompare(string: String) -> Bool {
        if (self.caseInsensitiveCompare(string) == .orderedSame) {
            return true
        }
        else{
            return false
        }
    }
}

extension String {
    
    func height(with width: CGFloat, font: UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: font], context: nil)
        return actualSize.height
    }
    ////https://stackoverflow.com/questions/37048759/swift-display-html-data-in-a-label-or-textview
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension NSAttributedString {
    
    func height(with width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil)
        return actualSize.height
    }
    
    static func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}

extension UITextField{
    //This method used to searching methos Or Serching API call
    func writingTimeGetTextFieldString(string: String) -> String {
        let replacementString = string
        let textFieldString = self.text
        var finalString = ""
        if string.count > 0 { // if it was not delete character
            finalString = textFieldString! + replacementString
        }
        else if (textFieldString?.count ?? 0) > 0{ // if it was a delete character
            finalString = String(textFieldString!.dropLast())
            if finalString.count <= 0 { //if all character are deleted..then show all values
                finalString = ""
            }
        }
        return finalString
    }
    
}

extension String {
    func getStringInMutipleColor(strings : [String], colors : [UIColor]) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        if strings.count == colors.count {
            for index in 0 ..< strings.count {
                let range = (self as NSString).range(of: strings[index])
                attributeString.addAttribute(.foregroundColor, value: colors[index], range: range)
            }
        }
        return attributeString
    }
}

extension UITextField{
    
    func leftView(frame:CGRect, image:UIImage?) {
        let view = UIView(frame: frame)
        //view.backgroundColor = UIColor.clear
        let imgView = UIImageView()
        imgView.frame = CGRect(x: 5, y: 5, width:15, height:15)
        imgView.image = image
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        self.leftView = view;
        self.leftViewMode = UITextFieldViewMode.always;
    }
    
    func rightView(frame:CGRect, image:UIImage?) {
        let view = UIView(frame: frame)
        //view.backgroundColor = UIColor.gray
        let imgView = UIImageView()
        imgView.frame = CGRect(x: -10, y: 5, width:15, height:15)//CGRect(x: 0, y: 0, width: 15, height: 15)
        imgView.image = image
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        self.rightView = view;
        self.rightViewMode = UITextFieldViewMode.always
    }
    
    func resetTextField() {
        self.resignFirstResponder()
        self.text = nil
    }
    
    func setPlaceHolderColor(color: UIColor){
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : color])
    }
    
    func setTextFiledAsRequired(string: String = "*", color: UIColor = UIColor.red) {
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = placeholder.getStringInMutipleColor(strings: [string], colors: [color])
        }
    }
    
    func addPasswordToggel() {
        let passwordToggelButton:UIButton = {
            let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "eye-open").withRenderingMode(.alwaysTemplate), for: .selected)
            button.setImage(#imageLiteral(resourceName: "eye-close").withRenderingMode(.alwaysTemplate), for: .normal)
            button.frame = CGRect(x: 0, y: 0, width: (self.frame.height) * 0.70, height: (self.frame.height) * 0.70)
            button.backgroundColor = .clear
            button.tintColor = Color.green.theam
            button.addTarget(self, action: #selector(didTapBtnPasswordToggel), for: .touchUpInside)
            return button
        }()
        self.rightView = passwordToggelButton
        self.rightViewMode = .whileEditing
        self.isSecureTextEntry = true
    }
    @objc private func didTapBtnPasswordToggel(_ sender:UIButton){
        UIView.transition(
            with: (sender),
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                sender.isSelected.toggal()
                self.isSecureTextEntry.toggal()
        })
    }
    
    
    func setPasswordToggle(normalImage icon1: UIImage, selectedImage icon2: UIImage) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0,
                                             width: ((self.frame.height) * 0.70),
                                             height: ((self.frame.height) * 0.70)))
        btnView.setImage(icon1, for: .normal)
        btnView.setImage(icon2, for: .selected)
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        self.rightViewMode = .whileEditing
        self.rightView = btnView
        btnView.tag = 10101
        btnView.addTarget(self, action: #selector(btnEyeAction(_:)), for: .touchUpInside)
        isSecureTextEntry = true
    }
    
    @objc private func btnEyeAction(_ sender: UIButton) {
        self.isSecureTextEntry = sender.isSelected
        //sender.isSelected = !sender.isSelected
        UIView.transition(
            with: (sender),
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                guard sender === self.rightView?.viewWithTag(10101) as? UIButton else {
                    return
                }
                sender.isSelected = !sender.isSelected
        })
    }
    
}

//https://finnwea.com/blog/adding-placeholders-to-uitextviews-in-swift
/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    public func resetPlaceHolder(){
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
                placeholderLabel.isHidden = self.text.count > 0
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.isHidden = self.text.count > 0
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        placeholderLabel.isHidden = self.text.count > 0
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

//Used for get the reference of ViewController from custome cell
extension UIResponder {
    var viewController: UIViewController? {
        if let vc = self as? UIViewController {
            return vc
        }
        return next?.viewController
    }
}

extension UIFont {
    class func getAllFontName() {
        for family in UIFont.familyNames {
            let familyString = family as NSString
            print("=============\(familyString)==============")
            for name in UIFont.fontNames(forFamilyName: familyString as String) {
                print(name)
            }
        }
    }
    class func printAllFontNames() {
        UIFont.familyNames.sorted().forEach({ print($0); UIFont.fontNames(forFamilyName: $0 as String).forEach({print($0)})})
    }
}

//https://stackoverflow.com/questions/24051633/how-to-remove-an-element-from-an-array-in-swift
extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
}

//https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
extension UIDevice {
    static func isiPhone5() -> Bool {
        var flag:Bool = false
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //print("iPhone 5 or 5S or 5C")
                flag = true
            case 1334:
                break
            //print("iPhone 6/6S/7/8")
            case 2208:
                break
            //print("iPhone 6+/6S+/7+/8+")
            case 2436:
                break
            //print("iPhone X")
            default:
                print("unknown Device")
            }
        }
        return flag
    }
}

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
/*
 let roundedValue1 = 0.6844.roundToDecimal(3)
 let roundedValue2 = 0.6849.roundToDecimal(3)
 print(roundedValue1) // returns 0.684
 print(roundedValue2) // returns 0.685
 */

extension UIApplication {
    //https://stackoverflow.com/questions/17678881/how-to-change-status-bar-text-color-in-ios-7
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}

//TODO:  Encoding Emojis:
extension String {
    //    var encodeEmoji: String{
    //        let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
    //        return String(data: data, encoding: .utf8)!
    //    }
    
    var encodeEmoji: String{
        if let encodeStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }
    
    //    var encodeEmoji: String {
    //        if let encodedStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
    //            return encodedStr as String
    //        }
    //        return self
    //    }
    
}
//Usage: let encodedString = yourString.encodeEmoji

//TODO: Decoding Emojis:
extension String {
    //    var decodeEmoji: String{
    //        let data = self.data(using: .utf8)!
    //        return String(data: data, encoding: .nonLossyASCII)!
    //    }
    
    //    var decode:String {
    //        let uni = self.unicodeScalars // Unicode scalar values of the string
    //        let unicode = uni[uni.startIndex].value // First element as an UInt32
    //
    //        print(String(unicode, radix: 16, uppercase: true))
    //    }
    
    var trim : String {
           return self.trimmingCharacters(in: .whitespaces)
       }
    
    var decodeEmoji: String{
        //let mainStr = self.replacingOccurrences(of: "\n", with: " ")
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return (str as String)
        }
        return self
    }
    
    //    var decodeEmoji: String {
    //        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
    //        if data != nil {
    //            let valueUniCode = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
    //            if let str = valueUniCode {//valueUniCode != nil {
    //                return str as String
    //            } else {
    //                return self
    //            }
    //        } else {
    //            return self
    //        }
    //    }
    
    //    func replaceWithEmoji(str: String) -> String {
    //        var result = str
    //
    //        let regex = try! NSRegularExpression(pattern: "(U\\+([0-9A-F]+))", options: [.caseInsensitive])
    //        let matches = regex.matches(in: result, options: [], range: NSMakeRange(0, result.characters.count))
    //
    //        for m in matches.reversed() {
    //            let range1 = m.rangeAt(1)
    //            let range2 = m.rangeAt(2)
    //
    //            if let codePoint = Int(result[range2], radix: 16) {
    //                let emoji = String(UnicodeScalar(codePoint))
    //                let startIndex = result.startIndex.advancedBy(range1.location)
    //                let endIndex = startIndex.advancedBy(range1.length)
    //
    //                result.replaceRange(startIndex..<endIndex, with: emoji)
    //            }
    //        }
    //
    //        return result
    //    }
    
}
//Usage: let decodedString = yourString.decodeEmoji

extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle,
                                          value: NSUnderlineStyle.styleSingle.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}

extension UIButton {
    func underline() {
        let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle,
                                      value: NSUnderlineStyle.styleSingle.rawValue,
                                      range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}


extension UIViewController {
    
    func presentAsPopUp(parentVC: UIViewController) {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        parentVC.present(self, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    //https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    func open(url: URL) {
        if UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
                UIApplication.shared.open(url, options: options, completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
        else{
            print("Can't open given URL")
        }
    }
    
    func callOn(PhoneNumber: String) {
        
        if let url = NSURL(string: "tel://\(PhoneNumber.replacingOccurrences(of: " ", with: ""))") as URL?, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                //let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
        else{
            print("Can't performe call")
        }
    }
    
    func sendMailTo(email: String) {
        if let url = NSURL(string: "mailto://\(email)") as URL?, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                //let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true]
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
        else{
            print("Can't send mail")
        }
    }
    
}


import Photos
import MobileCoreServices.UTType

extension UIImagePickerController{
    
    enum CheckStatus:String{
        case camera
        case photo
    }
    func chooseImage(vc:UIViewController, isCaptureFromCamera:Bool = false, allowsEditing:Bool = false, allowToPickVideo:Bool = false){
        if isCaptureFromCamera{
            self.openGalleryOrPhotoLibrary(vc: vc, sourceType: .camera,allowsEditing:allowsEditing, allowToPickVideo: allowToPickVideo)
        }
        else{
            self.openGalleryOrPhotoLibrary(vc: vc, sourceType: .photoLibrary,allowsEditing:allowsEditing, allowToPickVideo: allowToPickVideo)
        }
    }
    //Original function
    /*
     func chooseImage(vc:UIViewController, isCaptureFromCamera:Bool = false, allowsEditing:Bool = false){
     
     if isCaptureFromCamera{
     let openGallery = UIAlertAction(title: "Choose Photo", style: .default) { (actions) in
     self.openGalleryOrPhotoLibrary(vc: vc, sourceType: .photoLibrary,allowsEditing:allowsEditing)
     }
     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (actions) in
     self.dismiss(animated: true, completion: nil)
     }
     vc.alert(title: "", message: "Select Image", actions: [openGallery,cancel])
     }else{
     let openCamera = UIAlertAction(title: "Take Photo", style: .default) { (actions) in
     self.openGalleryOrPhotoLibrary(vc: vc, sourceType: .camera,allowsEditing:allowsEditing)
     }
     let openGallery = UIAlertAction(title: "Choose Photo", style: .default) { (actions) in
     self.openGalleryOrPhotoLibrary(vc: vc, sourceType: .photoLibrary,allowsEditing:allowsEditing)
     }
     let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (actions) in
     self.dismiss(animated: true, completion: nil)
     }
     vc.alert(title: "", message: "Select Image", actions: [openCamera,openGallery,cancel])
     }
     }
     */
    
    private func openGalleryOrPhotoLibrary(vc: UIViewController,sourceType:UIImagePickerControllerSourceType,allowsEditing:Bool, allowToPickVideo:Bool) {
        //            #if targetEnvironment(simulator)
        //            // Simulator
        //             self.sourceType = .photoLibrary
        //            #else
        //            // Device
        //               self.sourceType = .camera
        //            #endif
        self.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.allowsEditing = allowsEditing
        switch sourceType {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.sourceType = .camera
                //                if allowToPickVideo {
                //                    if #available(iOS 9.1, *) {
                //                        self.mediaTypes = [kUTTypeImage, kUTTypeMovie, kUTTypeLivePhoto] as [String]
                //                        //self.videoMaximumDuration = 10.0 //Default 600 seconds
                //                        //["public.image","public.movie"]
                //                    } else {
                //                        // Fallback on earlier versions
                //                        self.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
                //                    }
                //                }
                //                else{/* Default media type*/}
            }else{
                self.alert(title: "Alert".localized, message: "Camera is not available in this device".localized)
            }
            self.checkPhotoLibraryPermission(vc: vc, status: .camera)
        case .photoLibrary:
            self.sourceType = .photoLibrary
            if allowToPickVideo {
                if #available(iOS 9.1, *) {
                    self.mediaTypes = [kUTTypeImage, kUTTypeMovie, kUTTypeLivePhoto] as [String]
                    //["public.image","public.movie"]
                } else {
                    // Fallback on earlier versions
                    self.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
                }
            }
            else{/* Default media type*/}
            self.checkPhotoLibraryPermission(vc: vc, status: .photo)
        default:
            return
        }
    }
    
    private  func checkPhotoLibraryPermission(vc: UIViewController,status:CheckStatus){
        // Get the current authorization state.
        if status == CheckStatus.photo{
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized , .limited:
                // Access has been granted.
                //self.openGallary()
                vc.present(self, animated: true, completion: nil)
            case .denied, .restricted :
                // Access has been denied.
                // Restricted access - normally won't happen.
                self.openSettingForGivePermissionPhotos(vc: vc, status: .photo)
            case .notDetermined:
                // ask for permissions
                // Access has not been determined.
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        //self.openGallary()
                        vc.present(self, animated: true, completion: nil)
                    }
                    else {
                        self.openSettingForGivePermissionPhotos(vc: vc, status: .photo)
                    }
                })
            }
        }else if status == CheckStatus.camera{
            //https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera
            //https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera/27646311
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch authStatus {
            case .authorized:
                vc.present(self, animated: true, completion: nil)
            //                openCamera() // Do your stuff here i.e. callCameraMethod()
            case .denied, .restricted:
                self.openSettingForGivePermissionPhotos(vc: vc, status: .camera)
            //                openSettingForGivePermissionCamera()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                        vc.present(self, animated: true, completion: nil)
                        //                        self.openCamera()
                    } else {
                        //access denied
                        self.openSettingForGivePermissionPhotos(vc: vc, status: .camera)
                        //                        openSettingForGivePermissionCamera()
                    }
                })
            }
        }
    }
    
    private func openSettingForGivePermissionPhotos(vc: UIViewController,status:CheckStatus) {
        vc.alert(title: "", message: status == CheckStatus.photo ? "Photo Access Prohibited".localized : "Camera access required for capturing photos!".localized, actions: ["Cancel".localized,"Settings".localized], completion: { (flag) in
            if flag == 1{ //Setting
                vc.open(scheme:UIApplicationOpenSettingsURLString)
            }
            else{//Cancel
            }
        })
    }
    
}

extension UIImagePickerController{
    
    func getPickedFileName(info: [String:Any]) -> String? {
        if #available(iOS 11.0, *) {
            if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                if let fileName = (asset.value(forKey: "filename")) as? String {
                    print("\(fileName)")
                    return fileName
                }
                else{return nil}
            }
            else{return nil}
        } else {
            // Fallback on earlier versions
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                if let asset = result.firstObject {
                    print(asset.value(forKey: "filename")!)
                    return asset.value(forKey: "filename") as? String ?? ""
                }
                else{return nil}
            }
            else{return nil}
        }
        
    }
    
    func openGallery(vc: UIViewController) {
        self.delegate = vc as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.allowsEditing = false
        self.sourceType = .photoLibrary
        self.checkPhotoLibraryPermission(vc: vc)
    }
    
    private func checkPhotoLibraryPermission(vc: UIViewController){
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized , .limited:
            // Access has been granted.
            //self.openGallary()
            DispatchQueue.main.async {
            vc.present(self, animated: true, completion: nil)
            }
        case .denied, .restricted :
            // Access has been denied.
            // Restricted access - normally won't happen.
            self.openSettingForGivePermissionPhotos(vc: vc)
        case .notDetermined:
            // ask for permissions
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    //self.openGallary()
                    DispatchQueue.main.async {
                    vc.present(self, animated: true, completion: nil)
                    }
                }
                else {
                    self.openSettingForGivePermissionPhotos(vc: vc)
                }
            })
        }
    }
    
    private func openSettingForGivePermissionPhotos(vc: UIViewController) {
        vc.alert(title: "", message: "Photo Access Prohibited", actions: ["Cancel","Settings"], completion: { (flag) in
            if flag == 1{ //Setting
                vc.open(scheme:UIApplicationOpenSettingsURLString)
            }
            else{//Cancel
            }
        })
    }
    
}

//https://stackoverflow.com/questions/26519248/how-to-set-the-full-width-of-separator-in-uitableview
extension UITableViewCell {
    func setFullWidthSeparator() {
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }
}

//MARK:- Very Important Extention for developer purpose
extension UITableViewCell{
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

extension UIViewController{
    
    static var identifier: String {
        return String(describing: self)
    }
    
    //    static private func storyboardInstance <T:UIViewController>(viewControllerClass : T.Type, storyBoard: StoryBoardName = .none) -> T{
    //        let nibName = (storyBoard == .none ? String(describing: self) : storyBoard.rawValue)
    //        return UIStoryboard(name: nibName, bundle: nil).instantiateViewController(withIdentifier: identifier) as! T
    //    }
    //
    //    static func storyboardInstance(storyBoard: StoryBoardName) -> Self{
    //        return storyboardInstance(viewControllerClass: self, storyBoard: storyBoard)
    //    }
    
    //enum StoryBoardName:String {
    //    case main = "Main"
    //    case slideMenu = "SlideMenu"
    //    case singleViews = "SingleViews"
    //    case profiles = "Profiles"
    //    case popUp = "PopUp"
    //    case wallet = "Wallet"
    //    case messages = "Messages"
    //    case notification = "Notifications"
    //    case searchProvide = "SearchProvider"
    //    case provider = "Provider"
    //    case serviceDetail = "ServiceDetail"
    //    case none = "none"
    //}
    
    
}

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String(describing: viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
}

//https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        //contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                //self.image = images
                UIImageWriteToSavedPhotosAlbum(image/*imgThumb.image!*/, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    @objc fileprivate func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!".localized, message: "Image has been saved to your photos.".localized, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: nil))
            self.viewController?.present(ac, animated: true, completion: nil)
            print("Save Photo")
        } else {
            let ac = UIAlertController(title: "Save error".localized, message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: nil))
            self.viewController?.present(ac, animated: true, completion: nil)
            print("Error in Save Photo")
        }
    }
}

//https://stackoverflow.com/questions/32163848/how-to-convert-string-to-md5-hash-using-ios-swift

func md5HexString(_ string: String) -> String {
    let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
    var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
    CC_MD5_Init(context)
    CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
    CC_MD5_Final(&digest, context)
    context.deallocate()
    var hexString = ""
    for byte in digest {
        hexString += String(format:"%02x", byte)
    }
    return hexString
}

//func MD5(string: String) -> Data {
//    let messageData = string.data(using:.utf8)!
//    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
//
//    _ = digestData.withUnsafeMutableBytes {digestBytes in
//        messageData.withUnsafeBytes {messageBytes in
//            CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
//        }
//    }
//
//    return digestData
//}
/*
 //Test:
 let md5Data = MD5(string:"Hello")
 
 let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
 print("md5Hex: \(md5Hex)")
 
 let md5Base64 = md5Data.base64EncodedString()
 print("md5Base64: \(md5Base64)")
 */



extension CGFloat {
    
    init?(string: String) {
        
        guard let number = NumberFormatter().number(from: string) else {
            return nil
        }
        
        self.init(number.floatValue)
    }
    
}
//let x = CGFloat(xString)


extension UIDatePicker {
    //https://stackoverflow.com/questions/10494174/minimum-and-maximum-date-in-uidatepicker
    func setLimit(forCalendarComponent component:Calendar.Component, minimumUnit min: Int, maximumUnit max: Int) {
        
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        guard let timeZone = TimeZone(identifier: "UTC") else { return }
        calendar.timeZone = timeZone
        
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        
        components.setValue(-min, for: component)
        if let maxDate: Date = calendar.date(byAdding: components, to: currentDate) {
            self.maximumDate = maxDate
        }
        
        components.setValue(-max, for: component)
        if let minDate: Date = calendar.date(byAdding: components, to: currentDate) {
            self.minimumDate = minDate
        }
    }
}
//self.datePicker.setLimit(forCalendarComponent: .year, minimumUnit: 13, maximumUnit: 100)

extension UIDatePicker {
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    }
}


//https://stackoverflow.com/questions/25533147/get-day-of-week-using-nsdate
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}
//Use:
//print(Date().dayOfWeek()!) // Wednesday

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

//Use
// returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
//print(Date().dayNumberOfWeek()!) // 4

import MapKit
extension CLGeocoder{
    static func getCoordinate(_ addressString : String,
                              completionHandler: @escaping(CLLocationCoordinate2D) -> Void ) {
        //completionHandler: @escaping(CLLocationCoordinate2D, Error?) -> Void )
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else{
                        // handle no location found
                        print(error?.localizedDescription ?? "ERROR in get lat long")
                        completionHandler(kCLLocationCoordinate2DInvalid)
                        return
                }
                completionHandler(location.coordinate)
                return
            }
            else{
                print(error?.localizedDescription ?? "ERROR in get lat long")
                completionHandler(kCLLocationCoordinate2DInvalid)
            }
        }
    }
    
    static func openMapFromAddress(_ addressString : String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else{
                        // handle no location found
                        print(error?.localizedDescription ?? "ERROR in get lat long")
                        return
                }
                let latitude: CLLocationDegrees = location.coordinate.latitude
                let longitude: CLLocationDegrees = location.coordinate.longitude
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                    ] as [String : Any]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = addressString //customerSide_ProviderDetails?.address
                mapItem.openInMaps(launchOptions: options)
                UIApplication.shared.open(URL(string: "http://maps.apple.com/?ll=\(String(describing: location.coordinate.latitude)),\(String(describing: location.coordinate.longitude))")!, options: [:], completionHandler: nil)
            }
            else{
                print(error?.localizedDescription ?? "ERROR in get lat long")
            }
        }
    }
    
}
//Use:
//CLGeocoder.openMapFromAddress(serviceList[indexPath.row].address)

extension Bool{
    mutating func toggal() {
        self = !self
    }
}

extension UIPageViewController {
    //https://stackoverflow.com/questions/22098493/how-do-i-disable-the-swipe-gesture-of-uipageviewcontroller
    
    func enableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = true
                break
            }
        }
    }
    
    func disableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
                break
            }
        }
    }
}


extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


//MARK:- MultiLanguage

enum MuliLanguage:String{
    case english = "English"
    case french = "French"
    case portuguese = "Portuguese"
    case italian = "italian"
}


enum MuliLangShortHand:String{
    case it = "it"
    case en = "en"
    case fr = "fr"
    case pt = "pt-PT"
    case base = "Base" //Defaull string file
}

extension Bundle{
    static func localizedString(languageType type: MuliLangShortHand, forKey key: String, value: String? = nil, table tableName: String? = nil) -> String{
        let path = self.main.path(forResource: type.rawValue, ofType: "lproj")!
        let bundal = Bundle(path: path)!
        return bundal.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension String {
    var localized: String {
        //return Bundle().localizedString(forKey: self, value: nil, table: nil)
        
        if UserData.shared.language.isEmpty{
            return Bundle.localizedString(languageType: .en, forKey: self)
        }else{
            print("Key:\(self)")
            let userLanguage = UserData.shared.language
            if userLanguage.caseInsensitiveCompare(string: MuliLanguage.french.rawValue){
                print("Value:\(Bundle.localizedString(languageType: .fr, forKey: self))")
                return Bundle.localizedString(languageType: .fr, forKey: self)
            }
            else if userLanguage.caseInsensitiveCompare(string: MuliLanguage.portuguese.rawValue){
                print("Value:\(Bundle.localizedString(languageType: .pt, forKey: self))")
                return Bundle.localizedString(languageType: .pt, forKey: self)
            }
            else if userLanguage.caseInsensitiveCompare(string: MuliLanguage.english.rawValue){
                print("Value:\(Bundle.localizedString(languageType: .en, forKey: self))")
                return Bundle.localizedString(languageType: .en, forKey: self)
            } else if userLanguage.caseInsensitiveCompare(string: MuliLanguage.italian.rawValue){
                print("Value:\(Bundle.localizedString(languageType: .it, forKey: self))")
                return Bundle.localizedString(languageType: .it, forKey: self)
            }
            else{
                print("Value:\(Bundle.localizedString(languageType: .base, forKey: self))")
                return Bundle.localizedString(languageType: .base, forKey: self)
            }
        }
        
        //        if UserData.shared.languageID.isEmpty{
        //            return Bundle.localizedString(languageType: .en, forKey: self)
        //        }
        //        else{
        //            switch UserData.shared.language {
        //            case MuliLanguage.french.rawValue:
        //                return Bundle.localizedString(languageType: .fr, forKey: self)
        //            case MuliLanguage.portuguese.rawValue:
        //                return Bundle.localizedString(languageType: .pt, forKey: self)
        //            default:
        //                return Bundle.localizedString(languageType: .en, forKey: self)
        //            }
        //        }
        
    }
}

//func localizedString(key: String) -> String {
//    let isLang: String? = UserDefaults.standard.string(forKey: "IS_Lang")
//    if (isLang == "French") {
//        let path = Bundle.main.path(forResource: "fr", ofType: "lproj")
//        let bundal = Bundle.init(path: path!)! as Bundle
//        return bundal.localizedString(forKey: key, value: nil, table: nil)
//    }else if(isLang == "Portuguese"){
//        let path = Bundle.main.path(forResource: "pt-PT", ofType: "lproj")
//        let bundal = Bundle.init(path: path!)! as Bundle
//        return bundal.localizedString(forKey: key, value: nil, table: nil)
//    }else {
//        let path = Bundle.main.path(forResource: "en", ofType: "lproj")
//        let bundal = Bundle.init(path: path!)! as Bundle
//        return bundal.localizedString(forKey: key, value: nil, table: nil)
//    }
//}

extension String{
    static func parseNumberToString(dictionary dic:[String:Any], key:String) -> String {
        if dic[key] as? String != nil{
            return dic[key] as! String
        }
        else if dic[key] as? Int != nil{
            return String(dic[key] as? Int ?? 0)
        }
        else if dic[key] as? Float != nil{
            return String(dic[key] as? Float ?? 0)
        }
        else if dic[key] as? Double != nil{
            return String(dic[key] as? Double ?? 0)
        }
        else{
            return "0"
        }
    }
}

//https://stackoverflow.com/questions/30214519/add-a-string-property-to-a-uibutton-in-swift
extension UIView {
    private struct AssociatedKeys {
        static var DescriptiveName = ""//"nsh_DescriptiveName"
    }
    
    @IBInspectable var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}

extension String{
    mutating func setNotAvailable(){
        if self.isEmpty{
            self = "N/A".localized
        }
    }
}

extension URL{
    func getThumbnailFromVideo() -> UIImage?{
        do {
            let asset = AVURLAsset(url: self , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            print(thumbnail)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getDataAndFileNameBasedOnURL() -> (fileData:Data, fileName:String) {
        print("The Url is : \(self)")
        //let fileNameWithoutExtension = self.pathExtension//deletingPathExtension().lastPathComponent
        //print("fileNameWithoutExtension: \(fileNameWithoutExtension)")
        do {
            let data = try Data(contentsOf: self)
            //print("data=\(data)")
            let fileName = self.lastPathComponent
            //print(fileName)
            return (data, fileName)
        }
        catch {/* error handling here */
            return (Data(), "")
        }
    }
}

extension UIWindow {
    func setTheamColor(color: UIColor) {
        self.tintColor = color
    }
}

func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(item(), separator:separator, terminator: terminator)
    #endif
}

extension Int{
    static func randomInt(min: Int, max: Int) -> Int {
        if max < min { return min }
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}

//https://stackoverflow.com/questions/24132399/how-does-one-make-random-number-between-range-for-arc4random-uniform
extension Collection {
    private func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    func randomItem() -> Self.Iterator.Element {
        let count = distance(from: startIndex, to: endIndex)
        let roll = randomNumber(inRange: 0...count-1)
        return self[index(startIndex, offsetBy: roll)]
    }
}

//https://stackoverflow.com/questions/31363216/set-the-maximum-character-length-of-a-uitextfield-in-swift
//private var __maxLengths = [UITextField: Int]()
//extension UITextField {
//    @IBInspectable var maxLength: Int {
//        get {
//            guard let l = __maxLengths[self] else {
//                return 50 // (global default-limit. or just, Int.max)
//            }
//            return l
//        }
//        set {
//            __maxLengths[self] = newValue
//            addTarget(self, action: #selector(fix), for: .editingChanged)
//        }
//    }
//    @objc func fix(textField: UITextField) {
//        let t = textField.text
//        textField.text = t?.safelyLimitedTo(length: maxLength)
//    }
//}

extension String{
    mutating func safelyLimitedTo(length n: Int)/*->String*/ {
        if (self.count <= n) {
            /*return self*/
        }else{
            /*return*/ self = String( Array(self).prefix(upTo: n) )
        }
    }
}
//Use:
/*txtFirstNm.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
 @objc func textFieldDidChange(_ textField: UITextField) {
 textField.text?.safelyLimitedTo(length: 20)
 }
 */


//https://stackoverflow.com/questions/41646542/how-do-you-compare-just-the-time-of-a-date-in-swift?rq=1
class Time: Comparable, Equatable {
    init(_ date: Date) {
        //get the current calender
        let calendar = Calendar.current
        
        //get just the minute and the hour of the day passed to it
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60
        
        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        hour = dateComponents.hour!
        minute = dateComponents.minute!
    }
    
    init(_ hour: Int, _ minute: Int) {
        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = hour * 3600 + minute * 60
        
        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        self.hour = hour
        self.minute = minute
    }
    
    var hour : Int
    var minute: Int
    
    var date: Date {
        //get the current calender
        let calendar = Calendar.current
        
        //create a new date components.
        var dateComponents = DateComponents()
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return calendar.date(byAdding: dateComponents, to: Date())!
    }
    
    /// the number or seconds since the beggining of the day, this is used for comparisions
    private let secondsSinceBeginningOfDay: Int
    
    //comparisions so you can compare times
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay == rhs.secondsSinceBeginningOfDay
    }
    
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay < rhs.secondsSinceBeginningOfDay
    }
    
    static func <= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay <= rhs.secondsSinceBeginningOfDay
    }
    
    
    static func >= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay >= rhs.secondsSinceBeginningOfDay
    }
    
    
    static func > (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay > rhs.secondsSinceBeginningOfDay
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
}

extension String{
    func convertDate(dateFormate : String) -> Date? {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = dateFormate
        return dateFormator.date(from: self)
    } 
}

extension URL {
    func removeFile() {
        if FileManager.default.fileExists(atPath: self.path){
            do {
                try FileManager.default.removeItem(at: self)
                print("file deleted at: \(self.path)")
            }
            catch(let error) {
                print("file Can't deleate at: \(self.path)")
                print(error.localizedDescription)
            }
        }
    }
}

extension HTTPCookieStorage{
    static func clearCookieof(name:String = "linkedin"){
        let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies {
            for cookie in cookies {
                print("cookie.domain:\(cookie.domain)")
                if cookie.domain.contains(name) {
                    cookieStorage.deleteCookie(cookie)
                }
            }
        }
    }
}

extension Data{
    //https://stackoverflow.com/questions/37580015/how-to-access-file-included-in-app-bundle-in-swift
    
    private func createFileInDocumentDirectory(name: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let fileURL = documentsDirectory.appendingPathComponent(name/*"YourFile.extension"*/)
            do {
                let fileExists = try fileURL.checkResourceIsReachable()
                if fileExists {
                    fileURL.removeFile()
                    writeFile(fileURL: fileURL)
                    print("File exists")
                } else {
                    print("File does not exist, create it")
                    writeFile(fileURL: fileURL)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func writeFile(fileURL: URL) {
        do {
            try self.write(to: fileURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension String {
    func convertJSONStringToDictionary() -> [String: Any]? {
        guard let data = self.data(using: .utf8/*, allowLossyConversion: false*/) else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: [/*.mutableContainers*/]) as? [String: Any]
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}


extension String {
    func strippingHTML() -> String {
        var result = self
        while let range = result.range(of: "<[^>]+>", options: .regularExpression) {
            result.removeSubrange(range)
        }
        return result
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .removingPercentEncodingSafe()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Decodes URL/form-encoding: + → space, %XX → character (e.g. %27 → ', %C3%A8 → è).
    /// Returns the original string if decoding fails.
    func removingPercentEncodingSafe() -> String {
        let plusDecoded = self.replacingOccurrences(of: "+", with: " ")
        return plusDecoded.removingPercentEncoding ?? plusDecoded
    }
}

extension Dictionary{
    func dictionryToJsonString() -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self)
        return String(data: jsonData, encoding: .utf8) ?? "{}"//String.Encoding.utf8.rawValue)
    }
}
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}


extension UIImage {
    func resizedImageWith(targetSize: CGSize) -> UIImage? {

        let imageSize = self.size
        let newWidth  = targetSize.width  / self.size.width
        let newHeight = targetSize.height / self.size.height
        var newSize: CGSize

        if(newWidth > newHeight) {
            newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
        } else {
            newSize = CGSize(width: imageSize.width * newWidth,  height: imageSize.height * newWidth)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)

        self.draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}



private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
               return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t: String = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}


extension Data {
    func getSizeInMB() -> Double {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self.count)).replacingOccurrences(of: ",", with: ".")
        if let double = Double(string.replacingOccurrences(of: " MB", with: "")) {
            return double
        }
        return 0.0
    }
}
