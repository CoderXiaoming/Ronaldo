//
//  SAMSaleOrderDetailModel.swift
//  SaleManager
//
//  Created by apple on 16/12/7.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMSaleOrderDetailModel: NSObject {

    ///销售日期
    var startDate: String?
    ///客户名称
    var CGUnitName: String?
    ///仓库名称
    var storehouseName: String?
    ///备注
    var memoInfo: String?
    ///明细项金额累计
    var totalMoney: String?
    ///运费金额
    var freightFee: String?
    ///其他金额（正负都有）
    var cutMoney: String?
    ///本单应收金额（实际金额）
    var actualMoney: String?
    ///本单应收余额（本单欠款）
    var dueMoney: String?
    ///本单收款金额（已收）
    var receivedMoney: String?
    ///本单毛利
    var profits: String?
    ///收款方式
    var moneyMode: String?
    ///收款账户
    var accountName: String?
    ///业务员
    var employeeName: String?
    ///拼包地址
    var PBAddress: String?
    ///货运公司
    var freightCompany: String?
    ///货运单号
    var freightNumber: String?
    
}
