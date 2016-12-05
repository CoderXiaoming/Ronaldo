//
//  SAMHomeViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMHomeViewController: UIViewController {

    ///所有界面上展示的按钮的模型数据
    let btnModel = [
        ["title": "客户资料", "image": "customer", "selector" : "customerBtnClick"],
                    ["title": "库存查询", "image": "stock", "selector" : "stockBtnClick"],
                    ["title": "销售历史", "image": "saled", "selector" : "saleBtnClick"],
                    ["title": "订单管理", "image": "orderManage", "selector" : "orderBtnClick"],
                    ["title": "待售布匹", "image": "clothSale", "selector" : "clothSaleBtnClick"],
                    ["title": "缺货登记", "image": "outStock", "selector" : "outStockBtnClick"],
                    ["title": "客户销售排行", "image": "customerRank", "selector" : "customerRankBtnClick"],
                    ["title": "产品销售排行", "image": "productRank", "selector" : "productRankBtnClick"],
                    ["title": "客户回访管理", "image": "visitManager", "selector" : "visitManagerBtnClick"]
                    ]
    
    //MARK: - 重写init方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //添加子控件
        view.addSubview(buttonView)
    }
    
    private func setupUI() {
        //设置导航栏标题
        title = "首页"
        view.backgroundColor = UIColor.whiteColor()
    }

    //MARK: - 点击buttonView上按钮的处理
    func customerBtnClick() {
        print("customerBtnClick")
    }
    func stockBtnClick() {
        let btn = UIButton()
        btn.titleLabel?.backgroundColor = UIColor.whiteColor()
        btn.titleLabel?.clipsToBounds = true
    }
    func saleBtnClick() {
        print("saleBtnClick")
    }
    func orderBtnClick() {
        print("orderBtnClick")
    }
    func clothSaleBtnClick() {
        print("clothSaleBtnClick")
    }
    func outStockBtnClick() {
        print("outStockBtnClick")
    }
    func customerRankBtnClick() {
        print("customerRankBtnClick")
    }
    func productRankBtnClick() {
        print("productRankBtnClick")
    }
    func visitManagerBtnClick() {
        print("visitManagerBtnClick")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: - 懒加载集合
    private lazy var buttonView: UIView = {
        //设置frame各属性
        let buttonViewW = ScreenW
        let buttonViewH = buttonViewW * 0.7
        let btnView = UIView(frame: CGRect(x: 0, y: 0, width: buttonViewW, height: buttonViewH))
        
        //设置背景色
        btnView.backgroundColor = UIColor.grayColor()
        
        //添加所有按钮 
        //先初始化所有属性
        let count = self.btnModel.count
        let rows: CGFloat = 3
        let cols = CGFloat((count + 2) / 3)
        let margin: CGFloat = 2
        let btnW = (buttonViewW - (margin * (rows + 1))) / rows
        let btnH = (buttonViewH - (margin * (cols + 1))) / cols
        //for循环添加按钮 并设置各属性
        for i in 0...(count - 1) {
            let dict = self.btnModel[i] as [String: AnyObject]
            let imgName = dict["image"] as! String
            let selImgName = String(format: "%@_selected", imgName)
            let selector = Selector.init(dict["selector"] as! String)
            let title = dict["title"] as! String
            
            let x = (btnW + margin) * (CGFloat(i) % rows) + margin
            let y = (btnH + margin) * CGFloat(Int(i / Int(rows))) + margin
            
            let btn = SAMHomeButton(frame: CGRect(x: x, y: y, width: btnW, height: btnH))
            btn.backgroundColor = UIColor.whiteColor()
            btn.setTitle(title, forState: .Normal)
            btn.titleLabel?.font = UIFont.systemFontOfSize(15)
            btn.titleLabel?.backgroundColor = UIColor.whiteColor()
            btn.titleLabel?.clipsToBounds = true
            
            //设置普通状态
            btn.setImage(UIImage(named: imgName), forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            //设置高亮状态
            btn.setImage(UIImage(named: selImgName), forState: .Highlighted)
            btn.setTitleColor(mainColor_green, forState: .Highlighted)
            //设置点击事件
            btn.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
            btnView.addSubview(btn)
        }
        
        return btnView
    }()
    
    //无关紧要的方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
