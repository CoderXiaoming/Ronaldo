//
//  SAMLoginTextField.swift
//  SaleManager
//
//  Created by apple on 16/11/12.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
//该类是提供给登录界面使用,也控其他界面使用
class SAMLoginTextField: UITextField {

    override func becomeFirstResponder() -> Bool {
        setValue(textColor, forKeyPath: "_placeholderLabel.textColor")
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setValue(UIColor.lightGray, forKeyPath: "_placeholderLabel.textColor")
        return super.resignFirstResponder()
    }
    
    //MARK: - 设置leftView左边距
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var frame = super.leftViewRect(forBounds: bounds)
        frame.origin.x = 5
        return frame
    }
}
