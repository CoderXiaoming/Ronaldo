//
//  SAMMainTabBarController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
class SAMMainTabBarController: UITabBarController {

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化UI
        setupUI()
        
        //添加所有控制器
        addAllControllers()
        
        //清楚缓存
        SAMCacheClearer.clearCaches()
    }
    
    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        //初始化设置背景图片
        let navbar = UITabBar.appearance()
        navbar.backgroundImage = UIImage(named: "tabbarBackgroundcolorImage")
        
        //初始化设置所有tabBarItem正常状态和选中时的颜色
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 22 / 255.0, green: 122 / 255.0, blue: 189 / 255.0, alpha: 1.0)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 52 / 255.0, green: 52 / 255.0, blue: 52 / 255.0, alpha: 1.0)], for: UIControlState())
    }
    
    //MARK: - 添加所有控制器
    fileprivate func addAllControllers() {
        
        //首页控制器
        let homeVC = SAMBaseNavigationController(rootViewController: SAMComOperationController.instance())
        homeVC.view.backgroundColor = UIColor.white
        addOnmeController(homeVC, tabImg: UIImage(named: "home_tabar")!, selectedImg: UIImage(named: "home_tabar_highlighted")!, tabTile: "首页")
        
        let stockVC = SAMBaseNavigationController(rootViewController: SAMStockViewController.instance(shoppingCarListModel: nil, type: .normal))
        addOnmeController(stockVC, tabImg: UIImage(named: "stock_tabbar")!, selectedImg: UIImage(named: "stock_tabbar_highlighted")!, tabTile: "库存")
        
        let codeVC = SAMBaseNavigationController(rootViewController: LXMCodeViewController.instance())
        addOnmeController(codeVC, tabImg: UIImage(named: "QRcode_tabar")!, selectedImg: UIImage(named: "QRcode_tabar_highlighted")!, tabTile: "扫码")
        
        let carVC = SAMBaseNavigationController(rootViewController: SAMShoppingCarController.sharedInstanceMain())
        addOnmeController(carVC, tabImg: UIImage(named: "shoppingCar_tabar")!, selectedImg: UIImage(named: "shoppingCar_tabar_highlighted")!, tabTile: "购物车")
        
        let customerVC = SAMBaseNavigationController(rootViewController: SAMCustomerViewController.instance(controllerType: .Normal))
        addOnmeController(customerVC, tabImg: UIImage(named: "customer_tabar")!, selectedImg: UIImage(named: "customer_tabar_highlighted")!, tabTile: "客户")
    }
    
    //MARK: - 单独添加一个控制器
    fileprivate func addOnmeController(_ controller: UIViewController, tabImg: UIImage, selectedImg: UIImage, tabTile: String) {
        addChildViewController(controller)
        controller.tabBarItem = UITabBarItem(title: tabTile, image: tabImg, selectedImage: selectedImg)
    }
    
    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
