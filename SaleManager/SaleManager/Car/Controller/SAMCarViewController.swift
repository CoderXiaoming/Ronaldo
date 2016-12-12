//
//  SAMCarViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCarViewController: UIViewController {

    ///单例
    private static let carViewVC: SAMCarViewController = SAMCarViewController()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - 对外提供的设置购物车数量的方法
    func addOrMinusProductCountOne(add: Bool) {
        
        //改变计数
        var count = badgeCount
        count = add ? count + 1 : count - 1
        
        //判断计数
        count = count > 0 ? count : 0
        
        //设置badgeValue
        let tabbarItem = tabBarController!.tabBar.items![3] as UITabBarItem
        if count == 0 {
            tabbarItem.badgeValue = nil
        }else {
            tabbarItem.badgeValue = String(format: "%d", count)
        }
        
        badgeCount = count
    }
    
    //MARK: - 属性懒加载
    /// 右上角数字
    private var badgeCount: Int = 0
    
    //MARK: - 其他方法
    //MARK: - 对外提供的提供单例
    class func sharedInstance() -> SAMCarViewController {
        return carViewVC
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
