//
//  SAMShoppingCarListModel.swift
//  SaleManager
//
//  Created by apple on 16/12/14.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMShoppingCarListModel: NSObject {

    ///购物车的id
    var id = ""
    ///开始日期
    var startDate = ""
    ///产品编号ID
    var productID = ""
    ///匹数
    var countP: Int = 0
    ///米数
    var countM: Double = 0.0
    ///价格
    var price: Double = 0.0
    ///备注
    var memoInfo = "" {
        didSet{
            memoInfo = ((memoInfo == "") ? "---" : memoInfo)
        }
    }
    ///登陆id
    var userID = ""
    ///产品编号名称
    var productIDName = "" {
        didSet{
            productIDName = ((productIDName == "") ? "---" : productIDName)
        }
    }
    ///二维码缩略图url
    var thumbUrl = ""
    
    //MARK: - 附加属性
    ///记录当前数据是否被选中
    var selected: Bool = false
    
    ///库存匹数
    var stockCountP: Int = 0
    ///库存米数
    var stockCountM: Double = 0.0
    
    ///提交订单记录的码数
    var countMA: Double {
        return countM / 0.9144
    }
    ///提交订单的总价格 米数✖️价格
    var countPrice: Double {
        return price * countM
    }
}
