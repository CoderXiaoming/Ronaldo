//
//  UIColor+Extension.swift
//  SaleManager
//
//  Created by apple on 16/12/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

extension UIColor {
    
    //MARK: - 类方法对外提供随机色，alpha = 1
    class func randomColor() -> UIColor {
        
        return UIColor(red: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), green: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), blue: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), alpha: 1.0)
    }
}
