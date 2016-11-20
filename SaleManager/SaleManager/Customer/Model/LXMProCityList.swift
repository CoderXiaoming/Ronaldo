//
//  LXMProCityList.swift
//  SaleManager
//
//  Created by apple on 16/11/20.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class LXMProCityList: NSObject {

    ///省份
    var name: String?
    ///城市
    var cities: [String]?
    
    //MARK: - 对外提供的类方法
    class func listWithDict(dict: [String: String]) -> LXMProCityList {
        let list = LXMProCityList()
        list.setValuesForKeysWithDictionary(dict)
        return list
    }
    
}
