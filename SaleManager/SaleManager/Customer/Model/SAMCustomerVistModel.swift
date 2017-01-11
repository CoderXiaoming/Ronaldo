//
//  SAMCustomerVistModel.swift
//  SaleManager
//
//  Created by apple on 16/12/27.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerVistModel: NSObject {

    ///存放客户数据模型数组单例
    static let models = NSMutableArray()
    
    //MARK: - 对外提供的返回数据模型数组的类方法
    class func modelArr() -> NSMutableArray {
        return models
    }
    
    ///回访记录的id
    var id: String?
    ///最后回访日期
    var startDate: String?
    ///客户ID
    var CGUnitID: String?
    ///客户名称
    var CGUnitName: String?
    ///回访内容
    var strContent: String?
}
