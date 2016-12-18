//
//  SAMOrderBuildTitleModel.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderBuildTitleModel: NSObject {

    ///标题
    var cellTitle = ""
    ///内容
    var cellContent = ""
    
    //mark: - 对外提供的类工厂方法
    class func titleModel(title: String, content: String?) -> SAMOrderBuildTitleModel {
        let model = SAMOrderBuildTitleModel()
        model.cellTitle = title
        if content != nil {
            model.cellContent = content!
        }
        return model
    }
}
