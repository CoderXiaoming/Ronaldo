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
    class func stockRequest(shoppingCarListModel: SAMShoppingCarListModel){
    
        //购物车数据模型
        instance.shoppingCarListModel = shoppingCarListModel
        
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
    fileprivate func setupUI() {
        navigationItem.title = "库存查询"
        view.backgroundColor = UIColor.white
        
        //设置导航栏右边按钮
        setupRightNavBarItem()
        
        //设置textField监听方法
        productNameTF.addTarget(self, action: #selector(SAMStockViewController.textFieldDidEditChange(_:)), for: .editingChanged)
    }
    
    //MARK: - 设置导航栏右边按钮
    fileprivate func setupRightNavBarItem() {
        
        let conSearchBtn = UIButton()
        conSearchBtn.setImage(UIImage(named: "nameScan_nav"), for: UIControlState())
        conSearchBtn.sizeToFit()
        conSearchBtn.addTarget(self, action: #selector(SAMStockViewController.conSearchBtnClick), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: conSearchBtn)
    }
    
    //MARK: - 初始化collectionView
    fileprivate func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMStockProductCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchNewInfo))
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchMoreInfo))
        //没有数据自动隐藏footer
        collectionView.mj_footer.isAutomaticallyHidden = true
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
            conditionalSearchVC.view.transform = CGAffineTransform.identity
            present(conditionalSearchVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
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
            conSearchParameters = ["productIDName": productNameSearchStr! as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject]
        }
        
        //请求所有数据
        loadStockStatistic()
        
        //创建请求参数
        conSearchPageIndex = 1
        let index = String(format: "%d", conSearchPageIndex)
        let size = String(format: "%d", conSearchPageSize)
        conSearchParameters!["pageSize"] = size as AnyObject?
        conSearchParameters!["pageIndex"] = index as AnyObject?
        conSearchParameters!["showAlert"] = false as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(conSearchURLStr, parameters: conSearchParameters!, progress: nil, success: { (Task, json) in
            
            //清空原先数据
            self.stockProductModels.removeAllObjects()
            
            //清空选中index
            self.selectedIndexPath = nil
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有符合条件的产品", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self.conSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self.conSearchPageIndex += 1
                }
                self.stockProductModels.addObjects(from: arr as [AnyObject])
                
                if self.shoppingCarListModel != nil { //当前为购物车传过来查询库存的数据
                    let model = self.stockProductModels[0] as! SAMStockProductModel
                    self.shoppingCarListModel?.stockCountP = model.countP
                    self.shoppingCarListModel?.stockCountM = model.countM
                    self.shoppingCarListModel = nil
                }
            }
            
            //结束上拉
            self.collectionView.mj_header.endRefreshing()
            
            //回主线程刷新数据
            DispatchQueue.main.async(execute: {
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self.collectionView.reloadData()
                    
                    }, completion: { (_) in
                        
                        //判断顶部条是否隐藏
                        if self.allStockViewTopDistance.constant != 0 {
                            
                            //展示顶部条
                            UIView.animate(withDuration: 0.5, delay: 0.2, options: .layoutSubviews, animations: {
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
            let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 加载所有库存数据统计
    fileprivate func loadStockStatistic() {
        
        //创建请求参数
        let productIDName = conSearchParameters!["productIDName"] as! String
        let staticParameters = ["productIDName": productIDName, "storehouseID": "-1", "parentID": "-1", "minCountM": "0"]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(statisticSearchURLStr, parameters: staticParameters, progress: nil, success: { (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
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
        conSearchParameters!["pageIndex"] = index as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(conSearchURLStr, parameters: conSearchParameters!, progress: nil, success: { (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多产品", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMStockCodeModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
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
                self.stockProductModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            }
        }) { (Task, Error) in
            //处理下拉
            self.collectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 添加到购物车之后的动画方法
    fileprivate func addToShoppingCarSuccess(_ productImage: UIImage) {
        
        //设置用户界面不可交互
        tabBarController?.view.isUserInteractionEnabled = false
        
        //设置动画layer
        productAnimlayer!.contents = productImage.cgImage
        KeyWindow?.layer.addSublayer(productAnimlayer!)
        productAnimlayer?.add(groupAnimation, forKey: "group")
    }
    
    //MARK: - 文本框监听的方法
    func textFieldDidEditChange(_ textField: UITextField) {
        
        //获取搜索字符串
        productNameSearchStr = textField.text!.lxm_stringByTrimmingWhitespace()
        
        //设置是否产品名称搜索状态
        isProductNameSearch = (productNameSearchStr != "") ? true : false
    }
    
    //MARK: - 结束产品文本框编辑状态
    fileprivate func endProductNameTFEditing(_ clear: Bool) {
        if clear {
            productNameTF.text = ""
        }
        let _ = productNameTF.resignFirstResponder()
    }

    //MARK: - 懒加载属性
    ///条件搜索控制器
    fileprivate lazy var conditionalSearchVC: SAMStockConditionalSearchController = {
        let vc = SAMStockConditionalSearchController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.custom
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
                let originalFrame = conditionalSearchVC.view.convert(conditionalSearchVC.view.frame, to: view)
                let originalCenterY = (originalFrame.maxY - originalFrame.origin.y) * 0.5
                let transformY = collectionView.frame.origin.y - originalCenterY - 15
                
                //动画隐藏界面
                UIView.animate(withDuration: 0.3, animations: {
                    
                    let transform = CGAffineTransform(translationX: 0, y: transformY)
                    self.conditionalSearchVC.view.transform = transform.scaledBy(x: 0.0001, y: 0.0001)
                }, completion: { (_) in
                    
                    //恢复界面形变，刷新数据
                    self.conditionalSearchVC.dismiss(animated: true, completion: {
                        self.conditionalSearchVC.view.transform = CGAffineTransform.identity
                        self.conditionalSearchVC.view.layoutIfNeeded()
                        self.collectionView.mj_header.beginRefreshing()
                    })
                }) 
            }
        }
    }
    
    ///条件搜索请求URLStr
    fileprivate let conSearchURLStr = "getStock.ashx"
    ///总库存搜索请求URLStr
    fileprivate let statisticSearchURLStr = "getStockStatic.ashx"
    ///一次数据请求获取的数据最大条数
    fileprivate let conSearchPageSize = 15
    ///当前数据的页码
    fileprivate var conSearchPageIndex = 1
    
    ///当前是否有外界查询请求
    fileprivate var hasOutRequest: Bool = false
    ///外界查询请求产品名称
    fileprivate var outRequestProductName: String?
    
    ///当前是否为单独产品名搜索
    fileprivate var isProductNameSearch: Bool = false
    ///单独产品名搜索字符串
    fileprivate var productNameSearchStr: String?
    
    ///购物车穿过来的数据模型
    fileprivate var shoppingCarListModel: SAMShoppingCarListModel? {
        didSet{
            if shoppingCarListModel != nil {
                productNameSearchStr = shoppingCarListModel?.productIDName
            }
        }
    }
    
    ///数据模型数组
    let stockProductModels = NSMutableArray()
    
    ///当前选中IndexPath
    fileprivate var selectedIndexPath : IndexPath?
    
    ///总匹数字符串
    fileprivate var totalCountPString: String? {
        didSet{
            pishuLabel.text = totalCountPString
        }
    }
    ///总米数字符串
    fileprivate var totalCountMString: String? {
        didSet{
            mishuLabel.text = totalCountMString
        }
    }
    
    ///购物车选择控件
    fileprivate var shoppingCarView: SAMStockAddShoppingCarView?
    
    ///展示购物车时，主界面添加的蒙版
    fileprivate lazy var shoppingCarMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMStockViewController.hideShoppingCarViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()
    
    ///添加购物车成功时候的动画layer
    fileprivate lazy var productAnimlayer: CALayer? = {
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspectFill
        layer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.position = CGPoint(x: 50, y: ScreenH)
        KeyWindow?.layer.addSublayer(layer)
        return layer
    }()
    
    ///添加购物车成功时，layer执行的组动画
    fileprivate lazy var groupAnimation: CAAnimationGroup = {
        
        /******************  layer动画路线  ******************/
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        //动画路线
        let path = UIBezierPath()
        //计算各点
        let startPoint = CGPoint(x: 30, y: ScreenH)
        let endPoint = CGPoint(x: ScreenW * (3 / 5) + 23, y: ScreenH - 43)
        let controlPoint = CGPoint(x: (endPoint.x - startPoint.x) * 0.5, y: (endPoint.y - 250))
        //连线
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        
        pathAnimation.path = path.cgPath
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
        group.isRemovedOnCompletion = false
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
        view = Bundle.main.loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - CollectionView代理UICollectionViewDelegate
extension SAMStockViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //退出产品名搜索框编辑状态
        endProductNameTFEditing(false)
        
        //监听滚动，达到某一条件的时候让顶部所有库存条上滚消失
        let offsetY = scrollView.contentOffset.y
        
        if stockProductModels.count != 0 {
            if offsetY > 50 {
                if allStockViewTopDistance.constant == 0{
                    UIView.animate(withDuration: 0.6, animations: {
                        self.allStockViewTopDistance.constant = -self.allStockView.bounds.height
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            //清空记录
            selectedIndexPath = nil
        } else { //选中了其他的CELL
            
            //记录数据
            selectedIndexPath = indexPath
            
            //取出cell，刷新数据
            let selectedCell = collectionView.cellForItem(at: indexPath) as! SAMStockProductCell
            
            //如果cell的collectionView
            selectedCell.reloadCollectionView()
        }
        
        //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
        self.collectionView.performBatchUpdates({
        }) { (finished) in
            
            //如果点击了最下面一个cell，则滚至最底部
            if self.selectedIndexPath?.row == (self.stockProductModels.count - 1) {
                self.collectionView.scrollToItem(at: self.selectedIndexPath!, at: .bottom, animated: true)
            }
        }
    }
}

//MARK: - CollectionView数据源方法UICollectionViewDataSource
extension SAMStockViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockProductModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMStockProductCellReuseIdentifier, for: indexPath) as! SAMStockProductCell
        
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath == selectedIndexPath {
            return SAMStockProductCellSelectedSize
        }
        
        return SAMStockProductCellNormalSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    } 
}

//MARK: - 条件搜索控制器的动画代理UIViewControllerTransitioningDelegate
extension SAMStockViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}

//MARK: - 库存产品CELL的代理SAMStockProductCellDelegate
extension SAMStockViewController: SAMStockProductCellDelegate {
    
    //点击了购物车
    func productCellDidClickShoppingCarButton(_ stockProductModel: SAMStockProductModel, stockProductImage: UIImage) {
        
        //展示购物车
        showShoppingCar(stockProductImage, productModel: stockProductModel)
    }
    
    //点击了库存警报
    func productCellDidClickStockWarnningButton(_ stockProductModel: SAMStockProductModel) {
    
    }
    
    //点击了产品图片
    func productCellDidClickProductImageButton(_ stockProductModel: SAMStockProductModel) {
        
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
    
    func shoppingCarViewAddOrEditProductSuccess(_ productImage: UIImage) {
        //隐藏购物车
        hideShoppingCarView(true, produtImage: productImage)
    }
    
    //MARK: - 购物车相关4各方法
    //主控制器View展示购物车时的第一步形变
    fileprivate func firstTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m24 = -1/2000
        transform = CATransform3DScale(transform, 0.9, 0.9, 1)
        return transform
    }
    
    //主控制器View展示购物车时的第二步形变
    fileprivate func secondTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, self.view.frame.size.height * (-0.08), 0)
        transform = CATransform3DScale(transform, 0.8, 0.8, 1)
        return transform
    }
    
    //展示购物车控件
    fileprivate func showShoppingCar(_ productImage: UIImage, productModel: SAMStockProductModel) {
    
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
        UIView.animate(withDuration: 0.5, animations: {
            self.shoppingCarView!.frame = rect
        }) 
        
        //动画移动背景View
        UIView.animate(withDuration: 0.25, animations: {
            
            //执行第一步动画
            self.shoppingCarMaskView.alpha = 0.5
            self.tabBarController!.view.layer.transform = self.firstTran()
        }, completion: { (_) in
            
            //执行第二步动画
            UIView.animate(withDuration: 0.25, animations: {
                self.tabBarController!.view.layer.transform = self.secondTran()
                }, completion: { (_) in
            })
        }) 
    }
    
    //点击maskView隐藏购物车控件
    func hideShoppingCarViewWhenMaskViewDidClick() {
        
        hideShoppingCarView(false, produtImage: nil)
    }
    
    //隐藏购物车控件
    fileprivate func hideShoppingCarView(_ didAddProduct: Bool, produtImage: UIImage?) {
        
        //设置购物车目标frame
        var rect = self.shoppingCarView!.frame
        rect.origin.y = ScreenH
        
        //动画隐藏购物车控件
        UIView.animate(withDuration: 0.5, animations: {
            self.shoppingCarView!.frame = rect
        }) 
        
        //动画展示主View
        UIView.animate(withDuration: 0.25, animations: {
            
            self.tabBarController!.view.layer.transform = self.firstTran()
            self.shoppingCarMaskView.alpha = 0.0
        }, completion: { (_) in
            
            //移除蒙板
            self.shoppingCarMaskView.removeFromSuperview()
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.tabBarController!.view.layer.transform = CATransform3DIdentity
                }, completion: { (_) in
                    
                    //移除购物车
                    self.shoppingCarView!.removeFromSuperview()
                    
                    //调用成功添加购物车的动画
                    if didAddProduct {
                        self.addToShoppingCarSuccess(produtImage!)
                    }
            })
        }) 
    }
}

//MARK: - CAAnimationDelegate
extension SAMStockViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
        if anim == productAnimlayer?.animation(forKey: "group") {
            
            //改变shoppingCar控制器的badgeValue
            SAMShoppingCarController.sharedInstance().addOrMinusProductCountOne(true)
            
            //恢复界面交互状态
            tabBarController?.view.isUserInteractionEnabled = true
            
            //移除动画
            productAnimlayer?.removeFromSuperlayer()
            
            //移除动画图层
            productAnimlayer?.removeFromSuperlayer()
        }
    }
}

//MARK: - UITextFieldDelegate
extension SAMStockViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //结束编辑状态
        endProductNameTFEditing(false)
        
        //出发collectionView下拉
        collectionView.mj_header.beginRefreshing()
        return true
    }
}



