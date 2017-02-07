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
    func productCellDidClickShoppingCarButton(_ stockProductModel: SAMStockProductModel, stockProductImage: UIImage)
    func productCellDidClickStockWarnningButton(_ stockProductModel: SAMStockProductModel)
    func productCellDidClickProductImage(_ stockProductModel: SAMStockProductModel)
    func productCellDidLongPressProductImage(_ stockProductModel: SAMStockProductModel)
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
                stockWarningBtn.isEnabled = false
                shoppingCarBtn.isEnabled = false
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置图片圆角
        productImageView.layer.cornerRadius = 10
        
        //设置产品图片监听事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMStockProductCell.productImageViewDidTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SAMStockProductCell.productImageViewDidLongPress))
        productImageView.addGestureRecognizer(tapGesture)
        productImageView.addGestureRecognizer(longPressGesture)
    }
    
    //MARK: - 用户点击事件处理
    @IBAction func stockWaringBtnClick(_ sender: AnyObject) {
        delegate?.productCellDidClickStockWarnningButton(stockProductModel!)
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
    
    @IBAction func shoppingCarBtnClick(_ sender: AnyObject) {
        delegate?.productCellDidClickShoppingCarButton(stockProductModel!, stockProductImage: productImageView.image!)
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var stockWarningBtn: UIButton!
    @IBOutlet weak var shoppingCarBtn: UIButton!
}
