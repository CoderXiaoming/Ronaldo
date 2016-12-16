//
//  SAMOrderDetailListCell.swift
//  SaleManager
//
//  Created by apple on 16/12/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

//订单详情列表CELL重用标识符
private let SAMOrderMishuCellReuseIdentifier = "SAMOrderMishuCellReuseIdentifier"

class SAMOrderDetailListCell: UICollectionViewCell {

    ///接收的数据模型
    var orderDetailListModel: SAMSaleOrderDetailListModel? {
        didSet{
            
            //刷新collectionView
            self.collectionView.reloadData()
            
            //设置产品名称
            if orderDetailListModel!.productIDName != "" {
                productNumLabel.text = orderDetailListModel!.productIDName
            }else {
                productNumLabel.text = "---"
            }
            
            //设置匹数
            pishuLabel.text = String(format: "%.1f", orderDetailListModel!.countP)
            
            //设置米数
            mishuLabel.text = String(format: "%.1f", orderDetailListModel!.countM)
            
            //设置单价
            priceLabel.text = String(format: "%.1f", orderDetailListModel!.price)
            
            //设置价格小计
            countPriceLabel.text = String(format: "%.1f", orderDetailListModel!.smallMoney)
            
            //设置备注
            if orderDetailListModel!.memoInfo != "" {
                remarkLabel.text = orderDetailListModel!.memoInfo
            }else {
                remarkLabel.text = "---"
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    //MARK: - 设置collectionView
    fileprivate func setupCollectionView() {
        
        //设置数据源、代理
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //设置背景色
        collectionView.backgroundColor = customBlueColor
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMOrderMishuCell", bundle: nil), forCellWithReuseIdentifier: SAMOrderMishuCellReuseIdentifier)
        
        //添加collectionView
        contentView.addSubview(collectionView)
        
        //布局collectionView
        //布局子控件,因为要用VFL，先要进行初始化设置
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView" : collectionView, "remarkLabel":remarkLabel] as [String : AnyObject]
        
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:[remarkLabel]-5-[collectionView(28)]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        
        contentView.addConstraints(cons)
    }

    //MARK: - 属性懒加载
    //collectionView
    fileprivate lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMSOrderDetailListColletionViewFlowlayout())
        return view
    }()
    
    //MARK: - xib链接属性
    @IBOutlet weak var productNumLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countPriceLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
}

//MARK: - UICollectionViewDelegate
extension SAMOrderDetailListCell: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDataSource
extension SAMOrderDetailListCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = orderDetailListModel?.meterArr.count ?? 0

        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMOrderMishuCellReuseIdentifier, for: indexPath) as! SAMOrderMishuCell
        
        //取出米数字符串并赋值
        cell.miText = orderDetailListModel?.meterArr[indexPath.row]
        return cell
    }
}

//MARK: - 产品详情布局里用到的FlowLayout
private class SAMSOrderDetailListColletionViewFlowlayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.horizontal
        collectionView?.showsHorizontalScrollIndicator = false
        itemSize = CGSize(width: 80, height: 18)
        sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
}
