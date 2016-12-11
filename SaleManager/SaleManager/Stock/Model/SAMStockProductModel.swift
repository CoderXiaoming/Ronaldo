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
    var id: String? {
        didSet{
            //加载库存明细模型
            if id != "" {
                loadProductDeatilList()
            }
        }
    }
    
    ///产品编号名称
    var productIDName: String?
    
    ///产品花名
    var productIDNameHM: String?
    
    ///是否缺货的提醒，要么为空，要么是"缺货"，缺货的库存是红色显示，其他的是绿色显示
    var msg: String?
    
    ///产品编号的成本价
    var costNoTax: String?
    
    ///总米数
    var countM: Double = 0.0
    
    ///总匹数
    var countP: Int = 0
    
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
    var imageUrl1: String? {
        didSet{
            if imageUrl1 != "" {
                imageURL1 = NSURL(string: imageUrl1!)
            }
        }
    }

    //MARK: - 加载库存明细数据
    private func loadProductDeatilList() {
        
        let parameters = ["productID": id!, "storehouseID": "-1", "parentID": "-1"]
        //发送请求
        SAMNetWorker.sharedNetWorker().GET("getStockDetailList.ashx", parameters: parameters, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
            }else {//有数据模型
                
                let arr = SAMStockProductDeatil.mj_objectArrayWithKeyValuesArray(dictArr)!
                
                //添加数据模型
                self.productDeatilList.addObjectsFromArray(arr as [AnyObject])
            }
        }) { (Task, Error) in
        }
    }
    
    //MARK: - 附加属性
    ///缩略图1（主缩略图）链接
    var thumbURL1: NSURL?
    ///大图1（主缩略图）链接
    var imageURL1: NSURL?
    
    ///库存明细模型数组
    let productDeatilList = NSMutableArray()
}

//产品库存明细模型
class SAMStockProductDeatil: NSObject {
    
    ///该卷布的米数
    var meter: String?
    
    ///该卷布的编号
    var storePositionName: String?
}

