//
//  SAMSaleOrderInfoModel.swift
//  SaleManager
//
//  Created by apple on 16/12/7.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMSaleOrderInfoModel: NSObject {

    ///销售日期
    var startDate = "" {
        didSet{
            startDate = ((startDate == "") ? "---" : startDate)
        }
    }
    ///销售金额
    var actualMoney = 0.0
    ///客户名称
    var CGUnitName = "" {
        didSet{
            CGUnitName = ((CGUnitName == "") ? "---" : CGUnitName)
        }
    }
    ///销售单号
    var billNumber = "" {
        didSet{
            billNumber = ((billNumber == "") ? "---" : billNumber)
        }
    }
    
    //MARK: - 辅助属性
    let orderStateImage = UIImage(named: "indicater_saleHistory_selected")
}
