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
    
    ///接收的相同二维码名称数据模型数组
    var sameCodeNameModels: NSMutableArray?

    //MARK: - 对外提供的类工厂方法
    class func instance(stockModel: SAMStockProductModel, sameCodeNameModels: NSMutableArray) -> SAMStockProductInfoController? {
        let vc = UIStoryboard(name: "SAMStockProductInfoController", bundle: nil).instantiateInitialViewController() as? SAMStockProductInfoController
        vc?.stockProductModel = stockModel
        vc?.sameCodeNameModels = sameCodeNameModels
        return vc
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //初始化UI
        setupUI()
    }
    
    ///初始化UI
    func setupUI() {
        
        //设置标题
        navigationItem.title = "产品信息"
        
        //设置产品图片
        if stockProductModel?.thumbUrl1 != "" {
            productImageVIew.sd_setImage(with: URL.init(string: stockProductModel!.thumbUrl1), placeholderImage: UIImage(named: "photo_loadding")!)
        }else {
            productImageVIew.image = UIImage(named: "photo_loadding")
        }
        
        //设置编号名称
        numberLabel.text = stockProductModel!.productIDName
        
        //设置花名
        huaMingLabel.text = stockProductModel!.productIDNameHM
        
        //设置大类
        categoryLabel.text = stockProductModel!.parentID
        
        //设置条码
        codeNumberLabel.text = stockProductModel!.codeName
        
        //设置规格
        rankLabel.text = stockProductModel!.specName
        
        //设置单位
        countUnitLabel.text = stockProductModel!.unit
        
        //设置单位
        remarkLabel.text = stockProductModel!.memoInfo
    }
    
    //MARK: - 用户点击事件处理
    func navbarBackBtnClick() {
        let _ = navigationController?.popViewController(animated: true)
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
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }else {
            return 10
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //点击图片Cell跳转
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageIndex = IndexPath(row: 0, section: 0)
        if indexPath == imageIndex {
            let productImageVC = SAMProductImageController.instance(stockModel: stockProductModel!, sameNameModels: sameCodeNameModels!)
            navigationController!.pushViewController(productImageVC, animated: true)
        }
    }
}
