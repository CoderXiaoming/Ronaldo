//
//  SAMStockViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJRefresh
import Speech
import MBProgressHUD

///控制器类型
enum stockControllerType {
    case normal //常规
    case requestStock //查询库存
    case requestBuildOrder //创建订单
}

///刚是否成功上传成功图片
var SAMStockHasUnloadProductImage = false

///产品cell重用标识符
private let SAMStockProductCellReuseIdentifier = "SAMStockProductCellReuseIdentifier"
///产品cell正常状态size
private let SAMStockProductCellNormalSize = CGSize(width: ScreenW, height: SAMStockProductCellNormalHeight)

class SAMStockViewController: UIViewController {
    
    ///对外提供的类工厂方法
    class func instance(shoppingCarListModel: SAMShoppingCarListModel?, QRCodeScanStr: String?, type: stockControllerType) ->SAMStockViewController {
    
        let vc = SAMStockViewController()
        
        //判断控制器类型
        switch type {
            case .normal:
                //监听来自二维码扫描界面的通知
                NotificationCenter.default.addObserver(vc, selector: #selector(SAMStockViewController.receiveProductNameFromQRCodeView(notification:)), name: NSNotification.Name.init(SAMQRCodeViewGetProductNameNotification), object: nil)
                return vc
            
            case .requestStock:
                //购物车数据模型
                vc.shoppingCarListModel = shoppingCarListModel
                //当前有外部查询请求
                vc.hasOutRequest = true
                //当前不可以操作产品Cell
                vc.couldOperateCell = false
                return vc
            
            case .requestBuildOrder:
                //记录控制器状态
                vc.isFromBuildOrder = true
                if QRCodeScanStr != nil {
                    //当前有外部查询请求
                    vc.hasOutRequest = true
                    vc.productNameSearchStr = QRCodeScanStr!
                }
                return vc
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupBasicUI()
        
        //设置导航栏右边按钮
        setupRightNavBarItem()
        
        //设置展示库存的collectionView
        setupCollectionView()
        
        //设置一般监听
        setupNormalMonitorNotification()
        
        //设置长按手势
        setupSpeechRecognizer()
    }
    
    ///初始化UI
    fileprivate func setupBasicUI() {
        
        //设置标题
        navigationItem.title = "库存查询"
        
        //设置textField监听方法
        productNameTF.addTarget(self, action: #selector(SAMStockViewController.textFieldDidEditChange(_:)), for: .editingChanged)
    }
    
    ///设置导航栏右边按钮
    fileprivate func setupRightNavBarItem() {
        
        let conSearchBtn = UIButton()
        conSearchBtn.setImage(UIImage(named: "nameScan_nav"), for: UIControlState())
        conSearchBtn.sizeToFit()
        conSearchBtn.addTarget(self, action: #selector(SAMStockViewController.searchBtnClick), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: conSearchBtn)
    }
    
    ///初始化collectionView
    fileprivate func setupCollectionView() {
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMStockProductCell", bundle: nil), forCellWithReuseIdentifier: SAMStockProductCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchNewInfo))
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMStockViewController.loadConSearchMoreInfo))
        
        //没有数据自动隐藏footer
        collectionView.mj_footer.isAutomaticallyHidden = true
        //隐藏滑动条
        collectionView.showsVerticalScrollIndicator = false
    }
    
    ///设置一般通知监听
    fileprivate func setupNormalMonitorNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(SAMStockViewController.receiveStockDetailVCDismissNotification), name: NSNotification.Name.init(SAMStockDetailControllerDismissSuccessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SAMStockViewController.receiveStockConSearchVCDismissNotification), name: NSNotification.Name.init(SAMStockConSearchControllerDismissSuccessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SAMStockViewController.receiveSpeechSearch(notification:)), name: NSNotification.Name.init(SAMStockConSearchControllerSpeechSuccessNotification), object: nil)
    }
    
    //MARK: - 接收到通知调用的方法
    ///从产品详情控制器收到通知调用的方法
    func receiveStockDetailVCDismissNotification() {
        stockDetailVC = nil
    }
    ///从产品条件搜索控制器收到通知调用的方法
    func receiveStockConSearchVCDismissNotification() {
        conditionalSearchVC = nil
    }
    ///从二维码扫描界面收到通知调用的方法
    func receiveProductNameFromQRCodeView(notification: Notification) {
    
        //获取产品名
        let productIDName = notification.userInfo!["productIDName"] as! String
        
        //记录获取到的搜索字符串
        productNameSearchStr = productIDName
        
        //记录控制器状态
        hasOutRequest = true
    }
    ///从语音识别收到通知调用的方法
    func receiveSpeechSearch(notification: Notification) {
        productNameSearchStr = notification.userInfo!["searchString"] as! String
        productNameTF.text = productNameSearchStr
        collectionView.mj_header.beginRefreshing()
    }
    
    //MARK: - 设置语音识别
    fileprivate func setupSpeechRecognizer() {
        //设置语音识别按钮
        if #available(iOS 10.0, *) {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SAMStockViewController.longPressView(longPress:)))
            view.addGestureRecognizer(longPress)
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        noOrdercountPSearchAlertVCIsShowing = false
        
        //判断是否刚上传图片成功 或者是否有外界请求，如果有则触发下拉刷新。
        if SAMStockHasUnloadProductImage || hasOutRequest {
            
            collectionView.mj_header.beginRefreshing()
            
            if hasOutRequest { //如果有外界请求，赋值产品名搜索文本框
                
                //赋值文本框
                productNameTF.text = productNameSearchStr
            }
        }
    }
    
