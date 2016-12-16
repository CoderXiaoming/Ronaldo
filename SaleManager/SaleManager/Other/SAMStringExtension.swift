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
    func lxm_stringByTrimmingWhitespace() -> String? {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    //MARK: - 判断是不是纯数字
    func lxm_stringisWholeNumber() -> Bool {
        if self == "" {
            return false
        }
        let str = trimmingCharacters(in: CharacterSet.decimalDigits)
        let nsStr = NSString(string: str)
        if nsStr.length > 0 {
            return false
        }
        return true
    }
    
    //MARK: - 判断最后一个是不是所传字符串，如果是就切掉
    func lxm_stringByTrimmingLastIfis(_ lastString: String) ->String {
    
        let str = NSString(string: self)
        let strLength = str.length
        
        let lastStr = str.substring(from: strLength - 1)
        
        if lastStr == lastString {
            return str.substring(to: strLength - 1)
        }else {
            return self
        }
        
    }
}

















