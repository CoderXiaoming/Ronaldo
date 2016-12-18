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


/*
 
 ///对外提供的类工厂方法
 class func instance() -> SAMStockViewController {
 return SAMStockViewController()
 }
 
 
 //MARK: - 其他方法
 fileprivate init() { //重写该方法，为单例服务
 super.init(nibName: nil, bundle: nil)
 }
 fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
 super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 override func loadView() {
 //从xib加载view
 view = Bundle.main.loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
 }
 
 */
