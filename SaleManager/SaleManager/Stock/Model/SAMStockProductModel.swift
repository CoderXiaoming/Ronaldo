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
    var msg: String?
    
    ///产品编号的成本价
    var costNoTax: String?
    
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
                thumbURL1 = URL(string: thumbUrl1!)
            }
        }
    }
    
    ///大图1
    var imageUrl1: String? {
        didSet{
            if imageUrl1 != "" {
                imageURL1 = URL(string: imageUrl1!)
            }
        }
    }

    //MARK: - 加载库存明细数据
    fileprivate func loadProductDeatilList() {
        
        let parameters = ["productID": id!, "storehouseID": "-1", "parentID": "-1"]
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getStockDetailList.ashx", parameters: parameters, progress: nil, success: { (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
            }else {//有数据模型
                
                let arr = SAMStockProductDeatil.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //添加数据模型
                self.productDeatilList.addObjects(from: arr as [AnyObject])
                
                //计算选中的高度
                let countOfRow = Int(ScreenW / SAMStockProductDetailCellWidth)
                let IntRows = self.productDeatilList.count / countOfRow
                let remainder = self.productDeatilList.count % countOfRow
                let realRows = (remainder != 0) ? (IntRows + 1) : IntRows
                
                let selectedHeight = SAMStockProductDetailCellHeight * CGFloat(realRows) + SAMStockProductCellNormalHeight + SAMStockProductDetailCellMinimumLineSpacing * CGFloat(realRows - 1)
                self.cellSelectedSize = CGSize(width: ScreenW, height: selectedHeight)
            }
        }) { (Task, Error) in
        }
    }
    
    //MARK: - 附加属性
    //米数内容
    var countMText = "0.0"
    //匹数内容
    var countPText = "0"
    ///缩略图1（主缩略图）链接
    var thumbURL1: URL?
    ///大图1（主缩略图）链接
    var imageURL1: URL?
    
    ///collectioinView选中的高度
    var cellSelectedSize = CGSize(width: ScreenW, height: 126)
    
    ///库存明细模型数组
    let productDeatilList = NSMutableArray()
}

//产品库存明细模型
class SAMStockProductDeatil: NSObject {
    
    ///该卷布的米数
    var meter = "---"
    
    ///该卷布的编号
    var storePositionName = "---"
}

