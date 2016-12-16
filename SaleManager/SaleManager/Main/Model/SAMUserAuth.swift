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
    ///对应员工部门ID
    var deptID: String?
    
    ///单例
    static var user: SAMUserAuth?
    
    //MARK: - 对外提供单例的类方法
    class func shareUser() -> SAMUserAuth? {
        return user
    }
    
    //MARK: - 对外提供判断权限的方法
    class func checkAuth(_ authArr: [String]) -> Bool {
        for authStr in authArr {
            if !((user!.appPower!.contains(authStr))) {
                return false
            }
        }
        return true
    }
    
    //MARK: - 对外提供的类工厂方法
    class func auth(_ id: String?, employeeID: String?, appPower: String?, deptID: String?) -> SAMUserAuth {
        if user != nil {
            return user!
        }else {
            user = SAMUserAuth()
            user!.id = id
            user!.employeeID = employeeID
            user!.appPower = appPower?.components(separatedBy: "|")
            user!.deptID = deptID
            return user!
        }
    }
}
