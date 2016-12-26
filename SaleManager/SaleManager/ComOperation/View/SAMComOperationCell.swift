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
            if orderInfoModel!.orderStatus == "未开单" {
                sateImageView.image = UIImage(named: "orderManageNotCompletion")
            }else {
                sateImageView.image = UIImage(named: "orderManageCompletion")
            }
            
            //设置客户名称
            if orderInfoModel!.CGUnitName != "" {
                customerLabel.text = orderInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置订单编号
            firstInfoTitleLabel.text = "订单编号："
            if orderInfoModel!.billNumber != "" {
                fitstInfoContentLabel.text = orderInfoModel!.billNumber
            }else {
                fitstInfoContentLabel.text = "---"
            }
            
            //设置备注
            secondInfoTitleLabel.text = "备注："
            if orderInfoModel!.memoInfo != "" {
                secondInfoContentLabel.text = orderInfoModel!.memoInfo
            }else {
                secondInfoContentLabel.text = "---"
            }
            
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置时间
            if orderInfoModel!.startDate != "" {
                startDateLabel.text = orderInfoModel!.startDate
            }else {
                startDateLabel.text = "---"
            }
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
            sateImageView.image = UIImage(named: "indicater_forSale_selected")
            
            //设置客户名称
            if forSaleInfoModel!.CGUnitName != "" {
                customerLabel.text = forSaleInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置产品名称
            firstInfoTitleLabel.text = ""
            if forSaleInfoModel!.productIDName != "" {
                fitstInfoContentLabel.text = forSaleInfoModel!.productIDName
            }else {
                fitstInfoContentLabel.text = "---"
            }
            //设置数量数
            secondInfoTitleLabel.text = "数量："
            secondInfoContentLabel.text = forSaleInfoModel!.meter! + forSaleInfoModel!.unit!
            
            //设置米数
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置扫码人
            if forSaleInfoModel!.employeeName != "" {
                startDateLabel.text = forSaleInfoModel!.employeeName
            }else {
                startDateLabel.text = "---"
            }
            
            //设置交货日期
            if forSaleInfoModel!.orderBillNumber != "" {
                endDateLabel.text = forSaleInfoModel!.orderBillNumber
            }else {
                endDateLabel.text = "---"
            }
        }
    }
    
    ///接收的缺货登记数据模型
    var owedInfoModel: SAMOwedInfoModel? {
        didSet{
            if owedInfoModel == nil {
                return
            }
            
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
            firstInfoTitleLabel.text = ""
            if owedInfoModel!.productIDName != "" {
                fitstInfoContentLabel.text = owedInfoModel!.productIDName
            }else {
                fitstInfoContentLabel.text = "---"
            }
            //设置匹数
            secondInfoTitleLabel.text = "匹数："
            secondInfoContentLabel.text = String(format: "%d", owedInfoModel!.countP)
            
            //设置米数
            thirdInfoTitleLabel.text = "米数："
            thirdInfoContentLabel.text = String(format: "%.1f", owedInfoModel!.countM)
            
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
    
    ///接收的销售历史数据模型
    var saleOrderInfoModel: SAMSaleOrderInfoModel? {
        didSet{
            if saleOrderInfoModel == nil {
                return
            }
            
            //设置图片
            sateImageView.image = UIImage(named: "indicater_saleHistory_selected")
            
            //设置客户名称
            if saleOrderInfoModel!.CGUnitName != "" {
                customerLabel.text = saleOrderInfoModel!.CGUnitName
            }else {
                customerLabel.text = "---"
            }
            
            //设置订单编号
            firstInfoTitleLabel.text = "订单编号："
            if saleOrderInfoModel!.billNumber != "" {
                fitstInfoContentLabel.text = saleOrderInfoModel!.billNumber
            }else {
                fitstInfoContentLabel.text = "---"
            }
            
            //设置金额
            secondInfoTitleLabel.text = "金额："
            secondInfoContentLabel.text = String(format: "%.1f元", saleOrderInfoModel!.actualMoney)
            
            thirdInfoTitleLabel.text = ""
            thirdInfoContentLabel.text = ""
            
            //设置时间
            if saleOrderInfoModel!.startDate != "" {
                startDateLabel.text = saleOrderInfoModel!.startDate
            }else {
                startDateLabel.text = "---"
            }
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
