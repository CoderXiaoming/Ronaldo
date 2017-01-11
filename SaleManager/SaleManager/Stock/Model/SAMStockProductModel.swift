//
//  SAMStockProductModel.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockProductModel: NSObject {

    ///产品编号id
    var id = ""
    
    ///产品编号名称
    var productIDName = "" {
        didSet{
            productIDName = ((productIDName == "") ? "---" : productIDName)
        }
    }
    ///产品花名
    var productIDNameHM = "" {
        didSet{
            productIDNameHM = ((productIDNameHM == "") ? "---" : productIDNameHM)
        }
    }
    
    ///是否缺货的提醒，要么为空，要么是"缺货"，缺货的库存是红色显示，其他的是绿色显示
    var msg = ""
    
    ///产品编号的成本价
    var costNoTax = ""
    
    ///总米数
    var countM: Double = 0.0 {
        didSet{
            countMText = String(format: "%.1f", countM)
        }
    }
    
    ///总匹数
    var countP: Int = 0 {
        didSet{
            countPText = String(format: "%d", countP)
        }
    }
    
    ///仓库ID，暂时无用
    var storehouseID = ""
    
    ///产品大类ID  ，暂时无用
    var parentID = "" {
        didSet{
            parentID = ((parentID == "") ? "---" : parentID)
        }
    }
    
    ///产品编号单位
    var unit = "" {
        didSet{
            unit = ((unit == "") ? "---" : unit)
        }
    }
    
    ///产品编号规格
    var specName = "" {
        didSet{
            specName = ((specName == "") ? "---" : specName)
        }
    }
    
    ///产品编号备注
    var memoInfo = "" {
        didSet{
            memoInfo = ((memoInfo == "") ? "---" : memoInfo)
        }
    }
    
    ///产品编号对应二维码ID
    var codeID = ""
    
    ///产品编号对应二维码名称
    var codeName = "" {
        didSet{
            codeName = ((codeName == "") ? "---" : codeName)
        }
    }
    
    ///缩略图1（主缩略图）
    var thumbUrl1 = ""
    
    ///大图1
    var imageUrl1 = ""
    
    //MARK: - 附加属性
    //米数内容
    var countMText = "0.0"
    //匹数内容
    var countPText = "0"
    ///是否可以操作cell
    var couldOperateCell = true
}

