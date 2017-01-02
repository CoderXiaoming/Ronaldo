//
//  SAMProductRankListModel.swift
//  SaleManager
//
//  Created by apple on 17/1/2.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMProductRankListModel: NSObject {

    ///客户名称
    var CGUnitName = "" {
        didSet{
            CGUnitName = ((CGUnitName == "") ? "---" : CGUnitName)
        }
    }
    ///客户型号销售数量汇总
    var countM = 0.0
}
