//
//  Labels.swift
//  bemyrider
//
//  Created by Jaymin on 22/03/22.
//  Copyright © 2022 NCT 24. All rights reserved.
//

import Foundation
import UIKit

class RobotoMedium14Label: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.medium(with: 14)
        self.textColor = Color.Theme.charcolGrey
    }
}

class RobotoRegular14OrangeLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.regular(with: 14)
        self.textColor = Color.Theme.orange
    }
}


class RobotoRegular12Label: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.regular(with: 12)
        self.textColor = Color.Theme.lightGray
    }
}

class RobotoLight12Label: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.regular(with: 12)
        self.textColor = Color.Theme.extraLightGray
    }
}

class RobotoMedium16Label: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.medium(with: 14)
        self.textColor = Color.Theme.charcolGrey
    }
}

class RobotoMedium16WhiteLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.medium(with: 14)
        self.textColor = .white
    }
}

class RobotoRegular12GrayLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    fileprivate func setupUI(){
        self.font =  RobotoFont.regular(with: 12)
        self.textColor = Color.Theme.charcolGrey
    }
}
