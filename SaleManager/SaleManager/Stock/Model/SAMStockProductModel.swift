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
    var id: String?
    
    ///产品编号名称
    var productIDName: String?
    
    ///是否缺货的提醒，要么为空，要么是"缺货"，缺货的库存是红色显示，其他的是绿色显示
    var msg: String?
    
    ///产品编号的成本价
    var costNoTax: String?
    
    ///总米数
    var countM: String?
    
    ///总匹数
    var countP: String?
    
    ///仓库ID，暂时无用
    var storehouseID: String?
    
    ///产品大类ID  ，暂时无用
    var parentID: String?
    
    ///产品编号单位
    var unit: String?
    
    ///产品编号规格
    var specName: String?
    
    ///产品编号备注
    var memoInfo: String?
    
    ///产品编号对应二维码ID
    var codeID: String?
    
    ///产品编号对应二维码名称
    var codeName: String?
    
    ///缩略图1（主缩略图）
    var thumbUrl1: String? {
        didSet{
            if thumbUrl1 != "" {
                thumbURL1 = NSURL(string: thumbUrl1!)
            }
        }
    }
    
    ///大图1
    var imageUrl1: String?

    //MARK: - 附加属性
    ///缩略图1（主缩略图）链接
    var thumbURL1: NSURL?
}
