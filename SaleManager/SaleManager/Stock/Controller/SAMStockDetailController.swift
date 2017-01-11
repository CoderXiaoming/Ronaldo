//
//  SAMStockDetailController.swift
//  SaleManager
//
//  Created by apple on 17/1/9.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit

//库存明细重用标识符
private let SAMStockProductDetailCellReuseIdentifier = "SAMStockProductDetailCellReuseIdentifier"

class SAMStockDetailController: UIViewController {

    //MARK: - 类工厂方法
    class func instance(stockModel: SAMStockProductModel) -> SAMStockDetailController {
        let vc = SAMStockDetailController()
        vc.stockProductModel = stockModel
        
        //加载数据
        vc.loadProductDeatilList()
        return vc
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置圆角
        view.layer.cornerRadius = 8
        
        //设置标题
        titleLabel.text = stockProductModel?.productIDName
        
        //设置collectionView
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }
    
    ///设置collectionView
    fileprivate func setupCollectionView() {
        
        //设置数据源、代理
        collectionView.dataSource = self
        collectionView.delegate  = self
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMStockProductDetailCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductDetailCellReuseIdentifier)
    }
    
    //MARK: - 加载库存明细数据
    fileprivate func loadProductDeatilList() {
        
        let parameters = ["productID": stockProductModel!.id, "storehouseID": "-1", "parentID": "-1"]
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getStockDetailList.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
            }else {//有数据模型
                
                self!.productDeatilList = SAMStockProductDeatil.mj_objectArray(withKeyValuesArray: dictArr)!
            }
        }) { (Task, Error) in
        }
    }

    //MARK: - 用户点击事件
    @IBAction func dismissBtnClick(_ sender: UIButton) {
        dismiss(animated: true) { 
            //发出通知
            NotificationCenter.default.post(name: NSNotification.Name.init(SAMStockDetailControllerDismissSuccessNotification), object: nil)
        }
    }
    
    //MARK: - 属性
    ///接收的库存模型
    fileprivate var stockProductModel: SAMStockProductModel?
    ///模型数组
    fileprivate var productDeatilList = NSMutableArray()
    
    //MARK: - XIB链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        //从xib加载view
        view = Bundle.main.loadNibNamed("SAMStockDetailController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - UICollectionViewDataSource
extension SAMStockDetailController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productDeatilList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMStockProductDetailCellReuseIdentifier, for: indexPath) as! SAMStockProductDetailCell
        
        //赋值模型
        let model = productDeatilList[indexPath.row] as! SAMStockProductDeatil
        cell.productDetailModel = model
        return cell
    }
}

//MARK: - collectionView布局代理
extension SAMStockDetailController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: 35)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
