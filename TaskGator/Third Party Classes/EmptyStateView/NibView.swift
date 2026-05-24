//
//  FromNib.swift
//  StateView
//

import UIKit

protocol NibViewProtocol: class {
    func commonInit()
}

class NibView: UIView, NibViewProtocol {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
    }
}
