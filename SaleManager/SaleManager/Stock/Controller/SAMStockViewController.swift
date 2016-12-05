//
//  SAMStockViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJRefresh

//刚是否成功上传成功图片
var SAMStockHasUnloadProductImage = false

///产品cell重用标识符
private let SAMStockProductCellReuseIdentifier = "SAMStockProductCellReuseIdentifier"

///产品cell正常状态size
private let SAMStockProductCellNormalSize = CGSize(width: ScreenW, height: 75)
///产品cell选中状态size
private let SAMStockProductCellSelectedSize = CGSize(width: ScreenW, height: 126)

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
        navigationItem.title = "库存查询"
        view.backgroundColor = UIColor.whiteColor()
        
        //设置导航栏右边按钮
        setupRightNavBarItem()
    }
    
    //MARK: - 设置导航栏右边按钮
    private func setupRightNavBarItem() {
        
        let conSearchBtn = UIButton()
        conSearchBtn.setImage(UIImage(named: "nameScan_nav"), forState: .Normal)
        conSearchBtn.sizeToFit()
        conSearchBtn.addTarget(self, action: #selector(SAMStockViewController.conSearchBtnClick), forControlEvents: .TouchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: conSearchBtn)
    }
    
    //MARK: - 初始化collectionView
    private func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.registerNib(UINib(nibName: "SAMStockProductCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchNewInfo))
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchMoreInfo))
        //没有数据自动隐藏footer
        collectionView.mj_footer.automaticallyHidden = true
    }
    
    //MARK: - 总库存按钮点击
    func conSearchBtnClick() {
        conditionalSearchVC.view.transform = CGAffineTransformIdentity
        presentViewController(conditionalSearchVC, animated: true) {
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //判断是否刚上传图片成功
        if SAMStockHasUnloadProductImage {
            
            collectionView.mj_header.beginRefreshing()
            
        }
        
    }
    
    //MARK: - 加载数据
    func loadConSearchNewInfo() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //没有请求参数直接返回
        if conSearchParameters == nil {
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //请求所有数据
        loadStockStatistic()
        
        //创建请求参数
        conSearchPageIndex = 1
        let index = String(format: "%d", conSearchPageIndex)
        let size = String(format: "%d", conSearchPageSize)
        conSearchParameters!["pageSize"] = size
        conSearchParameters!["pageIndex"] = index
        conSearchParameters!["showAlert"] = false
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(conSearchURLStr, parameters: conSearchParameters!, progress: nil, success: { (Task, Json) in
            
            //清空原先数据
            self.stockProductModels.removeAllObjects()
            
            //清空选中index
            self.selectedIndexPath = nil
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                SAMHUD.showMessage("没有符合条件的产品", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMStockProductModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                if arr.count < self.conSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self.conSearchPageIndex += 1
                }
                self.stockProductModels.addObjectsFromArray(arr as [AnyObject])
            }
            
            //结束上拉
            self.collectionView.mj_header.endRefreshing()
            
            //回主线程刷新数据
            dispatch_async(dispatch_get_main_queue(), {
                
                UIView.animateWithDuration(0, animations: {
                    
                    //刷新数据
                    self.collectionView.reloadData()
                    
                    //记录数据
                    SAMStockHasUnloadProductImage = false
                    }, completion: { (_) in
                        
                        //判断顶部条是否隐藏
                        if self.allStockViewTopDistance.constant != 0 {
                            
                            //展示顶部条
                            UIView.animateWithDuration(0.5, delay: 0.2, options: .LayoutSubviews, animations: {
                                //设置stockView顶部距离
                                self.allStockViewTopDistance.constant = 0
                                self.view.layoutIfNeeded()
                                }, completion: { (_) in
                            })
                        }
                })
            })
        }) { (Task, Error) in
            //处理上拉
            self.collectionView.mj_header.endRefreshing()
            SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 加载所有库存数据统计
    private func loadStockStatistic() {
        
        //创建请求参数
        let productIDName = conSearchParameters!["productIDName"] as! String
        let staticParameters = ["productIDName": productIDName, "storehouseID": "-1", "parentID": "-1", "minCountM": "0"]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(statisticSearchURLStr, parameters: staticParameters, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有数据
            if count == 0 { //没有数据
                
                self.totalCountPString = "---"
                self.totalCountMString = "---"
            }else { //有数据
                
                self.totalCountPString = dictArr![0]["totalCountP"] as? String
                self.totalCountMString = dictArr![0]["totalCountM"] as? String
            }
        }) { (Task, Error) in
            self.totalCountPString = "---"
            self.totalCountMString = "---"
        }
    }
    
    //MARK: - 加载更多数据
    func loadConSearchMoreInfo() {
        
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", conSearchPageIndex)
        conSearchParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(conSearchURLStr, parameters: conSearchParameters!, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                SAMHUD.showMessage("没有更多产品", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMStockCodeModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self.conSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self.conSearchPageIndex += 1
                    
                    //处理下拉
                    self.collectionView.mj_footer.endRefreshing()
                }
                self.stockProductModels.addObjectsFromArray(arr as [AnyObject])
                
                //刷新数据
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
            }
        }) { (Task, Error) in
            //处理下拉
            self.collectionView.mj_footer.endRefreshing()
            SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }

    //MARK: - 懒加载属性
    ///条件搜索控制器
    private lazy var conditionalSearchVC: SAMStockConditionalSearchController = {
        let vc = SAMStockConditionalSearchController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.Custom
        vc.setCompletionCallback({[weak self] (parameters) in
            self!.conSearchParameters = parameters
        })
        return vc
    }()
    
    ///条件搜索参数字典
    var conSearchParameters: [String: AnyObject]? {
        didSet {
            if conSearchParameters != nil {
                
                //计算动画所需数据
                let originalFrame = conditionalSearchVC.view.convertRect(conditionalSearchVC.view.frame, toView: view)
                let originalCenterY = (originalFrame.maxY - originalFrame.origin.y) * 0.5
                let transformY = collectionView.frame.origin.y - originalCenterY - 15
                
                //动画隐藏界面
                UIView.animateWithDuration(0.3, animations: {
                    
                    let transform = CGAffineTransformMakeTranslation(0, transformY)
                    self.conditionalSearchVC.view.transform = CGAffineTransformScale(transform, 0.0001, 0.0001)
                }) { (_) in
                    
                    //恢复界面形变，刷新数据
                    self.conditionalSearchVC.dismissViewControllerAnimated(true, completion: {
                        self.conditionalSearchVC.view.transform = CGAffineTransformIdentity
                        self.conditionalSearchVC.view.layoutIfNeeded()
                        self.collectionView.mj_header.beginRefreshing()
                    })
                }
            }
        }
    }
    
    ///条件搜索请求URLStr
    private let conSearchURLStr = "getStock.ashx"
    ///条件搜索请求URLStr
    private let statisticSearchURLStr = "getStockStatic.ashx"
    ///一次数据请求获取的数据最大条数
    private let conSearchPageSize = 15
    ///当前数据的页码
    private var conSearchPageIndex = 1
    
    ///数据模型数组
    let stockProductModels = NSMutableArray()
    
    ///当前选中IndexPath
    private var selectedIndexPath : NSIndexPath?
    
    ///总匹数字符串
    private var totalCountPString: String? {
        didSet{
            pishuLabel.text = totalCountPString
        }
    }
    ///总米数字符串
    private var totalCountMString: String? {
        didSet{
            mishuLabel.text = totalCountMString
        }
    }
    
    ///产品信息展示控制器
    private lazy var productInfoVC: SAMStockProductInfoController? = {
        let vc = SAMStockProductInfoController.infoVC()
        return vc
    }()
    
    //MARK: - xib链接约束属性
    ///所有库存控件顶部距离
    @IBOutlet weak var allStockViewTopDistance: NSLayoutConstraint!
    
    //MARK: - xib链接控件
    @IBOutlet weak var allStockView: UIView!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
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

