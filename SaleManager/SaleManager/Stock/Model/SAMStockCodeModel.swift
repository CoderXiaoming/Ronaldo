//
//  SAMStockCodeModel.swift
//  SaleManager
//
//  Created by apple on 16/11/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockCodeModel: NSObject {

    ///二维码名称类别
    var codeName: String?
    ///缩略图1的地址
    var thumbUrl1: String? {
        didSet{
            if thumbUrl1 != "" {
                thumbURL = URL(string: thumbUrl1!)
            }
        }
    }
    
    var thumbURL: URL?
    
    ///大图1的地址
    var imageUrl1: String?
    
}
