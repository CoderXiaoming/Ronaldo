//
//  SAMOrderProductSectionFooterView.swift
//  SaleManager
//
//  Created by apple on 16/12/19.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

/*****************  本来是加在产品组当footerView，当有Bug,改到下面一组的headerView  ****************/

class SAMOrderProductSectionFooterView: UIView {
    
    ///接收的统计数组[码数，米数，价格]
    var countArr = [Double]() {
        didSet{
            countMashuLabel.text = String(format: "%.1f", countArr[0])
            countMishuLabel.text = String(format: "%.1f", countArr[1])
            countPriceLabel.text = String(format: "%.1f", countArr[2])
        }
    }
    
    ///MARK: - 对外提供的类方法
    class func instance() -> SAMOrderProductSectionFooterView {
        let view = Bundle.main.loadNibNamed("SAMOrderProductSectionFooterView", owner: nil, options: nil)![0] as! SAMOrderProductSectionFooterView
        return view
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var countMashuLabel: UILabel!
    @IBOutlet weak var countMishuLabel: UILabel!
    @IBOutlet weak var countPriceLabel: UILabel!
}
