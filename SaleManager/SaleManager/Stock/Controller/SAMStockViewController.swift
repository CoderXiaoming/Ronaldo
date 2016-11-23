//
//  SAMStockViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

private let productCellReuseIdentifier = "productCellReuseIdentifier"

class SAMStockViewController: UIViewController {
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //设置展示库存的collectionView
        setupCollectionView()
    }
    
    //MARK: - 初始化UI
    private func setupUI() {
        title = "库存查询"
        view.backgroundColor = UIColor.whiteColor()
        
        //设置导航栏右边的所有选项
        setupRightNavBarItems()
        
        //添加搜索框上部间距
        searchBarTopConstraint.constant = navigationController!.navigationBar.frame.maxY
    }
    
    //MARK: - 设置导航栏右边所有的按钮
    private func setupRightNavBarItems() {
        let nameScanBtn = UIButton()
        nameScanBtn.setImage(UIImage(named: "nameScan_nav"), forState: .Normal)
        nameScanBtn.sizeToFit()
        nameScanBtn.addTarget(self, action: #selector(SAMStockViewController.nameScanBtnClick), forControlEvents: .TouchUpInside)
        let codeScanBtn = UIButton()
        codeScanBtn.setImage(UIImage(named: "codeScan_nav"), forState: .Normal)
        codeScanBtn.sizeToFit()
        codeScanBtn.addTarget(self, action: #selector(SAMStockViewController.codeScanBtnClick), forControlEvents: .TouchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: codeScanBtn), UIBarButtonItem(customView: nameScanBtn)]
    }
    
    //MARK: - 设置collectionView
    private func setupCollectionView() {
        //设置内容的下边距
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, tabBarController!.tabBar.bounds.height, 0)
        //设置代理，数据源
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //注册cell
        collectionView.registerClass(SAMStockProductCell.self, forCellWithReuseIdentifier: productCellReuseIdentifier)
    }
    
    //MARK: - 总库存按钮点击
    func nameScanBtnClick() {
//        UIView.animateWithDuration(0.6) {
//            self.searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.maxY - self.searchBar.bounds.height
//            self.stockVTop_searchBar_space.constant = -(self.allStockView.bounds.height)
//            self.view.layoutIfNeeded()
//        }
        presentViewController(conditionalSearchVC, animated: true) { 
            
        }
        
    }
    //MARK: - 二维码按钮点击
    func codeScanBtnClick() {
        UIView.animateWithDuration(0.6) {
            self.searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.maxY
            self.view.layoutIfNeeded()
        }
    }
    
    ///展示的数据模型
    var productModels: [SAMProductInfo] = {
        let model1 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model1.moreInfo = [
                        SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
                        SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309),
                        SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709),
                        SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709),
                        SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709)]
        let model2 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model2.moreInfo = [
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309)]
        let model3 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model3.moreInfo = [
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709)]
        let model4 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model4.moreInfo = [
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709)]
        let model5 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model5.moreInfo = [
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709)]
        let model6 = SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02", pishuN: 22.0, mishuN: 2308)
        model6.moreInfo = [
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-01#", pishuN: 2.0, mishuN: 200),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-02#", pishuN: 13, mishuN: 1309),
            SAMProductInfo(pictureN: UIImage(named: "saled"), nameN: "H28-02-03#", pishuN: 7, mishuN: 709)]
        
        return [model1, model2, model3, model4, model5, model6]
    }()
    
    var realHeigts = [240, 180, 240, 360, 240, 240]
    
    //MARK: - 懒加载属性
    private lazy var conditionalSearchVC: SAMStockConditionalSearchController = {
        let vc = SAMStockConditionalSearchController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.Custom
        return vc
    }()
    
    //MARK: - xib链接约束属性
    ///搜索框顶部与控制View的距离
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    ///stockView顶部与搜索框底部的距离
    @IBOutlet weak var stockVTop_searchBar_space: NSLayoutConstraint!
    
    //MARK: - xib链接控件
    @IBOutlet weak var allStockView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var warrningLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicaterView: UIView!
    
    
    
    
    //MARK: - 其他方法
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - loadView
    override func loadView() {
        //从xib加载view
        view = NSBundle.mainBundle().loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
    }
}

extension SAMStockViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        UIView.animateWithDuration(0.6) {
            self.searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.maxY - self.searchBar.bounds.height
            self.stockVTop_searchBar_space.constant = -(self.allStockView.bounds.height)
            self.view.layoutIfNeeded()
        }
    }
    
    //dataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productModels.count;
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(productCellReuseIdentifier, forIndexPath: indexPath) as! SAMStockProductCell
        cell.backgroundColor = UIColor.redColor()
        cell.productModel = productModels[indexPath.row]
        return cell
    }
    //FlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let realHeight = realHeigts[indexPath.row]
        
        return CGSize(width: ScreenW, height: CGFloat(realHeight))
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension SAMStockViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}
