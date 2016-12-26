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
    
    //MARK: - 对外提供的，当不可编辑时设置cell的样式
    func setCellEditDisabledStyle() {
    
        accessoryType = .none
        contentLabelTrailingDistance.constant = 15
    }
    
    //MARK: - 对外提供的，当可编辑时设置cell的样式
    func setCellEditEnabledStyle() {
        
        accessoryType = .disclosureIndicator
        contentLabelTrailingDistance.constant = 0
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var contentLabelTrailingDistance: NSLayoutConstraint!
    
}
