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
    }
    
    //MARK: - 初始化UI
    private func setupUI() {
        
        let navbar = UITabBar.appearance()
        
        navbar.backgroundImage = UIImage(named: "tabbarBackgroundcolorImage")
        
        //初始化设置所有tabBarItem正常状态和选中时的颜色
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: mainColor_green], forState: .Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: .Normal)
    }
    
    //MARK: - 添加所有控制器
    private func addAllControllers() {
        
        let homeVC = SAMBaseNavigationController(rootViewController: SAMHomeViewController())
        addOnmeController(homeVC, tabImg: UIImage(named: "visitManagertabbar")!, selectedImg: UIImage(named: "visitManager_selected")!, tabTile: "首页")
        
        let stockVC = SAMBaseNavigationController(rootViewController: SAMStockViewController())
        addOnmeController(stockVC, tabImg: UIImage(named: "stock")!, selectedImg: UIImage(named: "stock_selected")!, tabTile: "库存")
        
        let codeVC = SAMBaseNavigationController(rootViewController: LXMCodeViewController())
        addOnmeController(codeVC, tabImg: UIImage(named: "codeScan")!, selectedImg: UIImage(named: "codeScan_selected")!, tabTile: "扫码")
        
        let carVC = SAMBaseNavigationController(rootViewController: SAMShoppingCarController.sharedInstance())
        addOnmeController(carVC, tabImg: UIImage(named: "shoppingCar")!, selectedImg: UIImage(named: "shoppingCar_selected")!, tabTile: "购物车")
        
        let customerVC = SAMBaseNavigationController(rootViewController: SAMCustomerViewController())
        addOnmeController(customerVC, tabImg: UIImage(named: "customer")!, selectedImg: UIImage(named: "customer_selected")!, tabTile: "客户")
    }
    
    //MARK: - 单独添加一个控制器
    private func addOnmeController(controller: UIViewController, tabImg: UIImage, selectedImg: UIImage, tabTile: String) {
        addChildViewController(controller)
        controller.tabBarItem = UITabBarItem(title: tabTile, image: tabImg, selectedImage: selectedImg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
