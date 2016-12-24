//
//  SAMOwedInfoModel.swift
//  SaleManager
//
//  Created by apple on 16/12/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOwedInfoModel: NSObject {


    ///缺货记录的id
    var id: String?
    ///起始日期
    var startDate: String?
    ///交货日期
    var endDate: String?
    ///客户ID
    var CGUnitID: String?
    ///客户名称
    var CGUnitName: String?
    ///产品编号ID
    var productID: String?
    ///产品编号名称
    var productIDName: String?
    ///缺货数量
    var countM = 0.0
    ///缺货匹数
    var countP = 0
    ///备注
    var memoInfo: String?
    ///状态：欠货中，已完成，已删除
    var iState: String?
    
}
