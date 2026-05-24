//
//  CustomControl.swift
//  TaskGator
//
//  Created by Nirav Sapariya on 06/04/18.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit

class WhiteBorderButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(loadUI), userInfo: nil, repeats: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func loadUI() {
        //backgroundColor = appColor.greenColor
        setTitleColor(Color.white, for: .normal)
        titleLabel?.font = RobotoFont.regular(with: (self.titleLabel?.font.pointSize)!)
        self.setRadius(self.bounds.height * 0.2, borderWidth: 1.0, color: Color.white)
    }
    
}

class GreenButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(loadUI), userInfo: nil, repeats: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func loadUI() {
        backgroundColor = Color.green.theam
        setTitleColor(Color.white, for: .normal)
        titleLabel?.font = RobotoFont.medium(with: (self.titleLabel?.font.pointSize)!)
        self.setRadius(self.bounds.height * 0.1)
    }
    
}

class OrangeBorderButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(loadUI), userInfo: nil, repeats: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func loadUI() {
        backgroundColor = .white
        setTitleColor(Color.Theme.purple, for: .normal)
        titleLabel?.font = RobotoFont.medium(with: (self.titleLabel?.font.pointSize)!)
        self.setRadius(self.bounds.height * 0.1)
    }
    
}



class UnderlineOrangeButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.01), target: self, selector: #selector(loadUI), userInfo: nil, repeats: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc private func loadUI() {
        
        setTitleColor(Color.Theme.orange, for: .normal)
        titleLabel?.font = RobotoFont.medium(with: (self.titleLabel?.font.pointSize)!)

        
        let yourAttributes:[NSAttributedString.Key:Any] = [NSAttributedString.Key.foregroundColor: Color.Theme.orange,
                             NSAttributedString.Key.font : RobotoFont.medium(with: (self.titleLabel?.font.pointSize)!),
                              NSAttributedString.Key.underlineStyle:1.0,]

        let attributedStr = NSMutableAttributedString(string: self.titleLabel?.text?.localized ?? "", attributes: yourAttributes)
        setAttributedTitle(attributedStr, for: UIControl.State())

    }
    
}