//MARK: - UICollectionViewDelegate
extension SAMStockViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {

        //监听滚动，达到某一条件的时候让顶部所有库存条上滚消失
        let offsetY = scrollView.contentOffset.y
        
        if stockProductModels.count != 0 {
            if offsetY > 50 {
                if allStockViewTopDistance.constant == 0{
                    UIView.animateWithDuration(0.6, animations: {
                        self.allStockViewTopDistance.constant = -self.allStockView.bounds.height
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            //清空记录
            selectedIndexPath = nil
        } else { //选中了其他的CELL
            
            //记录数据
            selectedIndexPath = indexPath
            
            //取出cell，刷新数据
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! SAMStockProductCell
            
            //如果cell的collectionView
            selectedCell.reloadCollectionView()
        }
        
        //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
        self.collectionView.performBatchUpdates({
        }) { (finished) in
            
            //如果点击了最下面一个cell，则滚至最底部
            if self.selectedIndexPath?.row == (self.stockProductModels.count - 1) {
                self.collectionView.scrollToItemAtIndexPath(self.selectedIndexPath!, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
}

//MARK: - UICollectionViewDataSource
extension SAMStockViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockProductModels.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SAMStockProductCellReuseIdentifier, forIndexPath: indexPath) as! SAMStockProductCell
        
        //取出模型
        let model = stockProductModels[indexPath.row] as! SAMStockProductModel
        cell.stockProductModel = model
        
        //刷新collectionView
        cell.reloadCollectionView()
        
        //设置闭包
        cell.setProductImageClick {[weak self] (stockProductModel) in
            self!.productInfoVC?.stockProductModel = stockProductModel
            self!.navigationController?.pushViewController(self!.productInfoVC!, animated: true)
        }
        return cell
    }
}

//MARK: - collectionView布局代理
extension SAMStockViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath == selectedIndexPath {
            return SAMStockProductCellSelectedSize
        }
        
        return SAMStockProductCellNormalSize
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
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