    //MARK: - 搜索按钮点击
    func searchBtnClick() {
        
        //判断当前是产品名搜索状态还是条件搜索状态
        if productNameTF.hasText {
            //退出编辑
            endProductNameTFEditing(false)
            
            //开始搜索
            collectionView.mj_header.beginRefreshing()
        }else { //条件搜索状态
            
            //清空产品名文本框，退出编辑
            endProductNameTFEditing(true)
            
            //创建条件搜索界面，并展示
            conditionalSearchVC = SAMStockConditionalSearchController.instance()
            conditionalSearchVC!.transitioningDelegate = self
            conditionalSearchVC!.modalPresentationStyle = UIModalPresentationStyle.custom
            conditionalSearchVC!.setCompletionCallback({[weak self] (parameters) in
                
                //赋值数据模型
                self!.conSearchParameters = parameters
                
                //计算动画所需数据
                let originalFrame = self!.view.convert(self!.conditionalSearchVC!.view.frame, from: self!.conditionalSearchVC!.view)
                let originalCenterY = (originalFrame.maxY - originalFrame.origin.y) * 0.5
                let transformY = self!.collectionView.frame.origin.y - originalCenterY - 15
                
                //动画隐藏界面
                UIView.animate(withDuration: 0.3, animations: {
                    
                    let transform = CGAffineTransform(translationX: 0, y: transformY)
                    self!.conditionalSearchVC!.view.transform = transform.scaledBy(x: 0.0001, y: 0.0001)
                }, completion: { (_) in
                    
                    //恢复界面形变，刷新数据
                    self!.conditionalSearchVC!.dismiss(animated: true, completion: {
                        
                        self!.collectionView.mj_header.beginRefreshing()
                    })
                })
            })
            
            //展示条件搜索控制器8
            present(conditionalSearchVC!, animated: true, completion: nil)
        }
    }
    
