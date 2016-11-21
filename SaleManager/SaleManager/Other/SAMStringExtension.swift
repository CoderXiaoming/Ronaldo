//
//  SAMStringExtension.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

extension String {
    
    //MARK: - 去掉字符串前后空白
    func stringByTrimmingWhitespace() -> String? {
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    //MARK: - 判断是不是纯数字
    func isWholeNumber() -> Bool {
        if self == "" {
            return false
        }
        let str = stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet())
        let nsStr = NSString(string: str)
        if nsStr.length > 0 {
            return false
        }
        return true
    }
}
