//
//  SAMStockViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockViewController: UIViewController {

    //MARK: - xib链接约束属性
    ///搜索框顶部与控制View的距离
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    ///stockView顶部与搜索框底部的距离
    @IBOutlet weak var stockVTop_searchBar_space: NSLayoutConstraint!
    
    //MARK: - xib链接控件
    @IBOutlet weak var allStockView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var warrningLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicaterView: UIView!
    
    //从XIB加载view
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化UI
        setupUI()
    }

    //MARK: - 初始化UI
    private func setupUI() {
        title = "库存查询"
        view.backgroundColor = UIColor.whiteColor()
        
        //设置导航栏右边的所有选项
        setupRightNavBarItems()
        
        //添加搜索框上部间距
        searchBarTopConstraint.constant = navigationController!.navigationBar.frame.maxY
    }
    
    //MARK: - 设置导航栏右边所有的按钮
    private func setupRightNavBarItems() {
        let nameScanBtn = UIButton()
        nameScanBtn.setImage(UIImage(named: "nameScan_nav"), forState: .Normal)
        nameScanBtn.sizeToFit()
        nameScanBtn.addTarget(self, action: #selector(SAMStockViewController.nameScanBtnClick), forControlEvents: .TouchUpInside)
        let codeScanBtn = UIButton()
        codeScanBtn.setImage(UIImage(named: "codeScan_nav"), forState: .Normal)
        codeScanBtn.sizeToFit()
        codeScanBtn.addTarget(self, action: #selector(SAMStockViewController.codeScanBtnClick), forControlEvents: .TouchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: codeScanBtn), UIBarButtonItem(customView: nameScanBtn)]
    }
    
    //MARK: - 总库存按钮点击
    func nameScanBtnClick() {
        UIView.animateWithDuration(0.6) {
            self.searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.maxY - self.searchBar.bounds.height
            self.stockVTop_searchBar_space.constant = -(self.allStockView.bounds.height)
            self.view.layoutIfNeeded()
        }
        
    }
    //MARK: - 二维码按钮点击
    func codeScanBtnClick() {
        UIView.animateWithDuration(0.6) {
            self.searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.maxY
            self.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
