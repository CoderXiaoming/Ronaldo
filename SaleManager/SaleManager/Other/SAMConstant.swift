//
//  SAMConstant.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

//MARK: - 自定义的通知
///用户登录成功发出的通知
let LoginSuccessNotification = "LoginSuccessNotification"
///用户在新建订单时成功选择客户时发出的通知
let SAMCustomerViewControllerDidSelectCustomerNotification = "SAMCustomerViewControllerDidSelectCustomerNotification"
///用户在新建订单时从库存界面成功获取到购物车数据模型发出的通知
let SAMProductOperationViewGetShoppingCarListModelNotification = "SAMProductOperationViewGetShoppingCarListModelNotification"
///用户在二维码扫描界面成功获取到信息跳转发出的通知
let SAMQRCodeViewGetProductNameNotification = "SAMQRCodeViewGetProductNameNotification"
///产品库存详情控制器dismiss成功后发出的通知
let SAMStockDetailControllerDismissSuccessNotification = "SAMStockDetailControllerDismissSuccessNotification"
///产品库存条件搜索控制器dismiss成功后发出的通知
let SAMStockConSearchControllerDismissSuccessNotification = "SAMStockConSearchControllerDismissSuccessNotification"
///产品库存条件搜索语音识别成功后发出的通知
let SAMStockConSearchControllerSpeechSuccessNotification = "SAMStockConSearchControllerSpeechSuccessNotification"


let ScreenW = UIScreen.main.bounds.width
let ScreenH = UIScreen.main.bounds.height

let KeyWindow = UIApplication.shared.keyWindow

let mainColor_green = UIColor(red: 140 / 255.0, green: 213 / 255.0, blue: 82 / 255.0, alpha: 1.0)
let customGrayColor = UIColor(red: 84 / 255.0, green: 84 / 255.0, blue: 84 / 255.0, alpha: 1.0)
let customBlueColor = UIColor(red: 52 / 255.0, green: 152 / 255.0, blue: 219 / 255.0, alpha: 1.0)
let customBGWhiteColor = UIColor(red: 241 / 255.0, green: 240 / 255.0, blue: 255 / 255.0, alpha: 1.0)


let randomColor = UIColor(red: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), green: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), blue: (CGFloat(arc4random_uniform(255)) / CGFloat(255.0)), alpha: 1.0)

