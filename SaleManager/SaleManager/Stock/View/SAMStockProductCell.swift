//
//  SAMStockProductCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

//cell正常高度
let SAMStockProductCellNormalHeight: CGFloat = 75

//库存明细重用标识符
private let SAMStockProductDetailCellReuseIdentifier = "SAMStockProductDetailCellReuseIdentifier"

//MARK: - 代理方法
protocol SAMStockProductCellDelegate: NSObjectProtocol {
    func productCellDidClickShoppingCarButton(_ stockProductModel: SAMStockProductModel, stockProductImage: UIImage)
    func productCellDidClickStockWarnningButton(_ stockProductModel: SAMStockProductModel)
    func productCellDidClickProductImageButton(_ stockProductModel: SAMStockProductModel)
}

class SAMStockProductCell: UICollectionViewCell {

    ///代理
    weak var delegate: SAMStockProductCellDelegate?
    
    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            
            //设置产品图片
            if stockProductModel?.thumbURL1 != nil {
                productImageBtn.sd_setBackgroundImage(with: stockProductModel?.thumbURL1!, for: .normal, placeholderImage: UIImage(named: "photo_loadding"))
            }else {
                productImageBtn.setBackgroundImage(UIImage(named: "photo_loadding"), for: UIControlState())
            }
            
            //设置产品名称
            productNameLabel.text = stockProductModel!.productIDName
            
            //设置米数
            mishuLabel.text = stockProductModel!.countMText
            
            //设置匹数
            pishuLabel.text = stockProductModel!.countPText
            
            //设置警告，购物车按钮状态
            stockWarningBtn.isEnabled = couldOperateWarningAndCar
            shoppingCarBtn.isEnabled = couldOperateWarningAndCar
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置图片圆角
        productImageBtn.layer.cornerRadius = 10
        
        //设置CollectionView
        setupCollectionView()
    }
    
    //MARK: - 设置collectionView
    fileprivate func setupCollectionView() {
        
        //设置数据源、代理
        collectionView.dataSource = self
        
        //设置背景色
        collectionView.backgroundColor = customBlueColor
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMStockProductDetailCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductDetailCellReuseIdentifier)
        
        //添加collectionView
        contentView.addSubview(collectionView)
        
        //布局collectionView
        //布局子控件,因为要用VFL，先要进行初始化设置
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView" : collectionView, "topContentView":topContentView] as [String : AnyObject]
        
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:[topContentView]-0-[collectionView(1000)]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        
        contentView.addConstraints(cons)
    }
    
    //MARK: - 对外提供方法，主动刷新数据
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    //MARK: - 用户点击事件处理
    @IBAction func stockWaringBtnClick(_ sender: AnyObject) {
        delegate?.productCellDidClickStockWarnningButton(stockProductModel!)
    }
    @IBAction func shoppingCarBtnClick(_ sender: AnyObject) {
        delegate?.productCellDidClickShoppingCarButton(stockProductModel!, stockProductImage: productImageBtn.backgroundImage(for: UIControlState())!)
    }
    @IBAction func productImageBtnClick(_ sender: AnyObject) {
        
        delegate?.productCellDidClickProductImageButton(stockProductModel!)
    }
    
    //MARK: - 属性懒加载
    //collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMStockProductDetailColletionViewFlowlayout())
        return view
    }()
    
    ///库存警告，购物车按钮是否可用，对外提供设置
    var couldOperateWarningAndCar = true
    
    //MARK: - XIB链接属性
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var productImageBtn: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var stockWarningBtn: UIButton!
    @IBOutlet weak var shoppingCarBtn: UIButton!
}

//MARK: - UICollectionViewDataSource
extension SAMStockProductCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = stockProductModel?.productDeatilList.count ?? 0
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMStockProductDetailCellReuseIdentifier, for: indexPath) as! SAMStockProductDetailCell
        
        //取出模型
        let model = stockProductModel?.productDeatilList[indexPath.row] as! SAMStockProductDeatil
        cell.productDetailModel = model
        return cell
    }
}

//MARK: - 产品详情布局里用到的FlowLayout
private class SAMStockProductDetailColletionViewFlowlayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = SAMStockProductDetailCellMinimumLineSpacing
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView?.showsVerticalScrollIndicator = false
        itemSize = CGSize(width: SAMStockProductDetailCellWidth, height: SAMStockProductDetailCellHeight)
        sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
    }
}
