//
//  SAMForSaleModel.swift
//  SaleManager
//
//  Created by apple on 16/12/26.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMForSaleModel: NSObject {

    ///产品编号ID
    var productID = "" {
        didSet{
            productID = ((productID == "") ? "---" : productID)
        }
    }
    ///客户名称
    var CGUnitName = "" {
        didSet{
            CGUnitName = ((CGUnitName == "") ? "---" : CGUnitName)
        }
    }
    ///产品编号名称
    var productIDName = "" {
        didSet{
            productIDName = ((productIDName == "") ? "---" : productIDName)
        }
    }

    ///订单单号
    var orderBillNumber = "" {
        didSet{
            orderBillNumber = ((orderBillNumber == "") ? "---" : orderBillNumber)
        }
    }
    ///产品编号单位
    var unit = ""
    ///数量
    var meter = ""
    ///扫码人
    var employeeName = "" {
        didSet{
            employeeName = ((employeeName == "") ? "---" : employeeName)
        }
    }
    
    //MARK: - 辅助属性
    let orderStateImage = UIImage(named: "indicater_forSale_selected")
}
