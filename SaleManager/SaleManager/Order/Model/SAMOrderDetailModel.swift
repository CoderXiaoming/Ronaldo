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
    var id: String?
    ///客户名称
    var CGUnitName: String?
    ///备注信息
    var memoInfo: String?
    ///优惠金额
    var cutMoney: String?
    ///其他金额
    var otherMoney: String?
    ///总金额
    var totalMoney: String?
    ///已收定金
    var receiveMoney: String?
    ///日期
    var startDate: String?
    ///开单人
    var userName: String?
    ///订单状态（已开单，未开单）
    var orderStatus: String?
    ///是否已经生成码单（是，否）
    var isMakeBill: String?
    ///是否同意发货，手机可见（是，否）
    var isAgreeSend: String?
    
}
