//
//  SAMOrderDetailBigCell.swift
//  SaleManager
//
//  Created by apple on 16/12/8.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

///产品cell重用标识符
private let SAMOrderDetailListCellReuseIdentifier = "SAMStockProductCellReuseIdentifier"

///产品cell正常状态size
private let SAMOrderDetailListCellNormalSize = CGSize(width: ScreenW, height: 74)
///产品cell选中状态size
private let SAMOrderDetailListCellSelectedSize = CGSize(width: ScreenW, height: 102)

class SAMOrderDetailBigCell: UICollectionViewCell {

    //mark: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置collectionView
        setupCollectionView()
    }

    //MARK: - 初始化collectionView
    fileprivate func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMOrderDetailListCell", bundle: nil), forCellWithReuseIdentifier: SAMOrderDetailListCellReuseIdentifier)
    }

    //MARK: - 懒加载集合
    ///数据模型数组
    var orderDetailListModelArr: NSMutableArray? {
        didSet{
            //刷新数据
            self.collectionView.reloadData()
        }
    }
    
    ///当前选中IndexPath
    fileprivate var selectedIndexPath : IndexPath?
    
    //MARK: - XIB链接属性
    @IBOutlet weak var collectionView: UICollectionView!
}

//MARK: - UICollectionViewDelegate
extension SAMOrderDetailBigCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            //清空记录
            selectedIndexPath = nil
        } else { //选中了其他的CELL
            
            //记录数据
            selectedIndexPath = indexPath
        }
        
        //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
        self.collectionView.performBatchUpdates({
        }) { (finished) in
            
            //如果点击了最下面一个cell，则滚至最底部
            if self.selectedIndexPath?.row == (self.orderDetailListModelArr!.count - 1) {
                self.collectionView.scrollToItem(at: self.selectedIndexPath!, at: .bottom, animated: true)
            }
        }
    }
}

//MARK: - UICollectionViewDataSource
extension SAMOrderDetailBigCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if orderDetailListModelArr == nil {
            return 0
        }else {
            return orderDetailListModelArr!.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMOrderDetailListCellReuseIdentifier, for: indexPath) as! SAMOrderDetailListCell
        
        //取出模型
        let model = orderDetailListModelArr![indexPath.row] as! SAMSaleOrderDetailListModel
        cell.orderDetailListModel = model
        return cell
    }
}

//MARK: - collectionView布局代理
extension SAMOrderDetailBigCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath == selectedIndexPath {
            return SAMOrderDetailListCellSelectedSize
        }
        
        return SAMOrderDetailListCellNormalSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
