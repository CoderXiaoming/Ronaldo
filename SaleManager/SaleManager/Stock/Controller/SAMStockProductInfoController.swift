//
//  SAMStockProductInfoController.swift
//  SaleManager
//
//  Created by apple on 16/11/28.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

class SAMStockProductInfoController: UITableViewController {

    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            //判断productImageVIew是否已经加载
            if productImageVIew != nil {
                productImageVIew.sd_setImage(with: stockProductModel!.thumbURL1! as URL, placeholderImage: UIImage(named: "firstLogo")!)
            }
        }
    }

    //MARK: - 对外提供的类工厂方法
    class func instance() -> SAMStockProductInfoController? {
        return UIStoryboard(name: "SAMStockProductInfoController", bundle: nil).instantiateInitialViewController() as? SAMStockProductInfoController
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //设置标题
        navigationItem.title = "产品信息"
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //初始化UI
        setupUI()
        
        //给图片控制器传递数据模型
        productImageVC?.stockProductModel = stockProductModel
    }
    
    //MARK: - 初始化UI
    func setupUI() {
        //设置产品图片
        if stockProductModel?.thumbURL1 != nil {
            productImageVIew.sd_setImage(with: stockProductModel!.thumbURL1! as URL, placeholderImage: UIImage(named: "firstLogo")!)
        }else {
            productImageVIew.image = UIImage(named: "temp")
            //TODO: temp要更换
        }
        
        //设置编号名称
        if stockProductModel!.productIDName != "" {
            numberLabel.text = stockProductModel!.productIDName
        }else {
            numberLabel.text = "---"
        }
        
        //设置花名
        if stockProductModel!.productIDNameHM != "" {
            huaMingLabel.text = stockProductModel!.productIDNameHM
        }else {
            huaMingLabel.text = "---"
        }
        
        //设置大类
        if stockProductModel!.parentID != "" {
            categoryLabel.text = stockProductModel!.parentID
        }else {
            categoryLabel.text = "---"
        }
        
        //设置条码
        if stockProductModel!.codeName != "" {
            codeNumberLabel.text = stockProductModel!.codeName
        }else {
            codeNumberLabel.text = "---"
        }
        
        //设置规格
        if stockProductModel!.specName != "" {
            rankLabel.text = stockProductModel!.specName
        }else {
            rankLabel.text = "---"
        }
        
        //设置单位
        if stockProductModel!.unit != "" {
            countUnitLabel.text = stockProductModel!.unit
        }else {
            countUnitLabel.text = "---"
        }
        
        //设置单位
        if stockProductModel!.memoInfo != "" {
            remarkLabel.text = stockProductModel!.memoInfo
        }else {
            remarkLabel.text = "---"
        }
    }
    
    //MARK: - 用户点击事件处理
    func navbarBackBtnClick() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 懒加载属性
    //产品图片展示器
    fileprivate lazy var productImageVC: SAMProductImageController? = {
        let vc = SAMProductImageController.instance()
        return vc
    }()
    
    //MARK: - XIB链接属性
    @IBOutlet weak var productImageVIew: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var huaMingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var codeNumberLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var countUnitLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
}

//MARK: - 代理方法
extension SAMStockProductInfoController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }else {
            return 10
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //点击图片Cell跳转
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageIndex = IndexPath(row: 0, section: 0)
        if indexPath == imageIndex {
            navigationController!.pushViewController(productImageVC!, animated: true)
        }
    }
}
