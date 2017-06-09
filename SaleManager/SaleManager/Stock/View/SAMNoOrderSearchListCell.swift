//
//  SAMNoOrderSearchListCell.swift
//  SaleManager
//
//  Created by LiuXiaoming on 2017/6/5.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

let SAMNoOrderSearchListCellReuseIdentifier = "SAMNoOrderSearchListCellReuseIdentifier"

class SAMNoOrderSearchListCell: UITableViewCell {

    ///接收的产品数据模型
    var model: SAMNoOrderSearchDetailModel? {
        didSet{
            firstLabel.text = model!.CGUnitName
            secondLabel.text = String.init(format: "%d", model!.countP)
            thirdLabel.text = String.init(format: "%.1f", model!.countM)
            
            let billNumberNstr = NSString.init(string: model!.billNumber!)
            let content = billNumberNstr.substring(from: billNumberNstr.length - 6) + "\n" + model!.dateState!
            let attStr = NSMutableAttributedString(string: content)
            if model!.dateState! == "今天" {
                
                attStr.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: NSMakeRange(attStr.length - 2, 2))
            }else {
            
                attStr.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: NSMakeRange(attStr.length - 2, 2))
            }
            forthLabel.attributedText = attStr
        }
    }

    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var forthLabel: UILabel!
}
