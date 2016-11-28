//
//  SAMStockProductDetailCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockProductDetailCell: UICollectionViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var storePositionLabel: UILabel!
    @IBOutlet weak var meterLabel: UILabel!
    
    @IBOutlet weak var rightSeperaterView: UIView!
}
