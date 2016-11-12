//
//  SAMStockProductCell.swift
//  SaleManager
//
//  Created by apple on 16/11/10.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

private let divHeight: CGFloat = 60

class SAMStockProductCell: UICollectionViewCell {
    
    var productModel: SAMProductInfo? {
        didSet{
            //添加所有div
            addAllDivs()
            
            //布局所有div
            layoutSubviews()
            
            //设置cell的实际高度
            realHeight = divHeight * CGFloat(divs.count)
        }
    }
    
    ///cell的实际高度
    var realHeight: CGFloat = 0
    
    //存储所有的Div数据
    var divs = [SAMStockProductCellDiv]()
    
    //MARK: - 添加Div
    private func addAllDivs() {
        //先填加主Div
        addOneDiv(productModel!, hideOperation: true)
        
        //添加其他颜色Div
        let count = productModel!.moreInfo?.count ?? 0
        for i in 0...(count - 1) {
            let subModel = productModel!.moreInfo![i]
            addOneDiv(subModel, hideOperation: false)
        }
    }
    private func addOneDiv(model: SAMProductInfo, hideOperation: Bool) {
        let div = SAMStockProductCellDiv.div()
        divs.append(div)
        contentView.addSubview(div)
        div.productModel = model
        div.isHideOperation = hideOperation
    }
    
    //MARK: - 布局所有div
    override func layoutSubviews() {
        super.layoutSubviews()
        for div in divs {
            let index = CGFloat(divs.indexOf(div)!)
            let x: CGFloat = 0
            let y = divHeight * index
            let width = contentView.bounds.width
            div.frame = CGRect(x: x, y: y, width: width, height: divHeight)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //MARK: - 无关紧要的方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


