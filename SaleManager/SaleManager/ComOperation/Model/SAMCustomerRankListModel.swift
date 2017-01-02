//
//  SAMCustomerRankListModel.swift
//  SaleManager
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerRankListModel: NSObject {

    ///产品id
    var productID = "" {
        didSet{
            productID = ((productID == "") ? "---" : productID)
        }
    }
    ///产品编号名称
    var productIDName = "" {
        didSet{
            productIDName = ((productIDName == "") ? "---" : productIDName)
        }
    }
    ///销售米数
    var countM = 0.0
    ///平均销售价格
    var avgPrice = 0.0
}
