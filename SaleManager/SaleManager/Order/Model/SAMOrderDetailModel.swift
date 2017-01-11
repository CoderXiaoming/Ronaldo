//
//  SAMOrderDetailModel.swift
//  SaleManager
//
//  Created by apple on 16/12/20.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderDetailModel: NSObject {

    ///订单主项id
    var id = ""
    ///客户名称
    var CGUnitName = ""
    ///备注信息
    var memoInfo = ""
    ///优惠金额
    var cutMoney = ""
    ///其他金额
    var otherMoney = ""
    ///总金额
    var totalMoney = ""
    ///已收定金
    var receiveMoney = ""
    ///日期
    var startDate = ""
    ///开单人
    var userName = ""
    ///订单状态（已开单，未开单）
    var orderStatus = ""
    ///是否已经生成码单（是，否）
    var isMakeBill = ""
    ///是否同意发货，手机可见（是，否）
    var isAgreeSend = ""
    
}
