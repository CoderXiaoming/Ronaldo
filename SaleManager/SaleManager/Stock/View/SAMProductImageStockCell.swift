//
//  SAMProductImageStockCell.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/3/3.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMProductImageStockCell: UITableViewCell {

    ///接收的产品数据模型
    var productModel: SAMStockProductModel? {
        didSet{
            productNameLabel.text = productModel!.productIDName
            stockLabel.text = String(format: "%d匹", productModel!.countP) + "/" + String(format: "%.1f米", productModel!.countM)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
}
