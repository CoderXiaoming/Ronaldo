//
//  SAMCustomerCollectionCell.swift
//  SaleManager
//
//  Created by apple on 16/11/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerCollectionCell: UICollectionViewCell {

    ///接收的数据模型
    var customerModel: SAMCustomerModel? {
        didSet{
            //设置 customerLabel
            if customerModel?.CGUnitName != "" {
                customerLabel.text = customerModel?.CGUnitName
            }
            
            //设置 remarkLabel
            if customerModel?.memoInfo != "" {
                remarkLabel.text = customerModel?.memoInfo
            }
            
            //设置 phoneLabel
            if customerModel?.mobilePhone != "" {
                phoneLabel.text = customerModel?.mobilePhone
            }
            
            //设置 faxLabel
            if customerModel?.faxNumber != "" {
                faxLabel.text = customerModel?.faxNumber
            }
            
            //设置 telLabel
            if customerModel?.phoneNumber != "" {
                telLabel.text = customerModel?.phoneNumber
            }
            
            //设置 addLabel
            var addStr = ""
            if (customerModel?.province != "") && (customerModel?.city != "") {
                addStr = String(format: "(%@/%@)", (customerModel?.province)!, (customerModel?.city)!)
            }else if customerModel?.province != "" {
                addStr = String(format: "（%@）", (customerModel?.province)!)
            }else if customerModel?.city != "" {
                addStr = String(format: "（%@）", (customerModel?.city)!)
            }
            if customerModel?.address != "" {
                addStr = addStr + (customerModel?.address)!
            }
            if addStr != "" {
                addLabel.text = addStr
            }
        }
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
