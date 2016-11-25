//
//  SAMStockProductCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

class SAMStockProductCell: UICollectionViewCell {

    var stockProductModel: SAMStockProductModel? {
        didSet{
            
            //设置铲平图片
            if stockProductModel?.thumbURL1 != nil {
                productImage.sd_setImageWithURL(stockProductModel?.thumbURL1!, placeholderImage: nil, options: .RetryFailed)
            }else {
                productImage.image = nil
            }
            
            //设置产品名称
            if stockProductModel!.productIDName != "" {
                productNameLabel.text = stockProductModel!.productIDName
            }else {
                productNameLabel.text = "---"
            }
            
            //设置匹数
            if stockProductModel!.countM != "" {
                mishuLabel.text = stockProductModel!.countM
            }else {
                mishuLabel.text = "---"
            }
            
            //设置匹数
            if stockProductModel!.countP != "" {
                pishuLabel.text = stockProductModel!.countP
            }else {
                pishuLabel.text = "---"
            }
        }
    }
    @IBAction func stockWaringBtnClick(sender: AnyObject) {
    }
    @IBAction func shoppingCarBtnClick(sender: AnyObject) {
    }
    
    //MARK: - XIB链接属性
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var stockWarningBtn: UIButton!
    @IBOutlet weak var shoppingCarBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
