//
//  SAMProducutStockImageView.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/3/3.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

fileprivate let SAMProductImageStockCellReuseIdentifier = "SAMProductImageStockCellReuseIdentifier"

class SAMProducutStockImageView: UIView {
    
    //MARK: - 对外提供的类方法
    class func instace(stockModel: SAMStockProductModel, productModels: NSMutableArray) -> SAMProducutStockImageView {
        let view = Bundle.main.loadNibNamed("SAMProducutStockImageView", owner: nil, options: nil)![0] as! SAMProducutStockImageView
        view.productModel = stockModel
        view.productModels = productModels
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置tableView的数据源
        tableView.dataSource = self
        tableView.delegate = self
        
        //注册cell
        tableView.register(UINib(nibName: "SAMProductImageStockCell", bundle: nil), forCellReuseIdentifier: SAMProductImageStockCellReuseIdentifier)
    }

    //MARK: - 属性
    ///产品图片
    fileprivate var productModel: SAMStockProductModel? {
        didSet {
            if productModel!.imageUrl1 != "" {
                imageView.sd_setImage(with: URL.init(string: productModel!.imageUrl1), placeholderImage: UIImage(named: "photo_loadding"))
            }else {
                imageView.image = UIImage(named: "photo_loadding")
            }
        }
    }
    ///产品模型数组
    fileprivate var productModels: NSMutableArray?
    
    //MARK: - XIB链接属性
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
}

extension SAMProducutStockImageView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productModels!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = productModels![indexPath.row] as! SAMStockProductModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMProductImageStockCellReuseIdentifier) as! SAMProductImageStockCell
        cell.productModel = model
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
}
