//
//  SAMBaseNavigationController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMBaseNavigationController: UINavigationController {

    //MARK: - 类初始化设置initialize
    override class func initialize() {
        
        let navBar = UINavigationBar.appearance()
        
        //设置主标题属性
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 60 / 255.0, green: 60 / 255.0, blue: 60 / 255.0, alpha: 1.0), NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        
        //设置返回按钮颜色
        navBar.tintColor = UIColor(red: 75 / 255.0, green: 75 / 255.0, blue: 75 / 255.0, alpha: 1.0)
        
        //设置背景图片
        navBar.setBackgroundImage(UIImage(named: "navbarBackgroundImage"), for: .default)
    }

    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
