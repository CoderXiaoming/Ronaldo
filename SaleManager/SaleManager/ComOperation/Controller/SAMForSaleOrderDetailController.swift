//
//  SAMForSaleOrderDetailController.swift
//  SaleManager
//
//  Created by LiuXiaoming on 17/2/22.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

private let SAMForSaleDetailCellReuseIdentifier = "SAMForSaleDetailCellReuseIdentifier"
class SAMForSaleOrderDetailController: UIViewController {

    class func instance(forSaleModels: NSMutableArray, selectedIndex: IndexPath) -> SAMForSaleOrderDetailController {
        let vc = SAMForSaleOrderDetailController()
        vc.forSaleModels = forSaleModels
        vc.selectedIndex = selectedIndex
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        setupTableView()
    }
    
    //MARK: - 处理数据
    fileprivate func setupData() {
        let selectedForSaleModel = forSaleModels![selectedIndex!.item] as! SAMForSaleModel
        let selectedCGUnitName = selectedForSaleModel.CGUnitName
        
        titleContentLabel.text = selectedForSaleModel.CGUnitName
        
        let orderModelArr = forSaleModels?.compare(modelKeys: ["CGUnitName"], searchItems: [selectedCGUnitName])
        
        orderDetaiModels = NSMutableArray()
        for obj in orderModelArr! {
            //当前要判断的待售数据模型
            let forSaleModel = obj as! SAMForSaleModel
            
            //计算统计数据
            countP += 1
            countM += forSaleModel.meter
            
            //与待售详情数据数组进行匹配
            let arr = orderDetaiModels!.compare(modelKeys: ["CGUnitName"], searchItems: [forSaleModel.CGUnitName])
            
            if arr.count == 0 { //数据模型数组里面没有这个名称的数据模型
                let forSaleDetailModel = SAMForSaleOrderDetailModel()
                forSaleDetailModel.productIDName = forSaleModel.productIDName
                forSaleDetailModel.mashuText.append(String(format: "%.1f", forSaleModel.meter))
                orderDetaiModels?.add(forSaleDetailModel)
                
            }else { //数据模型数组里面有这个名称的数据模型
                let model = arr[0] as! SAMForSaleOrderDetailModel
                model.mashuText.append(String(format: "，%.1f", forSaleModel.meter))
            }
        }
        
        //赋值统计数据
        countLabel.text = String(format: "%d/%.1f", countP, countM)
    }
    
    //MARK: - 设置tableView
    fileprivate func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        //注册CELL
        tableView.register(UINib.init(nibName: "SAMForSaleDetailCell", bundle: nil), forCellReuseIdentifier: SAMForSaleDetailCellReuseIdentifier)
    }
    
    //MARK: - 用户点击事件
    @IBAction func dismissBtnClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - 属性
    fileprivate var forSaleModels: NSMutableArray?
    fileprivate var selectedIndex: IndexPath?
    fileprivate var orderDetaiModels: NSMutableArray?
    fileprivate var countP = 0
    fileprivate var countM = 0.0
    

    //MARK: - XIB链接属性
    @IBOutlet weak var titleContentLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    
    //MARK: - 其他方法
    fileprivate init() { //重写该方法，为单例服务
        super.init(nibName: nil, bundle: nil)
    }
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        //从xib加载view
        view = Bundle.main.loadNibNamed("SAMForSaleOrderDetailController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - vistTableView数据源
extension SAMForSaleOrderDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetaiModels!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMForSaleDetailCellReuseIdentifier) as! SAMForSaleDetailCell
        //传递数据模型
        let model = orderDetaiModels![indexPath.row] as! SAMForSaleOrderDetailModel
        cell.forSaleDetailModel = model
        
        return cell
    }
}
