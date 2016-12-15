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
    
    ///单例
    static let instance = SAMStockViewController()
    
    ///对外提供的类工厂方法
    class func shareInstanc() -> SAMStockViewController {
        return instance
    }
    
    ///对外提供查询某个字符串相关库存信息的方法
    class func stockRequest(productName: String) {
    
        //赋值
        instance.productNameSearchStr = productName
        
        //设置记录状态
        instance.isProductNameSearch = true
        instance.hasOutRequest = true
    }
    
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
        
        //设置textField监听方法
        productNameTF.addTarget(self, action: #selector(SAMStockViewController.textFieldDidEditChange(_:)), forControlEvents: .EditingChanged)
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
    
    //MARK: - 搜索按钮点击
    func conSearchBtnClick() {
        
        //判断当前是产品名搜索状态还是条件搜索状态
        if isProductNameSearch { //产品名搜索状态
            
            //退出编辑
            endProductNameTFEditing(false)
            
            //开始搜索
            collectionView.mj_header.beginRefreshing()
        }else { //条件搜索状态
        
            //清空产品名文本框，退出编辑
            endProductNameTFEditing(true)
            
            //展示条件搜索界面
            conditionalSearchVC.view.transform = CGAffineTransformIdentity
            presentViewController(conditionalSearchVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //判断是否刚上传图片成功 或者是否有外界请求
        if SAMStockHasUnloadProductImage || hasOutRequest {
            
            collectionView.mj_header.beginRefreshing()
            
            if hasOutRequest {
                
                //赋值文本框
                productNameTF.text = productNameSearchStr
            }
        }
    }
    
    //MARK: - 加载数据
    func loadConSearchNewInfo() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //记录已经刷新
        SAMStockHasUnloadProductImage = false
        hasOutRequest = false
        
        //如果当前不是产品名搜索而且没有请求参数直接返回
        if !isProductNameSearch && (conSearchParameters == nil) {
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //如果是产品名搜索，设置请求参数
        if isProductNameSearch {
            conSearchParameters = ["productIDName": productNameSearchStr!, "minCountM": "0", "parentID": "-1", "storehouseID": "-1"]
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
    
    //MARK: - 添加到购物车之后的动画方法
    private func addToShoppingCarSuccess(productImage: UIImage) {
        
        //设置用户界面不可交互
        tabBarController?.view.userInteractionEnabled = false
        
        //设置动画layer
        productAnimlayer!.contents = productImage.CGImage
        KeyWindow?.layer.addSublayer(productAnimlayer!)
        productAnimlayer?.addAnimation(groupAnimation, forKey: "group")
    }
    
    //MARK: - 文本框监听的方法
    func textFieldDidEditChange(textField: UITextField) {
        
        //获取搜索字符串
        productNameSearchStr = textField.text!.lxm_stringByTrimmingWhitespace()
        
        //设置是否产品名称搜索状态
        isProductNameSearch = (productNameSearchStr != "") ? true : false
    }
    
    //MARK: - 结束产品文本框编辑状态
    private func endProductNameTFEditing(clear: Bool) {
        if clear {
            productNameTF.text = ""
        }
        productNameTF.resignFirstResponder()
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
            if (conSearchParameters != nil) && !isProductNameSearch {
                
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
    ///总库存搜索请求URLStr
    private let statisticSearchURLStr = "getStockStatic.ashx"
    ///一次数据请求获取的数据最大条数
    private let conSearchPageSize = 15
    ///当前数据的页码
    private var conSearchPageIndex = 1
    
    ///当前是否有外界查询请求
    private var hasOutRequest: Bool = false
    ///外界查询请求产品名称
    private var outRequestProductName: String?
    
    ///当前是否为单独产品名搜索
    private var isProductNameSearch: Bool = false
    ///单独产品名搜索字符串
    private var productNameSearchStr: String?
    
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
    
    ///购物车选择控件
    private var shoppingCarView: SAMStockAddShoppingCarView?
    
    ///展示购物车时，主界面添加的蒙版
    private lazy var shoppingCarMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.mainScreen().bounds)
        maskView.backgroundColor = UIColor.blackColor()
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMStockViewController.hideShoppingCarViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()
    
    ///添加购物车成功时候的动画layer
    private lazy var productAnimlayer: CALayer? = {
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspectFill
        layer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.position = CGPointMake(50, ScreenH)
        KeyWindow?.layer.addSublayer(layer)
        return layer
    }()
    
    ///添加购物车成功时，layer执行的组动画
    private lazy var groupAnimation: CAAnimationGroup = {
        
        /******************  layer动画路线  ******************/
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        //动画路线
        let path = UIBezierPath()
        //计算各点
        let startPoint = CGPoint(x: 30, y: ScreenH)
        let endPoint = CGPoint(x: ScreenW * (3 / 5) + 23, y: ScreenH - 43)
        let controlPoint = CGPoint(x: (endPoint.x - startPoint.x) * 0.5, y: (endPoint.y - 250))
        //连线
        path.moveToPoint(startPoint)
        path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
        
        pathAnimation.path = path.CGPath
        pathAnimation.rotationMode = kCAAnimationRotateAuto
        
        /******************  layer放大动画  ******************/
        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.fromValue = 0.5
        expandAnimation.toValue = 2
        expandAnimation.duration = 0.4
        expandAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        /******************  layer缩小动画  ******************/
        let narrowAnimation = CABasicAnimation(keyPath: "transform.scale")
        narrowAnimation.fromValue = 2
        narrowAnimation.toValue = 0.4
        narrowAnimation.beginTime = 0.4
        narrowAnimation.duration = 0.5
        expandAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let group = CAAnimationGroup()
        group.animations = [pathAnimation,expandAnimation,narrowAnimation]
        group.duration = 0.79
        group.removedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate = self
        
        return group
    }()
    
    //MARK: - xib链接约束属性
    ///所有库存控件顶部距离
    @IBOutlet weak var allStockViewTopDistance: NSLayoutConstraint!
    
    //MARK: - xib链接控件
    @IBOutlet weak var allStockView: UIView!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    @IBOutlet weak var productNameTF: SAMLoginTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicaterView: UIView!
    
    //MARK: - 其他方法
    private init() { //重写该方法，为单例服务
        super.init(nibName: nil, bundle: nil)
    }
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        //从xib加载view
        view = NSBundle.mainBundle().loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - CollectionView代理UICollectionViewDelegate
extension SAMStockViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {

        //退出产品名搜索框编辑状态
        endProductNameTFEditing(false)
        
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

//MARK: - CollectionView数据源方法UICollectionViewDataSource
extension SAMStockViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockProductModels.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SAMStockProductCellReuseIdentifier, forIndexPath: indexPath) as! SAMStockProductCell
        
        //取出模型
        let model = stockProductModels[indexPath.row] as! SAMStockProductModel
        cell.stockProductModel = model
        
        //设置代理
        cell.delegate = self
        
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

//MARK: - 条件搜索控制器的动画代理UIViewControllerTransitioningDelegate
extension SAMStockViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}

//MARK: - 库存产品CELL的代理SAMStockProductCellDelegate
extension SAMStockViewController: SAMStockProductCellDelegate {
    
    //点击了购物车
    func productCellDidClickShoppingCarButton(stockProductModel: SAMStockProductModel, stockProductImage: UIImage) {
        
        //展示购物车
        showShoppingCar(stockProductImage, productModel: stockProductModel)
    }
    
    //点击了库存警报
    func productCellDidClickStockWarnningButton(stockProductModel: SAMStockProductModel) {
    
    }
    
    //点击了产品图片
    func productCellDidClickProductImageButton(stockProductModel: SAMStockProductModel) {
        
        //展示产品详情控制器
        let productInfoVC = SAMStockProductInfoController.infoVC()
        productInfoVC!.stockProductModel = stockProductModel
        navigationController!.pushViewController(productInfoVC!, animated: true)
    }
}

//MARK: - 购物车控件代理SAMStockAddShoppingCarViewDelegate
extension SAMStockViewController: SAMStockAddShoppingCarViewDelegate {

    func shoppingCarViewDidClickDismissButton() {
        
        //隐藏购物车
        hideShoppingCarView(false, produtImage: nil)
    }
    
    func shoppingCarViewAddOrEditProductSuccess(productImage: UIImage) {
        //隐藏购物车
        hideShoppingCarView(true, produtImage: productImage)
    }
    
    //MARK: - 购物车相关4各方法
    //主控制器View展示购物车时的第一步形变
    private func firstTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m24 = -1/2000
        transform = CATransform3DScale(transform, 0.9, 0.9, 1)
        return transform
    }
    
    //主控制器View展示购物车时的第二步形变
    private func secondTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, self.view.frame.size.height * (-0.08), 0)
        transform = CATransform3DScale(transform, 0.8, 0.8, 1)
        return transform
    }
    
    //展示购物车控件
    private func showShoppingCar(productImage: UIImage, productModel: SAMStockProductModel) {
    
        //设置购物车控件的目标frame
        shoppingCarView = SAMStockAddShoppingCarView.shoppingCarViewWillShow(productImage, addProductModel: productModel, editProductModel: nil)
        shoppingCarView!.delegate = self
        shoppingCarView!.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: 350)
        
        var rect = shoppingCarView!.frame
        rect.origin.y = ScreenH - rect.size.height
        
        //添加背景View
        tabBarController!.view.addSubview(shoppingCarMaskView)
        KeyWindow?.addSubview(shoppingCarView!)
        
        //动画展示购物车控件
        UIView.animateWithDuration(0.5) {
            self.shoppingCarView!.frame = rect
        }
        
        //动画移动背景View
        UIView.animateWithDuration(0.25, animations: {
            
            //执行第一步动画
            self.shoppingCarMaskView.alpha = 0.5
            self.tabBarController!.view.layer.transform = self.firstTran()
        }) { (_) in
            
            //执行第二步动画
            UIView.animateWithDuration(0.25, animations: {
                self.tabBarController!.view.layer.transform = self.secondTran()
                }, completion: { (_) in
            })
        }
    }
    
    //点击maskView隐藏购物车控件
    func hideShoppingCarViewWhenMaskViewDidClick() {
        
        hideShoppingCarView(false, produtImage: nil)
    }
    
    //隐藏购物车控件
    private func hideShoppingCarView(didAddProduct: Bool, produtImage: UIImage?) {
        
        //设置购物车目标frame
        var rect = self.shoppingCarView!.frame
        rect.origin.y = ScreenH
        
        //动画隐藏购物车控件
        UIView.animateWithDuration(0.5) {
            self.shoppingCarView!.frame = rect
        }
        
        //动画展示主View
        UIView.animateWithDuration(0.25, animations: {
            
            self.tabBarController!.view.layer.transform = self.firstTran()
            self.shoppingCarMaskView.alpha = 0.0
        }) { (_) in
            
            //移除蒙板
            self.shoppingCarMaskView.removeFromSuperview()
            
            UIView.animateWithDuration(0.25, animations: {
                
                self.tabBarController!.view.layer.transform = CATransform3DIdentity
                }, completion: { (_) in
                    
                    //移除购物车
                    self.shoppingCarView!.removeFromSuperview()
                    
                    //调用成功添加购物车的动画
                    if didAddProduct {
                        self.addToShoppingCarSuccess(produtImage!)
                    }
            })
        }
    }
}

//MARK: - CAAnimationDelegate
extension SAMStockViewController: CAAnimationDelegate {
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
    
        if anim == productAnimlayer?.animationForKey("group") {
            
            //改变shoppingCar控制器的badgeValue
            SAMShoppingCarController.sharedInstance().addOrMinusProductCountOne(true)
            
            //恢复界面交互状态
            tabBarController?.view.userInteractionEnabled = true
            
            //移除动画
            productAnimlayer?.removeFromSuperlayer()
            
            //移除动画图层
            productAnimlayer?.removeFromSuperlayer()
        }
    }
}

//MARK: - UITextFieldDelegate
extension SAMStockViewController: UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //结束编辑状态
        endProductNameTFEditing(false)
        
        //出发collectionView下拉
        collectionView.mj_header.beginRefreshing()
        return true
    }
}



