//
//  SAMOrderProductSectionHeaderView.swift
//  SaleManager
//
//  Created by apple on 16/12/19.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

protocol SAMOrderProductSectionHeaderViewDelegate: NSObjectProtocol {
    func headerViewDidClickAddBtn()
}

class SAMOrderProductSectionHeaderView: UIView {

    ///代理
    var delegate: SAMOrderProductSectionHeaderViewDelegate?
    
    ///添加按钮可用状态
    var addButtonisEnable = true
    
    //MARK: - 对外提供的类方法
    class func instance(couldAddProduct: Bool) -> SAMOrderProductSectionHeaderView {
        let view = Bundle.main.loadNibNamed("SAMOrderProductSectionHeaderView", owner: nil, options: nil)![0] as! SAMOrderProductSectionHeaderView
        view.addProductButton.isEnabled = couldAddProduct
        return view
    }
    
    //MARK: - 用户点击事件
    @IBAction func AddBtnClick(_ sender: UIButton) {
        delegate?.headerViewDidClickAddBtn()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var addProductButton: UIButton!
}
