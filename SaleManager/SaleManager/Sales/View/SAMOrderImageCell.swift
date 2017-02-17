//
//  SAMOrderImageCell.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/16.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMOrderImageCell: UITableViewCell {

    var detaiListModel: SAMSaleOrderDetailListModel? {
        didSet{
            productNameLabel.text = detaiListModel!.productIDName
            mashuListLabel.text = detaiListModel!.meterList
            countPLabel.text = "\(detaiListModel!.countP)"
            mishuLabel.text = "\(detaiListModel!.countM)"
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
    @IBOutlet weak var mashuListLabel: UILabel!
    @IBOutlet weak var countPLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    
}
