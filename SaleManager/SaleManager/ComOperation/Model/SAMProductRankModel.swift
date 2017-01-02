//
//  SAMProductRankModel.swift
//  SaleManager
//
//  Created by apple on 17/1/2.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMProductRankModel: NSObject {

    ///产品型号id
    var id = ""
    /// 产品编号名称
    var productIDName = "" {
        didSet{
            productIDName = ((productIDName == "") ? "---" : productIDName)
        }
    }
    ///销售数量汇总
    var countM = 0.0
    
}
