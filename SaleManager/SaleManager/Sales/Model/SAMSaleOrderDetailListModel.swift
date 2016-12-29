//
//  SAMSaleOrderDetailListModel.swift
//  SaleManager
//
//  Created by apple on 16/12/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMSaleOrderDetailListModel: NSObject {

    ///明细项id
    var id: String?
    ///产品编号id
    var productID: String?
    ///产品编号名称
    var productIDName: String?
    ///数量（米数)
    var countM: Double = 0.0
    ///单价
    var price: Double = 0.0
    ///小计金额
    var smallMoney: Double = 0.0
    ///备注
    var memoInfo: String?
    ///匹数
    var countP: Double = 0.0
    ///每匹米数列表
    var meterList: String? {
        didSet{
            
            let listStr = meterList?.lxm_stringByTrimmingWhitespace()
            if listStr != "" { //字符串有内容
                
                if listStr!.contains(",") { //逗号分隔
                    meterArr = (listStr?.components(separatedBy: ","))!
                }else if listStr!.contains("|") { // |分隔
                    
                    meterArr = (listStr?.components(separatedBy: "|"))!
                }else { //只有一个数字
                    meterArr = [listStr!]
                }
            }
        }
    }
    
    //MARK: - 辅助属性
    var meterArr = [String]()
}
