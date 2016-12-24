//
//  SAMOrderBuildSmallCell.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderBuildSmallCell: UITableViewCell {

    var titleModel: SAMOrderBuildTitleModel? {
        didSet{
            //设置标题
            if titleModel!.cellTitle != "" {
                titleLabel.text = titleModel!.cellTitle
            }else {
                titleLabel.text = "---"
            }
            
            //设置内容
            if titleModel!.cellContent != "" {
                contentLabel.text = titleModel!.cellContent
            }else {
                contentLabel.text = "---"
            }
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
    
    
    //MARK: - XIB链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
}
