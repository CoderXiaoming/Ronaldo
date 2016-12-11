//
//  SAMStockProductCell.swift
//  SaleManager
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import SDWebImage

//库存明细重用标识符
private let SAMStockProductDetailCellReuseIdentifier = "SAMStockProductDetailCellReuseIdentifier"

//MARK: - 代理方法
protocol SAMStockProductCellDelegate: NSObjectProtocol {
    func productCellDidClickShoppingCarButton(stockProductModel: SAMStockProductModel, stockProductImage: UIImage)
    func productCellDidClickStockWarnningButton(stockProductModel: SAMStockProductModel)
    func productCellDidClickProductImageButton(stockProductModel: SAMStockProductModel)
}

class SAMStockProductCell: UICollectionViewCell {

    ///代理
    weak var delegate: SAMStockProductCellDelegate?
    
    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            
            //设置产品图片
            if stockProductModel?.thumbURL1 != nil {
                productImageBtn.sd_setBackgroundImageWithURL(stockProductModel?.thumbURL1!, forState: .Normal, placeholderImage: UIImage(named: "photo_loadding"))
            }else {
                productImageBtn.setBackgroundImage(UIImage(named: "photo_loadding"), forState: .Normal)
            }
            
            //设置产品名称
            if stockProductModel!.productIDName != "" {
                productNameLabel.text = stockProductModel!.productIDName
            }else {
                productNameLabel.text = "---"
            }
            
            //设置米数
            mishuLabel.text = String(format: "%.1f", stockProductModel!.countM)
            
            //设置匹数
            pishuLabel.text = String(format: "%d", stockProductModel!.countP)
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    //MARK: - 设置collectionView
    private func setupCollectionView() {
        
        //设置数据源、代理
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //设置背景色
        collectionView.backgroundColor = customBlueColor
        
        //注册cell
        collectionView.registerNib(UINib(nibName: "SAMStockProductDetailCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductDetailCellReuseIdentifier)
        
        //添加collectionView
        contentView.addSubview(collectionView)
        
        //布局collectionView
        //布局子控件,因为要用VFL，先要进行初始化设置
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView" : collectionView, "topContentView":topContentView] as [String : AnyObject]
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:[topContentView]-0-[collectionView(50)]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        
        contentView.addConstraints(cons)
    }
    
    //MARK: - 对外提供方法，主动刷新数据
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    //MARK: - 用户点击事件处理
    @IBAction func stockWaringBtnClick(sender: AnyObject) {
        delegate?.productCellDidClickStockWarnningButton(stockProductModel!)
    }
    @IBAction func shoppingCarBtnClick(sender: AnyObject) {
        delegate?.productCellDidClickShoppingCarButton(stockProductModel!, stockProductImage: productImageBtn.backgroundImageForState(.Normal)!)
    }
    @IBAction func productImageBtnClick(sender: AnyObject) {
        
        delegate?.productCellDidClickProductImageButton(stockProductModel!)
    }
    
    //MARK: - 属性懒加载
    //collectionView
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: SAMStockProductDetailColletionViewFlowlayout())
        return view
    }()
    
    //MARK: - XIB链接属性
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var productImageBtn: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var stockWarningBtn: UIButton!
    @IBOutlet weak var shoppingCarBtn: UIButton!
}

//MARK: - UICollectionViewDelegate
extension SAMStockProductCell: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDataSource
extension SAMStockProductCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = stockProductModel?.productDeatilList.count ?? 0
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SAMStockProductDetailCellReuseIdentifier, forIndexPath: indexPath) as! SAMStockProductDetailCell

        //取出模型
        let model = stockProductModel?.productDeatilList[indexPath.row] as! SAMStockProductDeatil
        cell.productDetailModel = model
        return cell
    }
}

//MARK: - 产品详情布局里用到的FlowLayout
private class SAMStockProductDetailColletionViewFlowlayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        itemSize = CGSize(width: 100, height: 40)
        sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
    }
    
}
