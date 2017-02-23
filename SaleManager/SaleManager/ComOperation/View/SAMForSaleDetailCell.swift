//
//  SAMForSaleDetailCell.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/22.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMForSaleDetailCell: UITableViewCell {

    //接收的数据模型
    var forSaleDetailModel: SAMForSaleOrderDetailModel? {
        didSet{
            productNameLabel.text = forSaleDetailModel!.productIDName
            mashuLabel.text = forSaleDetailModel!.mashuText
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var mashuLabel: UILabel!
    
}
