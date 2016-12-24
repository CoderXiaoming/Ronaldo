//
//  SAMOrderModel.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderModel: NSObject {

    ///销售日期
    var startDate: String?
    ///备注
    var memoInfo: String?
    ///客户ID
    var CGUnitID: String?
    ///客户名称
    var CGUnitName: String?
    ///订单状态
    var orderStatus: String?
    ///订单单号
    var billNumber: String?
    
    //MARK: - 对外提供的加载详情订单详情的数据模型
    func loadMoreInfo(success: @escaping ()->(), defeat: @escaping ()->()) {
    
        //如果没有订单号，执行失败闭包，返回
        if billNumber == "" {
            defeat()
            return
        }
        
        //简单创建用户数据模型
        orderCustomerModel = SAMCustomerModel()
        orderCustomerModel?.CGUnitName = CGUnitName
        orderCustomerModel?.id = CGUnitID
        
        //发送请求，获取订单详情数据模型
        SAMNetWorker.sharedNetWorker().get("getOrderMainDataByBillNumber.ashx", parameters: ["billNumber": billNumber!], progress: nil, success: { (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 {
                defeat()
                return
            }else { //有数据模型
                
                //获取订单主要内容数据模型
                let arr = SAMOrderDetailModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let model = arr[0] as? SAMOrderDetailModel
                
                //赋值订单详情内容数组
                self.orderDetailContentArr = [[["客户", model!.CGUnitName!],
                                               ["备注", model!.memoInfo!]],
                                              [],
                                              [["优惠", model!.cutMoney!],
                                               ["其他金额", model!.otherMoney!],
                                               ["总金额", model!.totalMoney!],
                                               ["已收定金", model!.receiveMoney!]],
                                              [["日期", model!.startDate!],
                                               ["开单人", model!.userName!],
                                               ["订单状态", model!.orderStatus!],
                                               ["是否已经生成码单", model!.isMakeBill!],
                                               ["是否同意发货", model!.isAgreeSend!]]]
            
                //记录订单状态
                self.isAgreeSend = (model!.isAgreeSend! == "是") ? true : false
                
                //发送请求，获取订单产品数据模型数组
                SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": self.billNumber!], progress: nil, success: { (Task, json) in
                    
                    //获取模型数组
                    let Json = json as! [String: AnyObject]
                    let dictArr = Json["body"] as? [[String: AnyObject]]
                    let count = dictArr?.count ?? 0
                    
                    //判断是否有模型数据
                    if count == 0 { //没有数据
                        defeat()
                        return
                    }else { //有数据模型
                        
                        let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                        for model in arr {
                            let shoppingCarListModel = model as! SAMShoppingCarListModel
                            self.productListModels.append(shoppingCarListModel)
                        }
                        success()
                        return
                    }
                }) { (Task, Error) in
                    defeat()
                    return
                }
            }
        }) { (Task, Error) in
            defeat()
            return
        }
    }
    
    //MARK: - 附加属性
    ///用户数据模型
    var orderCustomerModel: SAMCustomerModel?
    
    ///订单详情数据模型
    var orderDetailModel: SAMOrderDetailModel?
    
    ///订单详情内容数组
    var orderDetailContentArr = [[[String]]]()
    
    ///订单产品数据模型数组
    var productListModels = [SAMShoppingCarListModel]()
    
    ///是否同意发货
    var isAgreeSend: Bool = false
}

