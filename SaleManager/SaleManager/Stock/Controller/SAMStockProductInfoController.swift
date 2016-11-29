//
//  SAMStockProductInfoController.swift
//  SaleManager
//
//  Created by apple on 16/11/28.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

class SAMStockProductInfoController: UITableViewController {

    ///接收的数据模型
    var stockProductModel: SAMStockProductModel?

    
    class func infoVC() -> SAMStockProductInfoController? {
        return UIStoryboard(name: "SAMStockProductInfoController", bundle: nil).instantiateInitialViewController() as? SAMStockProductInfoController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置标题
        navigationItem.title = "产品信息"
        
        //设置返回按钮
        let backButton = UIButton()
        backButton.sizeToFit()
        backButton.setImage(UIImage(named: "navbarBack"), forState: .Normal)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0)
        
        backButton.addTarget(self, action: #selector(SAMStockProductInfoController.navbarBackBtnClick), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //初始化UI
        setupUI()
    }
    
    //MARK: - 初始化UI
    func setupUI() {
        print(tabBarController?.tabBar.bounds)
        //设置产品图片
        if stockProductModel?.thumbURL1 != nil {
            productImageVIew.sd_setImageWithURL(stockProductModel!.thumbURL1!, placeholderImage: UIImage(named: "firstLogo")!)
        }else {
            productImageVIew.image = UIImage(named: "temp")
        }
        
        //设置编号名称
        if stockProductModel!.productIDName != "" {
            numberLabel.text = stockProductModel!.productIDName
        }else {
            numberLabel.text = "---"
        }
        
        //设置花名
        if stockProductModel!.productIDNameHM != "" {
            huaMingLabel.text = stockProductModel!.productIDNameHM
        }else {
            huaMingLabel.text = "---"
        }
        
        //TODO: 设置大类
        //设置大类
        if stockProductModel!.parentID != "" {
            categoryLabel.text = stockProductModel!.parentID
        }else {
            categoryLabel.text = "---"
        }
        
        //设置条码
        if stockProductModel!.codeName != "" {
            codeNumberLabel.text = stockProductModel!.codeName
        }else {
            codeNumberLabel.text = "---"
        }
        
        //设置规格
        if stockProductModel!.specName != "" {
            rankLabel.text = stockProductModel!.specName
        }else {
            rankLabel.text = "---"
        }
        
        //设置单位
        if stockProductModel!.unit != "" {
            countUnitLabel.text = stockProductModel!.unit
        }else {
            countUnitLabel.text = "---"
        }
        
        //设置单位
        if stockProductModel!.memoInfo != "" {
            remarkLabel.text = stockProductModel!.memoInfo
        }else {
            remarkLabel.text = "---"
        }
    }

    //MARK: - 用户点击事件处理
    func navbarBackBtnClick() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var productImageVIew: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var huaMingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var codeNumberLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var countUnitLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
}

//MARK: - 代理方法
extension SAMStockProductInfoController {
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }else {
            return 10
        }
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
