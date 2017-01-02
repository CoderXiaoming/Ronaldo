//
//  SAMCustomerRankModel.swift
//  SaleManager
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerRankModel: NSObject {

    ///客户id
    var id = ""
    ///客户名称
    var CGUnitName = "" {
        didSet{
            CGUnitName = ((CGUnitName == "") ? "---" : CGUnitName)
        }
    }
    ///客户销售总金额
    var totalSellMoney = 0.0
}
