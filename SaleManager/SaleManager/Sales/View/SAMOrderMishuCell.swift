//
//  SAMOrderMishuCell.swift
//  SaleManager
//
//  Created by apple on 16/12/10.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderMishuCell: UICollectionViewCell {

    ///米数字符串
    var miText: String? {
        didSet{
            if miText != "" {
                mishuLabel.text = miText
            }else {
                mishuLabel.text = "---"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - XIB链接属性
    @IBOutlet weak var mishuLabel: UILabel!
}
