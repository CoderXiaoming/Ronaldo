//
//  NSDate+Extension.swift
//  SaleManager
//
//  Created by apple on 16/12/6.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

extension NSDate {
    
    ///n天前后 前传true 后穿false
    func beforeOrAfter(days: Double, before: Bool) -> NSDate {
        
        //获取时间差
        var timeInterval = 60 * 60 * 24 * days
        timeInterval = before ? (-timeInterval) : timeInterval
        
        return NSDate(timeInterval: timeInterval, sinceDate: self)
    }
    
    ///获取yyyy-MM-dd字符串
    func yyyyMMddStr() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(self)
    }
}
