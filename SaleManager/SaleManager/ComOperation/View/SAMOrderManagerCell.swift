//
//  SAMOrderManagerCell.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderManagerCell: UICollectionViewCell {

    ///接收的数据模型
    var orderInfoModel: SAMOrderModel? {
        didSet{
            //设置客户名称
            if orderInfoModel!.CGUnitName != "" {
                customerLabel.text = orderInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置时间
            if orderInfoModel!.startDate != "" {
                dateLabel.text = orderInfoModel!.startDate
            }else {
                dateLabel.text = "---"
            }
            
            //设置订单编号
            if orderInfoModel!.billNumber != "" {
                orderNumLabel.text = orderInfoModel!.billNumber
            }else {
                orderNumLabel.text = "---"
            }
            
            //设置备注
            if orderInfoModel!.memoInfo != "" {
                remarkLabel.text = orderInfoModel!.memoInfo
            }else {
                remarkLabel.text = "---"
            }
            
            //设置订单状态
            print(orderInfoModel!.orderStatus)
            if orderInfoModel!.orderStatus == "未开单" {
                orderStateImageView.image = UIImage(named: "orderManageNotCompletion")
            }else {
                orderStateImageView.image = UIImage(named: "orderManageCompletion")
            }
        }
    }
    
    
    //MARK: - XIB链接属性
    @IBOutlet weak var orderStateImageView: UIImageView!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
