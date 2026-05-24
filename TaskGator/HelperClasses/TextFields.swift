//
//  TextFields.swift
//


import Foundation
import UIKit

class RobotoRegular14TextField: UITextField, UITextFieldDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        self.setupUI()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        self.setupUI()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//            if action == #selector(UIResponderStandardEditActions.paste(_:)) ||   {
//                return false
//            }
//            return super.canPerformAction(action, withSender: sender)
        return false
    }
    
    private func setupUI() {
        
        
        //Basic texfield Setup
        self.borderStyle = .none
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor(red: 220.0/255.0, green: 225.0/255.0, blue: 226.0/255.0, alpha: 1.0).cgColor


        self.setView(.left, space: 15)
        self.setView(.right, space: 15)
        
        //To apply font and text color
        self.font = RobotoFont.regular(with: 14)
        self.textColor = .black
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: Color.Theme.placeholder])
//        self.setRadius(self.layer.cornerRadius, borderWidth: 1, color: .lightGray)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    
    enum ViewType {
        case left, right
    }
    
    func setView(_ type: ViewType, with view: UIView) {
        if type == ViewType.left {
            leftView = view
            leftViewMode = .always
        } else if type == .right {
            rightView = view
            rightViewMode = .always
        }
    }
    
    @discardableResult
    func setView(_ view: ViewType, title: String, space: CGFloat = 0) -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50, height: frame.height)
        button.setTitle(title, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: space, bottom: 4, right: space)
        button.sizeToFit()
        setView(view, with: button)
        return button
        
        //        let button = UIButton(type: .custom)
        //        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height))
        //        containerView.addSubview(button)
        //        containerView.backgroundColor = UIColor.red
        //        button.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        //        button.setTitle(title, for: .normal)
        //        setView(view, with: containerView)
        //        return button
    }
    
    func setView(_ view: ViewType, normalImage: UIImage?, selectedImage: UIImage?) -> UIButton {
        let button = UIButton()
        let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.height, height: self.frame.height))
        containerView.addSubview(button)
        button.frame = CGRect(x: self.frame.height/4, y: self.frame.height/4, width: self.frame.height/2, height: self.frame.height/2)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.imageView!.contentMode = .scaleAspectFit
        setView(view, with: containerView)
        return button
    }
    
    @discardableResult
    func setView(_ view: ViewType, space: CGFloat) -> UIView {
        let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: space, height: frame.height))
        setView(view, with: spaceView)
        return spaceView
    }
    
    func toggleSecure() {
        isSecureTextEntry = !isSecureTextEntry
    }
    
    func rightViewImage(frame:CGRect, image:UIImage?) {
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        let imgView = UIImageView()
        imgView.frame = view.bounds //CGRect(x: -10, y: 5, width:15, height:15)//CGRect(x: 0, y: 0, width: 15, height: 15)
        imgView.image = image
        imgView.contentMode = .center
        view.addSubview(imgView)
        self.rightView = view
        self.rightViewMode = UITextField.ViewMode.always
    }
    
}


class RightViewArrowTextField: UITextField {
    var rightButton: UIButton?
    var rightViewImage : UIImage? {
        didSet {
            updateRightView()
        }
    }
    
    var leftButton: UIButton?
    var leftViewImage : UIImage? {
        didSet {
            updateLeftView()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupUI()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        //Basic texfield Setup
        self.borderStyle = .none
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor(red: 220.0/255.0, green: 225.0/255.0, blue: 226.0/255.0, alpha: 1.0).cgColor
        //To apply corner radius

        self.setView(.left, space: 15)
        self.setView(.right, space: 15)
        
        //To apply font and text color
        self.font = RobotoFont.regular(with: 14)
        self.textColor = .black
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: Color.Theme.placeholder])



    }
    
    private func updateRightView() {

    rightButton = self.setView(.right, normalImage: rightViewImage, selectedImage: rightViewImage)

    }
    
    private func updateLeftView() {

    leftButton = self.setView(.left, normalImage: leftViewImage, selectedImage: leftViewImage)

    }
 
 
}