    //MARK: - 长按界面监听方法，调用语音识别
    func longPressView(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            //退出编辑状态
            view.endEditing(true)
            //添加麦克风图片
            microphoneImageView = UIImageView(image: UIImage(named: "microphone"))
            microphoneImageView?.frame = CGRect.zero
            microphoneImageView?.frame.size = CGSize(width: ScreenW, height: ScreenW)
            microphoneImageView!.center = KeyWindow!.center
            KeyWindow!.addSubview(microphoneImageView!)
            
            if #available(iOS 10.0, *) {
                LXMSpeechWorker.startRecording()
            } else {
                // Fallback on earlier versions
            }
        }
        if longPress.state == .ended  {
            //移除麦克风图片
            microphoneImageView?.removeFromSuperview()
            microphoneImageView = nil
            
            if #available(iOS 10.0, *) {
                LXMSpeechWorker.stopRecording()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    //MARK: - 加载数据
    func loadConSearchNewInfo() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //恢复记录状态
        SAMStockHasUnloadProductImage = false
        hasOutRequest = false
        
        //销毁条件搜索控制器
        conditionalSearchVC = nil
        //如果是产品名搜索，设置请求参数
        if productNameSearchStr != "" {
            conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject]
        }
        
        //如果此时conSearchParemeters为空，说明为空搜索名下拉，而且没有之前的搜索条件
        if conSearchParameters == nil {
            let _ = SAMHUD.showMessage("你想搜什么？", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //创建请求参数
        conSearchPageIndex = 1
        let index = String(format: "%d", conSearchPageIndex)
        let size = String(format: "%d", conSearchPageSize)
        conSearchParameters!["pageSize"] = size as AnyObject?
        conSearchParameters!["pageIndex"] = index as AnyObject?
        conSearchParameters!["showAlert"] = false as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters!, progress: nil, success: {[weak self] (Task, json) in
            //清空原先数据
            self!.stockProductModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //回主线程提示用户信息
                DispatchQueue.main.async(execute: { 
                    let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                })
            }else { //有数据模型
                
                let arr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.conSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    //回主线程处理下拉
                    DispatchQueue.main.async(execute: {
                        self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    })
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.conSearchPageIndex += 1
                }
                self!.stockProductModels.addObjects(from: arr as [AnyObject])
                
                //如果不能操作Cell,赋值状态BOOL变量
                if !self!.couldOperateCell {
                    for obj in self!.stockProductModels {
                        let model = obj as! SAMStockProductModel
                        model.couldOperateCell = self!.couldOperateCell
                    }
                }
                
                //当前为购物车传过来查询库存的数据
                if self!.shoppingCarListModel != nil {
                    let model = self!.stockProductModels[0] as! SAMStockProductModel
                    self!.shoppingCarListModel?.stockCountP = model.countP
                    self!.shoppingCarListModel?.stockCountM = model.countM
                    self!.shoppingCarListModel?.thumbUrl = model.thumbUrl1
                    self!.shoppingCarListModel = nil
                }
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.collectionView.mj_header.endRefreshing()
                
                //请求统计数据
                self!.calculateStockStatistic()
                
                //刷新数据
                self!.collectionView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            
            //清空条件搜索控制器
            self!.conditionalSearchVC = nil
            
            DispatchQueue.main.async(execute: { 
                //处理上拉
                self!.collectionView.mj_header.endRefreshing()
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }
    }
    
    //MARK: - 加载所有库存数据统计
    fileprivate func calculateStockStatistic() {
        
        let parameters = ["productIDName": conSearchParameters!["productIDName"], "minCountM": conSearchParameters!["minCountM"], "parentID": conSearchParameters!["parentID"], "storehouseID": conSearchParameters!["storehouseID"]]
        
        SAMNetWorker.sharedNetWorker().get("getStockStatic.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, Json) in
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            self!.totalCountPString = dictArr![0]["totalCountP"] as? String
            self!.totalCountMString = dictArr![0]["totalCountM"] as? String
        }) {[weak self] (Task, error) in
            self!.totalCountPString = "--"
            self!.totalCountMString = "---"
        }
        
        var staticCountP = 0
        var staticCountM = 0.0
        
        for obj in stockProductModels {
            let model = obj as! SAMStockProductModel
            staticCountP += model.countP
            staticCountM += model.countM
        }
        
        totalCountPString = String(format: "%d", staticCountP)
        totalCountMString = String(format: "%.1f", staticCountM)
    }
    
    //MARK: - 加载更多数据
    func loadConSearchMoreInfo() {
        
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", conSearchPageIndex)
        conSearchParameters!["pageIndex"] = index as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                DispatchQueue.main.async(execute: { 
                    //提示用户
                    let _ = SAMHUD.showMessage("没有更多数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                    
                    //设置footer
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                })
            }else {//有数据模型
                
                let arr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.conSearchPageSize { //没有更多数据
                    
                    DispatchQueue.main.async(execute: { 
                        //设置footer状态
                        self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    })
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.conSearchPageIndex += 1
                    
                    DispatchQueue.main.async(execute: {
                        //处理下拉
                        self!.collectionView.mj_footer.endRefreshing()
                    })
                }
                self!.stockProductModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.collectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            DispatchQueue.main.async(execute: { 
                //处理下拉
                self!.collectionView.mj_footer.endRefreshing()
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }
    }

    //MARK: - 懒加载属性
    ///条件搜索控制器
    fileprivate var conditionalSearchVC: SAMStockConditionalSearchController?
    
    ///库存详情控制器
    fileprivate var stockDetailVC: SAMStockDetailController?
    
    ///条件搜索参数字典
    var conSearchParameters: [String: AnyObject]?
    
    ///一次数据请求获取的数据最大条数
    fileprivate let conSearchPageSize = 15
    ///当前产品名搜索获取数据的页码
    fileprivate var conSearchPageIndex = 1
    
    ///当前是否有外界查询请求
    fileprivate var hasOutRequest: Bool = false
    ///当前是否可以操作产品Cell
    fileprivate var couldOperateCell: Bool = true
    
    ///当前是否为来自创建订单控制器
    fileprivate var isFromBuildOrder: Bool = false
    
    ///产品名搜索字符串
    fileprivate var productNameSearchStr = ""
    
    ///购物车穿过来的数据模型
    fileprivate var shoppingCarListModel: SAMShoppingCarListModel? {
        didSet{
            if shoppingCarListModel != nil {
                productNameSearchStr = shoppingCarListModel!.productIDName
            }
        }
    }
    
    ///库存数据模型数组
    fileprivate let stockProductModels = NSMutableArray()
    
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
    fileprivate var productOperationView: SAMProductOperationView?
    
    ///展示购物车时，主界面添加的蒙版
    fileprivate lazy var productOperationMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMStockViewController.hideProductOperationViewWhenMaskViewDidClick))
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
    
    ///话筒图片
    fileprivate var microphoneImageView: UIImageView?
    
    ///统计匹数订单管理数据模型数组
    fileprivate var stockSearchProductName = ""
    fileprivate var loadModelSuccess = true
    fileprivate let orderMarr1 = NSMutableArray()
    fileprivate var orderMarr1DidSet = false
    fileprivate let orderMarr2 = NSMutableArray()
    fileprivate var orderMarr2DidSet = false
    fileprivate let orderMarr3 = NSMutableArray()
    fileprivate var orderMarr3DidSet = false
    fileprivate let orderMarr4 = NSMutableArray()
    fileprivate var orderMarr4DidSet = false
    fileprivate let orderMarr5 = NSMutableArray()
    fileprivate var orderMarr5DidSet = false
    
    fileprivate let forSaleModels = NSMutableArray()
    fileprivate var forSaleModelsDidSet = false
    
    fileprivate let orderManageModels = NSMutableArray()
    fileprivate let searchShoppingCarListArr = NSMutableArray()
    fileprivate var noOrdercountP = 0
    fileprivate var noOrdercountM = 0.0
    fileprivate var noOrdercountPSearchIsSuccess = true {
    
        didSet{
            if noOrdercountPSearchIsSuccess == false {
                noOrderSearchProgressHud!.hide(true)
                noOrderSearchProgressHud = nil
            }
        }
    }
    
    fileprivate var noOrdercountPSearchHud: SAMHUD?
    fileprivate var noOrdercountPSearchAlertVC: UIAlertController?
    fileprivate var noOrdercountPSearchAlertVCIsShowing = false
    
    fileprivate var noOrderSearchProgressHud: SAMHUD?
    fileprivate var hudProgress: Float {
    
        get{
            return  Float(currentOrderSearchCount1 + currentOrderSearchCount2 + currentOrderSearchCount3 + currentOrderSearchCount4 + currentOrderSearchCount5) / Float(self.orderManageModels.count)
        }
    }
    
    fileprivate var orderArr1DidSet = true
    fileprivate let orderManageModels1 = NSMutableArray()
    fileprivate let searchShoppingCarListArr1 = NSMutableArray()
    fileprivate var currentOrderSearchCount1 = 0 {
        didSet{
            setHUDProgress()
        }
    }
    fileprivate var noOrdercountP1 = 0
    fileprivate var noOrdercountM1 = 0.0
    fileprivate var currentOrderCountM1 = 0.0 {
        
        didSet{
            noOrdercountM1 += currentOrderCountM1
        }
    }
    fileprivate var currentOrderCountP1 = 0 {
        didSet{
            
            if !noOrdercountPSearchIsSuccess {
                return
            }
            
            if currentOrderCountP1 == -1 {
                
                if noOrdercountPSearchHud != nil {
                    noOrdercountPSearchHud?.hide(true)
                }
                let _ = SAMHUD.showMessage("获取订单详情失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                noOrdercountPSearchIsSuccess = false
                
            }else {
                
                noOrdercountP1 += currentOrderCountP1
                
                if currentOrderSearchCount1 == orderManageModels1.count {
                    
                    orderArr1DidSet = true
                    getOrderDetail()
                    
                }else {
                
                    let model = orderManageModels1[currentOrderSearchCount1] as! SAMOrderModel
                    loadOrderDetailArr1(orderModel: model)
                }
            }
        }
    }
    
    fileprivate var orderArr2DidSet = true
    fileprivate let orderManageModels2 = NSMutableArray()
    fileprivate let searchShoppingCarListArr2 = NSMutableArray()
    fileprivate var currentOrderSearchCount2 = 0 {
        didSet{
            setHUDProgress()
        }
    }
    fileprivate var noOrdercountP2 = 0
    fileprivate var noOrdercountM2 = 0.0
    fileprivate var currentOrderCountM2 = 0.0 {
        
        didSet{
            noOrdercountM2 += currentOrderCountM2
        }
    }
    fileprivate var currentOrderCountP2 = 0 {
        didSet{
            
            if !noOrdercountPSearchIsSuccess {
                return
            }
            
            if currentOrderCountP2 == -1 {
                
                if noOrdercountPSearchHud != nil {
                    noOrdercountPSearchHud?.hide(true)
                }
                let _ = SAMHUD.showMessage("获取订单详情失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                noOrdercountPSearchIsSuccess = false
                
            }else {
                
                noOrdercountP2 += currentOrderCountP2
                
                if currentOrderSearchCount2 == orderManageModels2.count {
                    
                    orderArr2DidSet = true
                    getOrderDetail()
                    
                }else {
                    
                    let model = orderManageModels2[currentOrderSearchCount2] as! SAMOrderModel
                    loadOrderDetailArr2(orderModel: model)
                }
            }
        }
    }
    
    fileprivate var orderArr3DidSet = true
    fileprivate let orderManageModels3 = NSMutableArray()
    fileprivate let searchShoppingCarListArr3 = NSMutableArray()
    fileprivate var currentOrderSearchCount3 = 0 {
        didSet{
            setHUDProgress()
        }
    }
    fileprivate var noOrdercountP3 = 0
    fileprivate var noOrdercountM3 = 0.0
    fileprivate var currentOrderCountM3 = 0.0 {
        
        didSet{
            noOrdercountM3 += currentOrderCountM3
        }
    }
    fileprivate var currentOrderCountP3 = 0 {
        didSet{
            
            if !noOrdercountPSearchIsSuccess {
                return
            }
            
            if currentOrderCountP3 == -1 {
                
                if noOrdercountPSearchHud != nil {
                    noOrdercountPSearchHud?.hide(true)
                }
                let _ = SAMHUD.showMessage("获取订单详情失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                noOrdercountPSearchIsSuccess = false
                
            }else {
                
                noOrdercountP3 += currentOrderCountP3
                
                if currentOrderSearchCount3 == orderManageModels3.count {
                    
                    orderArr3DidSet = true
                    getOrderDetail()
                    
                }else {
                    
                    let model = orderManageModels3[currentOrderSearchCount3] as! SAMOrderModel
                    loadOrderDetailArr3(orderModel: model)
                }
            }
        }
    }
    
    fileprivate var orderArr4DidSet = true
    fileprivate let orderManageModels4 = NSMutableArray()
    fileprivate let searchShoppingCarListArr4 = NSMutableArray()
    fileprivate var currentOrderSearchCount4 = 0 {
        didSet{
            setHUDProgress()
        }
    }
    fileprivate var noOrdercountP4 = 0
    fileprivate var noOrdercountM4 = 0.0
    fileprivate var currentOrderCountM4 = 0.0 {
        
        didSet{
            noOrdercountM4 += currentOrderCountM4
        }
    }
    fileprivate var currentOrderCountP4 = 0 {
        didSet{
            
            if !noOrdercountPSearchIsSuccess {
                return
            }
            
            if currentOrderCountP4 == -1 {
                
                if noOrdercountPSearchHud != nil {
                    noOrdercountPSearchHud?.hide(true)
                }
                let _ = SAMHUD.showMessage("获取订单详情失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                noOrdercountPSearchIsSuccess = false
                
            }else {
                
                noOrdercountP4 += currentOrderCountP4
                
                if currentOrderSearchCount4 == orderManageModels4.count {
                    
                    orderArr4DidSet = true
                    getOrderDetail()
                    
                }else {
                    
                    let model = orderManageModels4[currentOrderSearchCount4] as! SAMOrderModel
                    loadOrderDetailArr4(orderModel: model)
                }
            }
        }
    }
    
    fileprivate var orderArr5DidSet = true
    fileprivate let orderManageModels5 = NSMutableArray()
    fileprivate let searchShoppingCarListArr5 = NSMutableArray()
    fileprivate var currentOrderSearchCount5 = 0 {
        didSet{
            setHUDProgress()
        }
    }
    fileprivate var noOrdercountP5 = 0
    fileprivate var noOrdercountM5 = 0.0
    fileprivate var currentOrderCountM5 = 0.0 {
        
        didSet{
            noOrdercountM5 += currentOrderCountM5
        }
    }
    fileprivate var currentOrderCountP5 = 0 {
        didSet{
            
            if !noOrdercountPSearchIsSuccess {
                return
            }
            
            if currentOrderCountP5 == -1 {
                
                if noOrdercountPSearchHud != nil {
                    noOrdercountPSearchHud?.hide(true)
                }
                let _ = SAMHUD.showMessage("获取订单详情失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                noOrdercountPSearchIsSuccess = false
                
            }else {
                
                noOrdercountP5 += currentOrderCountP5
                
                if currentOrderSearchCount5 == orderManageModels5.count {
                    
                    orderArr5DidSet = true
                    getOrderDetail()
                    
                }else {
                    
                    let model = orderManageModels5[currentOrderSearchCount5] as! SAMOrderModel
                    loadOrderDetailArr5(orderModel: model)
                }
            }
        }
    }

    
    
    //MARK: - xibffs束属性
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
        view = Bundle.main.loadNibNamed("SAMStockViewController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
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

//MARK: - CollectionView代理UICollectionViewDelegate
extension SAMStockViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        endProductNameTFEditing(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        endProductNameTFEditing(false)
        
        //获取数据模型
        let selectedModel = stockProductModels[indexPath.item] as! SAMStockProductModel
        
        //展示产品详情控制器
        let codeName = selectedModel.codeName
        let sameCodeNameModels = stockProductModels.compare(modelKeys: ["codeName"], searchItems: [codeName])
        let productInfoVC = SAMStockProductInfoController.instance(stockModel: selectedModel, sameCodeNameModels: NSMutableArray(array: sameCodeNameModels))
//        productInfoVC!.stockProductModel = selectedModel
        //TODO: - 暂时注释，看有没有影响
        navigationController!.pushViewController(productInfoVC!, animated: true)
    }
}

//MARK: - collectionView布局代理
extension SAMStockViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return SAMStockProductCellNormalSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    } 
}

//MARK: - 条件搜索控制器的转场动画代理
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
    //点击了产品图片
    func productCellDidClickProductImage(_ stockProductModel: SAMStockProductModel) {
        //展示产品图片控制器
        let codeName = stockProductModel.codeName
        let sameCodeNameModels = stockProductModels.compare(modelKeys: ["codeName"], searchItems: [codeName])
        let productImageVC = SAMProductImageController.instance(stockModel: stockProductModel, sameNameModels: NSMutableArray(array: sameCodeNameModels))
        navigationController!.pushViewController(productImageVC, animated: true)
    }
    
    //长按了产品图片
    func productCellDidLongPressProductImage(_ stockProductModel: SAMStockProductModel) {
        //创建条件搜索界面，并展示
        stockDetailVC = SAMStockDetailController.instance(stockModel: stockProductModel)
        stockDetailVC!.transitioningDelegate = self
        stockDetailVC!.modalPresentationStyle = UIModalPresentationStyle.custom
        
        present(stockDetailVC!, animated: true) {
        }
    }
    
    //点击了库存警报图片
    func productCellDidTapWarnningImage(_ stockProductModel: SAMStockProductModel) {
        let owedVC = SAMOrderOwedOperationController.buildOwe(productModel: stockProductModel, type: .buildOwe)
        navigationController!.pushViewController(owedVC, animated: true)
    }
    
    //长按了库存警报图片
    func productCellDidLongPressWarnningImage(_ stockProductModel: SAMStockProductModel) {
        
        let productName = stockProductModel.productIDName
        //发出通知
        NotificationCenter.default.post(name: NSNotification.Name.init(SAMStockProductCellLongPressWarnningImageNotification), object: nil, userInfo: ["productIDName": productName])
        
        //切换到库存查询界面
        tabBarController!.selectedIndex = 0
        let animation = CATransition()
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        animation.type = "kCATransitionFade"
        tabBarController?.view.layer.add(animation, forKey: nil)
    }
    
    func productCellDidTapShoppingCarImage(_ stockProductModel: SAMStockProductModel, stockProductImage: UIImage) {
        //展示购物车
        showShoppingCar(stockProductImage, productModel: stockProductModel)
    }
    func productCellDidLongPressShoppingCarImage(_ stockProductModel: SAMStockProductModel) {
        
        stockSearchProductName = stockProductModel.productIDName
        countCountPInNoOrder()
    }
}

//MARK: - 购物车控件代理
extension SAMStockViewController: SAMProductOperationViewDelegate {

    func operationViewDidClickDismissButton() {
        //隐藏购物车
        hideProductOperationView(false, produtImage: nil)
    }
    
    func operationViewAddOrEditProductSuccess(_ productImage: UIImage, postShoppingCarListModelSuccess: Bool) {
        
        if isFromBuildOrder && postShoppingCarListModelSuccess {
            
            //隐藏购物车, 提示用户
            hideProductOperationView(false, produtImage: productImage)
            let _ = SAMHUD.showMessage("添加成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }else if isFromBuildOrder && !postShoppingCarListModelSuccess {
            
            //隐藏购物车, 提示用户
            hideProductOperationView(false, produtImage: productImage)
            let _ = SAMHUD.showMessage("添加失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }else {
            //隐藏购物车
            hideProductOperationView(true, produtImage: productImage)
        }
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
        productOperationView = SAMProductOperationView.operationViewWillShow(productModel, editProductModel: nil, isFromeCheckOrder: false, postModelAfterOperationSuccess: isFromBuildOrder)
        
        productOperationView!.delegate = self
        productOperationView!.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: 350)
        
        var rect = productOperationView!.frame
        rect.origin.y = ScreenH - rect.size.height
        
        //添加背景View
        tabBarController!.view.addSubview(productOperationMaskView)
        KeyWindow?.addSubview(productOperationView!)
        
        //动画展示购物车控件
        UIView.animate(withDuration: 0.5, animations: {
            self.productOperationView!.frame = rect
        }) 
        
        //动画移动背景View
        UIView.animate(withDuration: 0.25, animations: {
            
            //执行第一步动画
            self.productOperationMaskView.alpha = 0.5
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
    func hideProductOperationViewWhenMaskViewDidClick() {
        
        hideProductOperationView(false, produtImage: nil)
    }
    
    //隐藏购物车控件
    fileprivate func hideProductOperationView(_ didAddProduct: Bool, produtImage: UIImage?) {
        
        //设置购物车目标frame
        var rect = self.productOperationView!.frame
        rect.origin.y = ScreenH
        
        //动画隐藏购物车控件
        UIView.animate(withDuration: 0.5, animations: {
            self.productOperationView!.frame = rect
        }) 
        
        //动画展示主View
        UIView.animate(withDuration: 0.25, animations: {
            
            self.tabBarController!.view.layer.transform = self.firstTran()
            self.productOperationMaskView.alpha = 0.0
        }, completion: { (_) in
            
            //移除蒙板
            self.productOperationMaskView.removeFromSuperview()
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.tabBarController!.view.layer.transform = CATransform3DIdentity
                }, completion: { (_) in
                    
                    //移除购物车
                    self.productOperationView!.removeFromSuperview()
                    
                    //调用成功添加购物车的动画
                    if didAddProduct {
                        
                        self.addToShoppingCarSuccess(produtImage!)
                    }
            })
        }) 
    }
    
    //添加到购物车之后的产品图片动画方法
    fileprivate func addToShoppingCarSuccess(_ productImage: UIImage) {
        
        //设置用户界面不可交互
        tabBarController?.view.isUserInteractionEnabled = false
        
        //设置动画layer
        productAnimlayer!.contents = productImage.cgImage
        KeyWindow?.layer.addSublayer(productAnimlayer!)
        productAnimlayer?.add(groupAnimation, forKey: "group")
    }
}

//MARK: - 添加产品至购物车成功后，产品图片动画的监听代理
extension SAMStockViewController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
        if anim == productAnimlayer?.animation(forKey: "group") {
            
            //改变shoppingCar控制器的badgeValue
            SAMShoppingCarController.sharedInstanceMain().addOrMinusProductCountOne(true)
            
            //恢复界面交互状态
            tabBarController?.view.isUserInteractionEnabled = true
            
            //移除动画
            productAnimlayer?.removeFromSuperlayer()
            
            //移除动画图层
            productAnimlayer?.removeFromSuperlayer()
        }
    }
}

//MARK: - 文本框相关方法
extension SAMStockViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //结束编辑状态
        endProductNameTFEditing(false)
        
        //触发collectionView下拉
        collectionView.mj_header.beginRefreshing()
        return true
    }
    
    ///文本框监听的方法
    func textFieldDidEditChange(_ textField: UITextField) {
        
        //获取搜索字符串
        productNameSearchStr = textField.text!.lxm_stringByTrimmingWhitespace()!
    }
    
    ///结束产品文本框编辑状态
    fileprivate func endProductNameTFEditing(_ clear: Bool) {
        if clear {
            productNameTF.text = ""
            productNameSearchStr = ""
        }
        let _ = productNameTF.resignFirstResponder()
    }
}

//MARK: - 新增扩展方法，计算未开单总匹数
extension SAMStockViewController {
    
    ///设置初始化数据，调用获取订单，待售布匹方法
    func countCountPInNoOrder() {
        
        //初始化数据
        orderManageModels.removeAllObjects()
        orderMarr1.removeAllObjects()
        orderMarr2.removeAllObjects()
        orderMarr3.removeAllObjects()
        orderMarr4.removeAllObjects()
        orderMarr5.removeAllObjects()
        forSaleModels.removeAllObjects()
        orderMarr1DidSet = false
        orderMarr2DidSet = false
        orderMarr3DidSet = false
        orderMarr4DidSet = false
        orderMarr5DidSet = false
        forSaleModelsDidSet = false;
        
        //设置加载hud
        noOrdercountPSearchHud = SAMHUD.showAdded(to: KeyWindow!, animated: true)
        noOrdercountPSearchHud!.labelText = NSLocalizedString("", comment: "HUD loading title")
        
        self.loadNewforSaleModels()
        self.loadModel(pageIndex: "1")
        self.loadModel(pageIndex: "2")
        self.loadModel(pageIndex: "3")
        self.loadModel(pageIndex: "4")
        self.loadModel(pageIndex: "5")
    }
    
    ///获取订单
    func loadModel(pageIndex: String) {
    
        //创建请求参数
        let employeeID = "-1"
        let CGUnitName = ""
        let pageSize = "100"
        let statusStr = "未开单"
        let yesterDayStr = Date.init(timeIntervalSinceNow: -60 * 60 * 24).yyyyMMddStr()
        let startDate = yesterDayStr
        let endDate = Date().yyyyMMddStr()
        
        let orderRequestParameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "status": statusStr]
        
        SAMNetWorker.sharedNetWorker().get("getOrderMainData.ashx", parameters: orderRequestParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            
            let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
            let pageIndexStr = orderRequestParameters["pageIndex"]!
            switch pageIndexStr {
                case "1":
                    self!.orderMarr1DidSet = true
                    self!.orderMarr1.addObjects(from: arr as! [Any])
                    self!.setModelArr()
                    break
                case "2":
                    self!.orderMarr2DidSet = true
                    self!.orderMarr2.addObjects(from: arr as! [Any])
                    self!.setModelArr()
                    break
                case "3":
                    self!.orderMarr3DidSet = true
                    self!.orderMarr3.addObjects(from: arr as! [Any])
                    self!.setModelArr()
                    break
                case "4":
                    self!.orderMarr4DidSet = true
                    self!.orderMarr4.addObjects(from: arr as! [Any])
                    self!.setModelArr()
                    break
                case "5":
                    self!.orderMarr5DidSet = true
                    self!.orderMarr5.addObjects(from: arr as! [Any])
                    self!.setModelArr()
                    break
                default:
                    break
            }
            
        }) {[weak self] (Task, Error) in
            
            if self!.noOrdercountPSearchHud != nil {
                self!.noOrdercountPSearchHud?.hide(true)
            }
            let _ = SAMHUD.showMessage("获取订单失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            
            self!.loadModelSuccess = false
        }
    }
    
    ///获取待售布匹
    func loadNewforSaleModels() {
        
        //创建请求参数
        let userID = "-1"
        let CGUnitName = ""
        let productIDName = stockSearchProductName
        let parameters = ["userID": userID, "CGUnitName": CGUnitName, "productIDName": productIDName]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getReadySellProductListNew.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            
            let arr = SAMForSaleModel.mj_objectArray(withKeyValuesArray: dictArr)!
            self!.forSaleModels.addObjects(from: arr as [AnyObject])
            self!.forSaleModelsDidSet = true;
            
        }) {[weak self] (Task, Error) in
            
            self!.loadModelSuccess = false
            self!.forSaleModelsDidSet = true;
            
            if self!.noOrdercountPSearchHud != nil {
                self!.noOrdercountPSearchHud?.hide(true)
            }
            let _ = SAMHUD.showMessage("获取待售布匹失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    ///订单获取后调用方法，对订单进行筛选
    func setModelArr() {
        
        if !loadModelSuccess {
            return
        }
        
        if orderMarr1DidSet && orderMarr2DidSet && orderMarr3DidSet && orderMarr4DidSet && orderMarr5DidSet && forSaleModelsDidSet {
            
            orderManageModels.addObjects(from: orderMarr1 as! [Any])
            orderManageModels.addObjects(from: orderMarr2 as! [Any])
            orderManageModels.addObjects(from: orderMarr3 as! [Any])
            orderManageModels.addObjects(from: orderMarr4 as! [Any])
            orderManageModels.addObjects(from: orderMarr5 as! [Any])
            
            if orderManageModels.count == 0  {
                
                _ = SAMHUD.showMessage("暂无未开单订单", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                return
            }
            
            //剔除已在待售布匹里的订单
            if forSaleModels.count > 0 {
                
                let forSaleOrderArr = NSMutableArray()
                for forSaleIndex in 0...(forSaleModels.count - 1) {
                    
                    let model = forSaleModels[forSaleIndex] as! SAMForSaleModel
                    let orderBillNum = model.orderBillNumber
                    
                    for orderIndex in 0...(orderManageModels.count - 1) {
                        
                        let orderModel = orderManageModels[orderIndex] as! SAMOrderModel
                        if orderModel.billNumber == orderBillNum {
                            
                            if !forSaleOrderArr.contains(orderModel) {
                                forSaleOrderArr.add(orderModel)
                                break
                            }
                        }
                    }
                }
                
                orderManageModels.removeObjects(in: forSaleOrderArr as! [Any])
            }
            
            if orderManageModels.count == 0  {
                return
            }
            
            searchShoppingCarListArr.removeAllObjects()
            noOrdercountPSearchIsSuccess = true
            noOrdercountP = 0
            noOrdercountM = 0.0
            
            orderArr1DidSet = false
            orderManageModels1.removeAllObjects()
            searchShoppingCarListArr1.removeAllObjects()
            currentOrderSearchCount1 = 0
            noOrdercountP1 = 0
            noOrdercountM1 = 0.0
            
            orderArr2DidSet = false
            orderManageModels2.removeAllObjects()
            searchShoppingCarListArr2.removeAllObjects()
            currentOrderSearchCount2 = 0
            noOrdercountP2 = 0
            noOrdercountM2 = 0.0
            
            orderArr3DidSet = false
            orderManageModels3.removeAllObjects()
            searchShoppingCarListArr3.removeAllObjects()
            currentOrderSearchCount3 = 0
            noOrdercountP3 = 0
            noOrdercountM3 = 0.0
            
            orderArr4DidSet = false
            orderManageModels4.removeAllObjects()
            searchShoppingCarListArr4.removeAllObjects()
            currentOrderSearchCount4 = 0
            noOrdercountP4 = 0
            noOrdercountM4 = 0.0
            
            orderArr5DidSet = false
            orderManageModels5.removeAllObjects()
            searchShoppingCarListArr5.removeAllObjects()
            currentOrderSearchCount5 = 0
            noOrdercountP5 = 0
            noOrdercountM5 = 0.0
            
            let perCount = orderManageModels.count / 5
            
            for index in 0...(orderManageModels.count - 1) {
                
                if index < perCount {
                    
                    orderManageModels1.add(orderManageModels[index])
                    
                }else if (index >= perCount) && (index < perCount * 2) {
                    
                    orderManageModels2.add(orderManageModels[index])
                    
                }else if (index >= perCount * 2) && (index < perCount * 3) {
                    
                    orderManageModels3.add(orderManageModels[index])
                    
                }else if (index >= perCount * 3) && (index < perCount * 4) {
                    
                    orderManageModels4.add(orderManageModels[index])
                    
                }else {
                    
                    orderManageModels5.add(orderManageModels[index])
                }
            }
            
            setupProgressHUD()
            
            let model1 = orderManageModels1[0] as! SAMOrderModel
            loadOrderDetailArr1(orderModel: model1)
            
            let model2 = orderManageModels2[0] as! SAMOrderModel
            loadOrderDetailArr2(orderModel: model2)
            
            let model3 = orderManageModels3[0] as! SAMOrderModel
            loadOrderDetailArr3(orderModel: model3)
            
            let model4 = orderManageModels4[0] as! SAMOrderModel
            loadOrderDetailArr4(orderModel: model4)
            
            let model5 = orderManageModels5[0] as! SAMOrderModel
            loadOrderDetailArr5(orderModel: model5)
        }
    }
    
    fileprivate func setupProgressHUD() {
        
        if noOrdercountPSearchHud != nil {
            noOrdercountPSearchHud?.hide(true)
        }
        noOrderSearchProgressHud = SAMHUD.showAdded(to: KeyWindow!, animated: true)
        noOrderSearchProgressHud!.mode = MBProgressHUDMode.annularDeterminate
        let userName = UserDefaults.standard.object(forKey: "userNameStrKey") as? String
        var remarkText: String?
        if userName == "任玉" {
            
            remarkText = String.init(format: "别急嘛~ 小玉😳", userName!)
        }else if userName == "王超超" {
            
            remarkText = String.init(format: "别急嘛~ 超超😉", userName!)
        }else {
            
            remarkText = "正在解析..."
        }
        noOrderSearchProgressHud!.labelText = NSLocalizedString(remarkText!, comment: "HUD loading title")
        setHUDProgress()
    }
    
    fileprivate func setHUDProgress() {
        
        if noOrderSearchProgressHud == nil {
            return
        }
        
        if hudProgress < 1.0 {
            noOrderSearchProgressHud!.progress = hudProgress
            
        }else {
        
            noOrderSearchProgressHud!.hide(true)
            noOrderSearchProgressHud = nil
        }
    }
    
    
    fileprivate func getOrderDetail() {
    
        if orderArr1DidSet && orderArr2DidSet && orderArr3DidSet && orderArr4DidSet && orderArr5DidSet{
            
            searchShoppingCarListArr.addObjects(from: searchShoppingCarListArr1 as! [Any])
            noOrdercountP += noOrdercountP1
            noOrdercountM += noOrdercountM1
            
            searchShoppingCarListArr.addObjects(from: searchShoppingCarListArr2 as! [Any])
            noOrdercountP += noOrdercountP2
            noOrdercountM += noOrdercountM2
            
            searchShoppingCarListArr.addObjects(from: searchShoppingCarListArr3 as! [Any])
            noOrdercountP += noOrdercountP3
            noOrdercountM += noOrdercountM3
            
            searchShoppingCarListArr.addObjects(from: searchShoppingCarListArr4 as! [Any])
            noOrdercountP += noOrdercountP4
            noOrdercountM += noOrdercountM4
            
            searchShoppingCarListArr.addObjects(from: searchShoppingCarListArr5 as! [Any])
            noOrdercountP += noOrdercountP5
            noOrdercountM += noOrdercountM5
            
            if noOrdercountPSearchHud != nil {
                noOrdercountPSearchHud?.hide(true)
            }
            
            if !noOrdercountPSearchAlertVCIsShowing {
                
                if noOrdercountP == 0 {
                    
                    let message = String(format: "未开单中共有%d匹", noOrdercountP)
                    noOrdercountPSearchAlertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    noOrdercountPSearchAlertVC!.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
                        self.noOrdercountPSearchAlertVCIsShowing = false
                    }))
                    
                    present(noOrdercountPSearchAlertVC!, animated: true, completion: nil)
                }else {
                    
                    let vc = SAMNoOrderSearchDetailController.instance(orderArr: orderManageModels, shoppingCarListArr: searchShoppingCarListArr, productIDName: stockSearchProductName, countP: noOrdercountP, countM: noOrdercountM)
                    present(vc, animated: true, completion: nil)
                }
                
                noOrdercountPSearchAlertVCIsShowing = true
            }
        }
    }
    
    func loadOrderDetailArr1(orderModel: SAMOrderModel){
        
        if !noOrdercountPSearchIsSuccess {
            return
        }
        
        //发送请求，获取订单产品数据模型数组
        SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": orderModel.billNumber], progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有数据
                
                self!.currentOrderSearchCount1 += 1
                self!.currentOrderCountP1 = 0
                self!.currentOrderCountM1 = 0.0
                
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                var countP = 0
                var countM = 0.0
                for model in arr {
                    let shoppingCarListModel = model as! SAMShoppingCarListModel
                    if shoppingCarListModel.productIDName == self!.stockSearchProductName {
                        countP += shoppingCarListModel.countP
                        countM += shoppingCarListModel.countM
                        self!.searchShoppingCarListArr1.add(shoppingCarListModel)
                    }
                }
                self!.currentOrderSearchCount1 += 1
                self!.currentOrderCountP1 = countP
                self!.currentOrderCountM1 = countM
            }
        }) {[weak self] (Task, Error) in
            
            self!.currentOrderSearchCount1 += 1
            self!.currentOrderCountP1 = -1
        }
    }
    
    func loadOrderDetailArr2(orderModel: SAMOrderModel){
        
        if !noOrdercountPSearchIsSuccess {
            return
        }
        
        //发送请求，获取订单产品数据模型数组
        SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": orderModel.billNumber], progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有数据
                
                self!.currentOrderSearchCount2 += 1
                self!.currentOrderCountP2 = 0
                self!.currentOrderCountM2 = 0.0
                
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                var countP = 0
                var countM = 0.0
                for model in arr {
                    let shoppingCarListModel = model as! SAMShoppingCarListModel
                    if shoppingCarListModel.productIDName == self!.stockSearchProductName {
                        countP += shoppingCarListModel.countP
                        countM += shoppingCarListModel.countM
                        self!.searchShoppingCarListArr2.add(shoppingCarListModel)
                    }
                }
                self!.currentOrderSearchCount2 += 1
                self!.currentOrderCountP2 = countP
                self!.currentOrderCountM2 = countM
            }
        }) {[weak self] (Task, Error) in
            
            self!.currentOrderSearchCount2 += 1
            self!.currentOrderCountP2 = -1
        }
    }
    
    func loadOrderDetailArr3(orderModel: SAMOrderModel){
        
        if !noOrdercountPSearchIsSuccess {
            return
        }
        
        //发送请求，获取订单产品数据模型数组
        SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": orderModel.billNumber], progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有数据
                
                self!.currentOrderSearchCount3 += 1
                self!.currentOrderCountP3 = 0
                self!.currentOrderCountM3 = 0.0
                
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                var countP = 0
                var countM = 0.0
                for model in arr {
                    let shoppingCarListModel = model as! SAMShoppingCarListModel
                    if shoppingCarListModel.productIDName == self!.stockSearchProductName {
                        countP += shoppingCarListModel.countP
                        countM += shoppingCarListModel.countM
                        self!.searchShoppingCarListArr3.add(shoppingCarListModel)
                    }
                }
                self!.currentOrderSearchCount3 += 1
                self!.currentOrderCountP3 = countP
                self!.currentOrderCountM3 = countM
            }
        }) {[weak self] (Task, Error) in
            
            self!.currentOrderSearchCount3 += 1
            self!.currentOrderCountP3 = -1
        }
    }
    
    func loadOrderDetailArr4(orderModel: SAMOrderModel){
        
        if !noOrdercountPSearchIsSuccess {
            return
        }
        
        //发送请求，获取订单产品数据模型数组
        SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": orderModel.billNumber], progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有数据
                
                self!.currentOrderSearchCount4 += 1
                self!.currentOrderCountP4 = 0
                self!.currentOrderCountM4 = 0.0
                
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                var countP = 0
                var countM = 0.0
                for model in arr {
                    let shoppingCarListModel = model as! SAMShoppingCarListModel
                    if shoppingCarListModel.productIDName == self!.stockSearchProductName {
                        countP += shoppingCarListModel.countP
                        countM += shoppingCarListModel.countM
                        self!.searchShoppingCarListArr4.add(shoppingCarListModel)
                    }
                }
                self!.currentOrderSearchCount4 += 1
                self!.currentOrderCountP4 = countP
                self!.currentOrderCountM4 = countM
            }
        }) {[weak self] (Task, Error) in
            
            self!.currentOrderSearchCount4 += 1
            self!.currentOrderCountP4 = -1
        }
    }
    
    func loadOrderDetailArr5(orderModel: SAMOrderModel){
        
        if !noOrdercountPSearchIsSuccess {
            return
        }
        
        //发送请求，获取订单产品数据模型数组
        SAMNetWorker.sharedNetWorker().get("getOrderDetailData.ashx", parameters: ["billNumber": orderModel.billNumber], progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有数据
                
                self!.currentOrderSearchCount5 += 1
                self!.currentOrderCountP5 = 0
                self!.currentOrderCountM5 = 0.0
                
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                var countP = 0
                var countM = 0.0
                for model in arr {
                    let shoppingCarListModel = model as! SAMShoppingCarListModel
                    if shoppingCarListModel.productIDName == self!.stockSearchProductName {
                        countP += shoppingCarListModel.countP
                        countM += shoppingCarListModel.countM
                        self!.searchShoppingCarListArr5.add(shoppingCarListModel)
                    }
                }
                self!.currentOrderSearchCount5 += 1
                self!.currentOrderCountP5 = countP
                self!.currentOrderCountM5 = countM
            }
        }) {[weak self] (Task, Error) in
            
            self!.currentOrderSearchCount5 += 1
            self!.currentOrderCountP5 = -1
        }
    }
    
}

