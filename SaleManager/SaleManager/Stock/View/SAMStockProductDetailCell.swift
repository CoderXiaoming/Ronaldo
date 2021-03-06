//
//  SAMStockProductDetailCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockProductDetailCell: UICollectionViewCell {

    //接收的数据模型
    var productDetailModel: SAMStockProductDeatil? {
        didSet{
            
            //设置该卷布编号
            storePositionLabel.text = productDetailModel?.storePositionName
            
            //设置该卷布米数
            meterLabel.text = productDetailModel?.meter
        }
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var storePositionLabel: UILabel!
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var rightSeperaterView: UIView!
}
