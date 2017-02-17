//
//  SAMOrderImageView.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/16.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit
fileprivate let SAMOrderImageViewProductDetailCellReuseIdentifier = "SAMOrderImageViewProductDetailCellReuseIdentifier"

class SAMOrderImageView: UIView {

    //MARK: - 对外提供的类方法
    class func instance(orderInfoModel: SAMSaleOrderDetailModel, productDetailModels: NSMutableArray) -> SAMOrderImageView {
        let view = Bundle.main.loadNibNamed("SAMOrderImageView", owner: nil, options: nil)![0] as! SAMOrderImageView
        view.orderDetailModel = orderInfoModel
        view.productDetailModels = productDetailModels
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //注册cell
        tableView.register(UINib(nibName: "SAMOrderImageCell", bundle: nil), forCellReuseIdentifier: SAMOrderImageViewProductDetailCellReuseIdentifier)
        tableView.rowHeight = 65
    }
    
    //MARK: - 属性
    fileprivate var orderDetailModel: SAMSaleOrderDetailModel? {
        didSet{
            customerLabel.text = orderDetailModel!.CGUnitName
            orderTimeLabel.text = orderDetailModel!.startDate
        }
    }
    fileprivate var productDetailModels: NSMutableArray?
    
    //MARK: - XIB属性
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
}

//MARK: - vistTableView数据源
extension SAMOrderImageView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productDetailModels!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderImageViewProductDetailCellReuseIdentifier) as! SAMOrderImageCell
        //传递数据模型
        let model = productDetailModels![indexPath.row] as! SAMSaleOrderDetailListModel
        cell.detaiListModel = model
        
        return cell
    }
}
