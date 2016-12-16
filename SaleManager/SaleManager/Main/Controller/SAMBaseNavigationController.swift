//
//  SAMBaseNavigationController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMBaseNavigationController: UINavigationController {

    override class func initialize() {
        
        let navBar = UINavigationBar.appearance()
        
        //设置主标题属性
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 19)]
        
        //设置返回按钮颜色
        navBar.tintColor = UIColor.white
        
        navBar.setBackgroundImage(UIImage(named: "navbarBackgroundImage"), for: .default)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
