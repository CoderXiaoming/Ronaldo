//
//  SAMUserAuth.swift
//  SaleManager
//
//  Created by apple on 16/11/15.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMUserAuth: NSObject{
    ///登录名
    var id: String?
    ///对应员工ID
    var employeeID: String?
    ///权限字符串数组
    var appPower: [String]?
    
    ///单例
    static var user: SAMUserAuth?
    
    //MARK: - 对外提供单例的类方法
    class func shareUser() -> SAMUserAuth? {
        return user
    }
    
    //MARK: - 对外提供的类工厂方法
    class func auth(id: String?, employeeID: String?, appPower: String?) -> SAMUserAuth {
        if user != nil {
            return user!
        }else {
            user = SAMUserAuth()
            user!.id = id
            user!.employeeID = employeeID
            user?.appPower = appPower?.componentsSeparatedByString("|")
            return user!
        }
    }
    
    override var description: String {
        return String.init(format: "id = %@ ~~~ employID = %@ ~~~ appPower = %@", arguments: [id!, employeeID!, appPower!])
    }
}
