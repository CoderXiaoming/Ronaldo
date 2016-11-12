//
//  SAMLoginTextField.swift
//  SaleManager
//
//  Created by apple on 16/11/12.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMLoginTextField: UITextField {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self .resignFirstResponder()
        tintColor = textColor
    }

    override func becomeFirstResponder() -> Bool {
        setValue(textColor, forKeyPath: "_placeholderLabel.textColor")
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setValue(UIColor.lightGrayColor(), forKeyPath: "_placeholderLabel.textColor")
        return super.resignFirstResponder()
    }
    
}
