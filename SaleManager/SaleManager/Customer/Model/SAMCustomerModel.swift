//
//  SAMCustomerModel.swift
//  SaleManager
//
//  Created by apple on 16/11/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerModel: NSObject {
    
    ///存放客户数据模型数组单例
    static let models = NSMutableArray()
    
    //MARK: - 对外提供的返回数据模型数组的类方法
    class func modelArr() -> NSMutableArray {
        return models
    }
    
    var id = ""
    ///客户拼音简记码
    var CGUnitBM = ""
    ///客户名称
    var CGUnitName = "" {
        didSet{
            CGUnitName = ((CGUnitName == "") ? "---" : CGUnitName)
        }
    }
    ///联系人
    var contactPerson = ""
    ///省份
    var province = ""
    ///城市
    var city = ""
    ///地址
    var address = ""
    ///手机
    var mobilePhone = "" {
        didSet{
            mobilePhone = ((mobilePhone == "") ? "---" : mobilePhone)
        }
    }
    ///固定电话
    var phoneNumber = "" {
        didSet{
            phoneNumber = ((phoneNumber == "") ? "---" : phoneNumber)
        }
    }
    ///传真
    var faxNumber = "" {
        didSet{
            faxNumber = ((faxNumber == "") ? "---" : faxNumber)
        }
    }
    ///备注
    var memoInfo = "" {
        didSet{
            memoInfo = ((memoInfo == "") ? "---" : memoInfo)
        }
    }
    ///部门
    var deptName = ""
    ///员工名
    var employeeName = ""
}
