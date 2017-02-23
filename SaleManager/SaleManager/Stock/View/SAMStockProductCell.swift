//
//  SAMStockProductCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

//cell正常高度
let SAMStockProductCellNormalHeight: CGFloat = 75

//MARK: - 代理方法
protocol SAMStockProductCellDelegate: NSObjectProtocol {
    func productCellDidClickProductImage(_ stockProductModel: SAMStockProductModel)
    func productCellDidLongPressProductImage(_ stockProductModel: SAMStockProductModel)
    
    func productCellDidTapWarnningImage(_ stockProductModel: SAMStockProductModel)
    func productCellDidLongPressWarnningImage(_ stockProductModel: SAMStockProductModel)
    
    func productCellDidTapShoppingCarImage(_ stockProductModel: SAMStockProductModel, stockProductImage: UIImage)
    func productCellDidLongPressShoppingCarImage(_ stockProductModel: SAMStockProductModel)
    
}

class SAMStockProductCell: UICollectionViewCell {

    ///代理
    weak var delegate: SAMStockProductCellDelegate?
    
    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            
            //设置产品图片
            if stockProductModel!.thumbUrl1 != "" {
                productImageView.sd_setImage(with: URL(string: stockProductModel!.thumbUrl1), placeholderImage: UIImage(named: "photo_loadding"))
            }else {
                productImageView.image = UIImage(named: "photo_loadding")
            }
            
            //设置产品名称
            productNameLabel.text = stockProductModel!.productIDName
            
            //设置米数
            mishuLabel.text = stockProductModel!.countMText
            
            //根据米数设置背景图片
            if stockProductModel!.countMText == "0.0" {
                topContentView.backgroundColor = UIColor(red: 200 / 255.0, green: 200 / 255.0, blue: 200 / 255.0, alpha: 1.0)
            }else {
                topContentView.backgroundColor = UIColor.white
            }
            
            //设置匹数
            pishuLabel.text = stockProductModel!.countPText
            
            //设置警告，购物车按钮状态
            if !stockProductModel!.couldOperateCell {
                warningNormalImage.isHidden = true
                shoppingCarNormalImage.isHidden = true
            }else {
                warningNormalImage.isHidden = false
                shoppingCarNormalImage.isHidden = false
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置图片圆角
        productImageView.layer.cornerRadius = 10
        
        //设置产品图片手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMStockProductCell.productImageViewDidTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SAMStockProductCell.productImageViewDidLongPress))
        productImageView.addGestureRecognizer(tapGesture)
        productImageView.addGestureRecognizer(longPressGesture)
        
        //设置库存警告图片手势
        let tapWarnningGesture = UITapGestureRecognizer(target: self, action: #selector(SAMStockProductCell.tapStockWarnningImage(tap:)))
        let longWarnningPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SAMStockProductCell.longPressWarnningImage(longPress:)))
        warningNormalImage.addGestureRecognizer(tapWarnningGesture)
        warningNormalImage.addGestureRecognizer(longWarnningPressGesture)
        
        //设置库存警告图片手势
        let tapShoppingCarGesture = UITapGestureRecognizer(target: self, action: #selector(SAMStockProductCell.tapShoppingCarImage(tap:)))
        let longPressShoppingCarGesture = UILongPressGestureRecognizer(target: self, action: #selector(SAMStockProductCell.longPressShoppingCarImage(longPress:)))
        shoppingCarNormalImage.addGestureRecognizer(tapShoppingCarGesture)
        shoppingCarNormalImage.addGestureRecognizer(longPressShoppingCarGesture)
    }
    
    //MARK: - 用户点击事件处理
    func tapStockWarnningImage(tap: UITapGestureRecognizer) {
        delegate?.productCellDidTapWarnningImage(stockProductModel!)
    }
    
    func longPressWarnningImage(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            delegate?.productCellDidLongPressWarnningImage(stockProductModel!)
        }
    }
    
    func tapShoppingCarImage(tap: UITapGestureRecognizer) {
        delegate?.productCellDidTapShoppingCarImage(stockProductModel!, stockProductImage: productImageView.image!)
    }
    
    func longPressShoppingCarImage(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            delegate?.productCellDidLongPressShoppingCarImage(stockProductModel!)
        }
    }
    
    //点击了产品图片
    func productImageViewDidTap() {
        delegate?.productCellDidClickProductImage(stockProductModel!)
    }
    
    //长按了产品图片
    func productImageViewDidLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            delegate?.productCellDidLongPressProductImage(stockProductModel!)
        }
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var warningNormalImage: UIImageView!
    @IBOutlet weak var shoppingCarNormalImage: UIImageView!
}
