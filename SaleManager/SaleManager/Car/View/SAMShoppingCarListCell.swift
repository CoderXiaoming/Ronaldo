//
//  SAMShoppingCarListCell.swift
//  SaleManager
//
//  Created by apple on 16/12/14.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMShoppingCarListCell: UITableViewCell {

    ///接收的数据模型
    var listModel: SAMShoppingCarListModel? {
        didSet{
            ///设置选中指示器的照片
            if listModel!.selected {
                selectedImageView.image = SAMShoppingCarCellIndicaterSelectedImage
            }else {
                selectedImageView.image = SAMShoppingCarCellIndicaterNormalImage
            }
            
            //设置产品图片
            if listModel?.thumbURL != nil {
                productImageView.sd_setImageWithURL(listModel?.thumbURL!, placeholderImage: UIImage(named: "photo_loadding"))
            }else {
                productImageView.image = UIImage(named: "photo_loadding")
            }
            
            //设置产品名称
            if listModel!.productIDName != "" {
                productName.text = listModel!.productIDName
            }else {
                productName.text = "---"
            }
            
            //设置米数，价格
            var str: String?
            if (listModel?.countM != 0.0) && (listModel?.price != 0.0) {
                str = String(format: "%.1f/%.1f", listModel!.countM, listModel!.price)
            }else if (listModel?.countM == 0.0) && (listModel?.price == 0.0) {
                str = "---/---"
            }else if listModel?.countM == 0.0 {
                str = String(format: "---/%.1f", listModel!.price)
            }else {
                str = String(format: "%.1f/---", listModel!.countM)
            }
            mishuJiageLabel.text = str
            
            //设置匹数
            pishuLabel.text = String(format: "%d", listModel!.countP)
            
            //设置备注
            if listModel!.memoInfo != "" {
                remarkLabel.text = listModel!.memoInfo
            }else {
                remarkLabel.text = "---"
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedImageView.image = SAMShoppingCarCellIndicaterNormalImage
    }
    
    //MARK: - xib链接属性
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuJiageLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
}
