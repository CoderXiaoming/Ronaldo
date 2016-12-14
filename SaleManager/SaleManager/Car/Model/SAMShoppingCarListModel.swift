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
    var id: String?
    ///开始日期
    var startDate: String?
    ///产品编号ID
    var productID: String?
    ///匹数
    var countP: Int = 0
    ///米数
    var countM: Double = 0.0
    ///价格
    var price: Double = 0.0
    ///备注
    var memoInfo: String?
    ///登陆id
    var userID: String?
    ///产品编号名称
    var productIDName: String?
    ///二维码缩略图url
    var thumbUrl: String? {
        didSet{
            if thumbURL != "" {
                thumbURL = NSURL(string: thumbUrl!)
            }
        }
    }
    
    //MARK: - 附加属性
    ///缩略图1（主缩略图）链接
    var thumbURL: NSURL?
    
    ///记录当前数据是否被选中
    var selected: Bool = false
    
}
