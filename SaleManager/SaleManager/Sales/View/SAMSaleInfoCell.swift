//
//  SAMSaleInfoCell.swift
//  SaleManager
//
//  Created by apple on 16/12/6.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMSaleInfoCell: UICollectionViewCell {

    ///接收的数据模型
    var saleOrderInfoModel: SAMSaleOrderInfoModel? {
        didSet{
            //设置客户名称
            if saleOrderInfoModel!.CGUnitName != "" {
                customerLabel.text = saleOrderInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置时间
            if saleOrderInfoModel!.startDate != "" {
                dateLabel.text = saleOrderInfoModel!.startDate
            }else {
                dateLabel.text = "---"
            }
            
            //设置订单编号
            if saleOrderInfoModel!.billNumber != "" {
                orderNumLabel.text = saleOrderInfoModel!.billNumber
            }else {
                orderNumLabel.text = "---"
            }
            
            //设置金额
            priceLabel.text = String(format: "%.1f元", saleOrderInfoModel!.actualMoney)
        }
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
