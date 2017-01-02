//
//  SAMComOperationViewRankCell.swift
//  SaleManager
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMComOperationViewRankCell: UICollectionViewCell {

    ///接收的客户排行数据模型
    var customerRankModel: SAMCustomerRankModel? {
        didSet{
            if customerRankModel == nil {
                return
            }
            
            titleLabel.text = customerRankModel!.CGUnitName
            
            contentLabel.text = String(format: "%.1f元", customerRankModel!.totalSellMoney)
        }
    }
    
    ///接收的客户排行详情数据模型
    var customerRankListModel: SAMCustomerRankListModel? {
        didSet{
            if customerRankListModel == nil {
                return
            }
            
            //设置产品名
            titleLabel.text = customerRankListModel!.productIDName
            
            //设置米数
            contentLabel.text = String(format: "%.1f米", customerRankListModel!.countM)
        }
    }
    
    ///接收的产品排行数据模型
    var productRankModel: SAMProductRankModel? {
        didSet{
            if productRankModel == nil {
                return
            }
            
            titleLabel.text = productRankModel!.productIDName
            
            contentLabel.text = String(format: "%.1f米", productRankModel!.countM)
        }
    }
    
    ///接收的产品排行详情数据模型
    var productRankListModel: SAMProductRankListModel? {
        didSet{
            if productRankListModel == nil {
                return
            }
            
            titleLabel.text = productRankListModel!.CGUnitName
            
            contentLabel.text = String(format: "%.1f米", productRankListModel!.countM)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
}
