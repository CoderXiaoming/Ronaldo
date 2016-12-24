//
//  SAMStockProductDetailCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

//CELL的宽度
let SAMStockProductDetailCellWidth: CGFloat = 100
//CELL的高度
let SAMStockProductDetailCellHeight: CGFloat = 40
//CELL的高度
let SAMStockProductDetailCellMinimumLineSpacing: CGFloat = 5

class SAMStockProductDetailCell: UICollectionViewCell {

    //接收的数据模型
    var productDetailModel: SAMStockProductDeatil? {
        didSet{
            
            //设置该卷布编号
            if productDetailModel?.storePositionName != "" {
                storePositionLabel.text = productDetailModel?.storePositionName
            }else {
                storePositionLabel.text = "---"
            }
            
            //设置该卷布米数
            if productDetailModel?.meter != "" {
                meterLabel.text = productDetailModel?.meter
            }else {
                meterLabel.text = "---"
            }
        }
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var storePositionLabel: UILabel!
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var rightSeperaterView: UIView!
}
