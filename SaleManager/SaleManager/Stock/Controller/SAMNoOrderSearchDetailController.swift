//
//  SAMNoOrderSearchDetailController.swift
//  SaleManager
//
//  Created by LiuXiaoming on 2017/6/5.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

class SAMNoOrderSearchDetailController: UIViewController {

    ///对外提供的类工厂方法
    class func instance(orderArr: NSMutableArray, shoppingCarListArr: NSMutableArray, productIDName: String, countP: Int, countM: Double) ->SAMNoOrderSearchDetailController {
        
        let vc = SAMNoOrderSearchDetailController()
        vc.orderArr = orderArr
        vc.shoppingCarListArr = shoppingCarListArr
        vc.productIDName = productIDName
        vc.countP = countP
        vc.countM = countM
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置标题
        titleLabel.text = String.init(format: "%@ 共 %d匹 %.1f米", productIDName, countP, countM)
        
        //设置数据
        self.setupData()
        
        //设置tableView
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UINib(nibName: "SAMNoOrderSearchListCell", bundle: nil), forCellReuseIdentifier: SAMNoOrderSearchListCellReuseIdentifier)
    }
    
    //MARK: - 设置数据
    fileprivate func setupData() {
        
        if shoppingCarListArr!.count == 0 {
            return
        }
    
        for index in 0...(shoppingCarListArr!.count - 1) {
            
            let detailModel = SAMNoOrderSearchDetailModel()
            let shoppingCarListModel = shoppingCarListArr![index] as! SAMShoppingCarListModel
            detailModel.productIDName = shoppingCarListModel.productIDName
            detailModel.countP = shoppingCarListModel.countP
            detailModel.countM = shoppingCarListModel.countM
            detailModel.billNumber = shoppingCarListModel.billNumber
            
            for orderIndex in 0...(orderArr!.count - 1) {
                
                let orderModel = orderArr![orderIndex] as! SAMOrderModel
                if orderModel.billNumber == shoppingCarListModel.billNumber {
                    
                    detailModel.CGUnitName = orderModel.CGUnitName
                    
                    if Date().yyyyMMddStr() == orderModel.startDate {
                        
                        detailModel.dateState = "今天"
                    }else {
                    
                        detailModel.dateState = "昨天"
                    }
                    break
                }
            }
            
            detailModelArr.add(detailModel)
        }
    }
    
    @IBAction func dismissButtonClick(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 属性
    fileprivate var orderArr: NSMutableArray?
    fileprivate var shoppingCarListArr: NSMutableArray?
    fileprivate let detailModelArr =  NSMutableArray()
    fileprivate var productIDName = ""
    fileprivate var countP = 0
    fileprivate var countM = 0.0
    
    //MARK: - XIB链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    //MARK: - 其他方法
    fileprivate init() {
        super.init(nibName: nil, bundle: nil)
    }
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMNoOrderSearchDetailController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - mainTableView相关方法
extension SAMNoOrderSearchDetailController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModelArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = detailModelArr[indexPath.row] as! SAMNoOrderSearchDetailModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMNoOrderSearchListCellReuseIdentifier) as! SAMNoOrderSearchListCell
        cell.model = model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
