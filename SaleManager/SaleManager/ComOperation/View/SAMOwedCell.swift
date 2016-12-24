//
//  SAMOwedCell.swift
//  SaleManager
//
//  Created by apple on 16/12/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOwedCell: UICollectionViewCell {

    ///接收的数据模型
    var owedInfoModel: SAMOwedInfoModel? {
        didSet{
            //设置状态指示图片
            switch owedInfoModel!.iState! {
            case "欠货中":
                sateImageView.image = UIImage(named: "oweding")
            case "已完成":
                sateImageView.image = UIImage(named: "owedCompletion")
            case "已删除":
                sateImageView.image = UIImage(named: "owedDelete")
            default:
                break
            }
            //设置客户名称
            if owedInfoModel!.CGUnitName != "" {
                customerLabel.text = owedInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            //设置产品名称
            if owedInfoModel!.productIDName != "" {
                productNameLabel.text = owedInfoModel!.productIDName
            }else {
                productNameLabel.text = "---"
            }
            //设置匹数
            pishuLabel.text = String(format: "%d", owedInfoModel!.countP)
            //设置米数
            mishuLabel.text = String(format: "%.1f", owedInfoModel!.countM)
            //设置起始日期
            if owedInfoModel!.startDate != "" {
                startDateLabel.text = owedInfoModel!.startDate
            }else {
                startDateLabel.text = "---"
            }
            //设置交货日期
            if owedInfoModel!.endDate != "" {
                endDateLabel.text = owedInfoModel!.endDate
            }else {
                endDateLabel.text = "---"
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var sateImageView: UIImageView!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
}
