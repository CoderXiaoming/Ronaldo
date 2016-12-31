//
//  SAMStockCodeSearchCell.swift
//  SaleManager
//
//  Created by apple on 16/11/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

class SAMStockCodeSearchCell: UICollectionViewCell {

    //接收的数据模型
    var codeModel: SAMStockCodeModel? {
        didSet{
            //设置二维码名称
            productName.text = codeModel?.codeName
            
            //设置照片
            if codeModel?.thumbURL != nil {
                productImage.sd_setImage(with: codeModel?.thumbURL! as URL!, placeholderImage: UIImage(named: "photo_loadding")!, options: .retryFailed)
            }else {
                productImage.image = UIImage(named: "photo_loadding")
            }
    }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        productImage.layer.cornerRadius = 15
        productImage.layer.masksToBounds = true
    }
    
    //MARK: - xib链接属性
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
}
