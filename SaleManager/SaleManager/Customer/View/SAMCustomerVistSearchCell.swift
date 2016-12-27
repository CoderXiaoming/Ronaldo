//
//  SAMCustomerVistSearchCell.swift
//  SaleManager
//
//  Created by apple on 16/12/28.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerVistSearchCell: UITableViewCell {

    ///接收的数据模型
    var vistModel: SAMCustomerVistModel? {
        didSet{
            //设置 客户名称
            if vistModel?.CGUnitName != "" {
                customerLabel.text = vistModel?.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置 日期
            if vistModel?.startDate != "" {
                dateLabel.text = vistModel?.startDate
            }else {
                dateLabel.text = "---"
            }
            
            //设置 回访内容
            if vistModel?.strContent != "" {
                contentLabel.text = vistModel?.strContent
            }else {
                contentLabel.text = "---"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
}
