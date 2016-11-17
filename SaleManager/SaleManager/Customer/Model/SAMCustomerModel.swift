//
//  SAMCustomerModel.swift
//  SaleManager
//
//  Created by apple on 16/11/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerModel: NSObject {
    
    var id: String?
    ///客户拼音简记码
    var CGUnitBM: String?
    ///客户名称
    var CGUnitName: String?
    ///联系人
    var contactPerson: String?
    ///省份
    var province: String?
    ///城市
    var city: String?
    ///地址
    var address: String?
    ///手机
    var mobilePhone: String?
    ///固定电话
    var phoneNumber: String?
    ///传真
    var faxNumber: String?
    ///备注
    var memoInfo: String?
    ///部门
    var deptName: String?
    ///员工名
    var employeeName: String?
    
    override var description: String {
        return String.init(format: "id = %@ ~~~ CGUnitBM = %@ ~~~ CGUnitName = %@ ~~~ contactPerson = %@ ~~~ province = %@ ~~~ city = %@ ~~~ address = %@ ~~~ mobilePhone = %@ ~~~ phoneNumber = %@ ~~~ faxNumber = %@ ~~~ memoInfo = %@ ~~~ deptName = %@ ~~~ employeeName = %@", arguments: [id!, CGUnitBM!, CGUnitName!, contactPerson!, province!, city!, address!, mobilePhone!, phoneNumber!, CGUnitBM!, faxNumber!, memoInfo!, deptName!, employeeName!])
    }
}
