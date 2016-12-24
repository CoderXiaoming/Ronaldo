//
//  SAMOrderBuildBigCell.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderBuildBigCell: UITableViewCell {

    ///接收的数据模型
    var productAddToOrderModel: SAMShoppingCarListModel? {
        didSet{
            
            //设置产品名称
            if productAddToOrderModel!.productIDName != "" {
                productNameLabel.text = productAddToOrderModel!.productIDName
            }else {
                productNameLabel.text = "---"
            }
            
            //设置匹数
            pishuLabel.text = String(format: "%d", productAddToOrderModel!.countP)
            
            //设置码数
            mashuLabel.text = String(format: "%.1f", productAddToOrderModel!.countMA)
            
            //设置米数
            mishuLabel.text = String(format: "%.1f", productAddToOrderModel!.countM)
            
            //设置价格
            jiageLabel.text = String(format: "%.1f", productAddToOrderModel!.price)
            
            //设置总价
            zongjiaLabel.text = String(format: "%.1f", productAddToOrderModel!.countPrice)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    //MARK: - XIB属性
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mashuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var jiageLabel: UILabel!
    @IBOutlet weak var zongjiaLabel: UILabel!
    
}
