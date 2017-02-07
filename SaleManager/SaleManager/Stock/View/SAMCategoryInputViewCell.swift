//
//  SAMCategoryInputViewCell.swift
//  SaleManager
//
//  Created by apple on 17/2/7.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMCategoryInputViewCell: UICollectionViewCell {

    //接收的数据模型
    var categoryModel: SAMStockCategory? {
        didSet{
            
            contentLabel.text = categoryModel?.categoryName
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var contentLabel: UILabel!

}
