//
//  SAMComOperationCell.swift
//  SaleManager
//
//  Created by apple on 16/12/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMComOperationCell: UICollectionViewCell {

    ///接收的销售历史数据模型
    var orderInfoModel: SAMOrderModel? {
        didSet{
            if orderInfoModel == nil {
                return
            }
            
            //设置订单状态图片
            sateImageView.image = UIImage(named: orderInfoModel!.orderStateImageName)
            
            //设置客户名称
            customerLabel.text = orderInfoModel!.CGUnitName
            
            //设置订单编号
            firstInfoTitleLabel.text = "订单编号："
            fitstInfoContentLabel.text = orderInfoModel!.billNumber
            
            //设置备注
            secondInfoTitleLabel.text = "备注："
            secondInfoContentLabel.text = orderInfoModel!.memoInfo
            
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置时间
            startDateLabel.text = orderInfoModel!.startDate
            endDateLabel.text = ""
        }
    }
    
    ///接收的待售布匹的数据模型
    var forSaleInfoModel: SAMForSaleModel? {
        didSet{
            if forSaleInfoModel == nil {
                return
            }
            
            //设置图片
            sateImageView.image = UIImage(named: forSaleInfoModel!.orderStateImageName)
            
            //设置产品名称
            customerLabel.text = forSaleInfoModel!.productIDName
            
            //设置客户名称
            firstInfoTitleLabel.text = ""
            fitstInfoContentLabel.text = forSaleInfoModel!.CGUnitName
            
            //设置数量数
            secondInfoTitleLabel.text = "数量："
            secondInfoContentLabel.text = String(format: "%.1f", forSaleInfoModel!.meter) + forSaleInfoModel!.unit
            
            //设置米数
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置扫码人
            startDateLabel.text = forSaleInfoModel!.employeeName
            
            //设置交货日期
            endDateLabel.text = forSaleInfoModel!.orderBillNumber
        }
    }
    
    ///接收的缺货登记数据模型
    var owedInfoModel: SAMOwedInfoModel? {
        didSet{
            if owedInfoModel == nil {
                return
            }
            
            //设置图片
            sateImageView.image = UIImage(named: owedInfoModel!.orderStateImageName)
            
            //设置客户名称
            customerLabel.text = owedInfoModel!.CGUnitName
            
            //设置产品名称
            firstInfoTitleLabel.text = ""
            fitstInfoContentLabel.text = owedInfoModel!.productIDName
            
            //设置匹数
            secondInfoTitleLabel.text = "匹数："
            secondInfoContentLabel.text = String(format: "%d", owedInfoModel!.countP)
            
            //设置米数
            thirdInfoTitleLabel.text = "米数："
            thirdInfoContentLabel.text = String(format: "%.1f", owedInfoModel!.countM)
            
            //设置起始日期
            startDateLabel.text = owedInfoModel!.startDate
            
            //设置交货日期
            endDateLabel.text = owedInfoModel!.endDate
        }
    }
    
    ///接收的销售历史数据模型
    var saleOrderInfoModel: SAMSaleOrderInfoModel? {
        didSet{
            if saleOrderInfoModel == nil {
                return
            }
            
            //设置图片
            sateImageView.image = UIImage(named: saleOrderInfoModel!.orderStateImageName)
            
            //设置客户名称
            customerLabel.text = saleOrderInfoModel!.CGUnitName
            
            //设置订单编号
            firstInfoTitleLabel.text = "订单编号："
            fitstInfoContentLabel.text = saleOrderInfoModel!.billNumber
            
            //设置金额
            secondInfoTitleLabel.text = "金额："
            secondInfoContentLabel.text = String(format: "%.1f元", saleOrderInfoModel!.actualMoney)
            
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置时间
            startDateLabel.text = saleOrderInfoModel!.startDate
            endDateLabel.text = ""
        }
    }
        
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var sateImageView: UIImageView!
    @IBOutlet weak var customerLabel: UILabel!
    
    @IBOutlet weak var firstInfoTitleLabel: UILabel!
    @IBOutlet weak var fitstInfoContentLabel: UILabel!
    
    @IBOutlet weak var secondInfoTitleLabel: UILabel!
    @IBOutlet weak var secondInfoContentLabel: UILabel!
    
    @IBOutlet weak var thirdInfoTitleLabel: UILabel!
    @IBOutlet weak var thirdInfoContentLabel: UILabel!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
}
