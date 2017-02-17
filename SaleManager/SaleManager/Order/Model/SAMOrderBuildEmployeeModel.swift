//
//  SAMOrderBuildEmployeeModel.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/16.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit
import MJExtension

class SAMOrderBuildEmployeeModel: NSObject {

    var employeeID = ""
    var name = ""
    
    //MARK: - 初始化数据模型
    class func setupModels() {
        let arr = SAMOrderBuildEmployeeModel.mj_objectArray(withKeyValuesArray: employeeArr)!
        employeeModelArr.addObjects(from: arr as [AnyObject])
    }
    
    //MARK: - 对外提供获取数据模型数组
    class func shareModelArr() -> NSMutableArray {
        return employeeModelArr
    }
    
    static let employeeModelArr = NSMutableArray()
    
    static let employeeArr = [["name": "徐啟容", "employeeID": "6"], ["name": "廖芬", "employeeID": "9"], ["name": "金安娜", "employeeID": "7"], ["name": "任君君", "employeeID": "11"], ["name": "廖芬", "employeeID": "9"], ["name": "任玉", "employeeID": "10"], ["name": "王超超", "employeeID": "18"], ["name": "梁茜", "employeeID": "19"], ["name": "任慧", "employeeID": "22"], ["name": "黎芳", "employeeID": "66"], ["name": "龙江萍", "employeeID": "49"], ["name": "贺红梅", "employeeID": "12"], ["name": "唐燕", "employeeID": "69"], ["name": "谭小峰", "employeeID": "35"], ["name": "余林浓", "employeeID": "32"]]
}
