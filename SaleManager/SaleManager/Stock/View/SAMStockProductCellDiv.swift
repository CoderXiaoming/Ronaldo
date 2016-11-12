//
//  SAMStockProductCellDiv.swift
//  SaleManager
//
//  Created by apple on 16/11/11.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMStockProductCellDiv: UIView {
    
    //MARK: - 对外提供的类工厂方法
    class func div() -> SAMStockProductCellDiv {
        let view = NSBundle.mainBundle().loadNibNamed("SAMStockProductCellDiv", owner: nil, options: nil)![0] as! SAMStockProductCellDiv
        return view
    }
    
    ///对外提供属性，是否隐藏操作按钮
    var isHideOperation: Bool = false {
        didSet{
            outStockBtn.hidden = false
            shoppingCarBtn.hidden = false
        }
    }
    ///接受的数据模型
    var productModel: SAMProductInfo? {
        didSet{
            productImage.image = productModel!.picture
            productName.text = productModel!.name
            pishuLabel.text = String(format: "匹数：%.0f", productModel!.pishu)
            mishuLabel.text = String(format: "米数：%.1f", productModel!.mishu)
        }
    }

    //MARK: - XIB连接控件
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var outStockBtn: UIButton!
    @IBOutlet weak var shoppingCarBtn: UIButton!
    
    
}
