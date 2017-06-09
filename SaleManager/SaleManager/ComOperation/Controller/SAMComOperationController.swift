//
//  SAMComOperationController.swift
//  SaleManager
//
//  Created by apple on 16/12/22.
//  Copyright © 2016年 YZH. All rights reserved.
//
import UIKit
import MJRefresh
import AFNetworking
import MBProgressHUD

///SAMOrderManagerCell重用标识符
private let SAMOrderManagerCellReuseIdentifier = "SAMOrderManagerCellReuseIdentifier"
///SAMOrderManagerCell尺寸
private let SAMComOperationCellSize = CGSize(width: ScreenW, height: 95)

class SAMComOperationController: UIViewController {
    
    ///对外提供的类工厂方法
    class func instance() -> SAMComOperationController {
        let vc = SAMComOperationController()
        return vc
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置导航栏指示控制器
        setupNavIndicaterView()
        
        //设置时间按钮控件
        setupDateButtonView()
        
        ///设置文本
        setupTextField()
        
        //设置ScrollView
        setupScrollCollectionView()
        
        //设置其他
        setupOtherUI()
        
        //设置待售布匹搜索控件UI
        setupForSaleSearchViewUI()
        
        //设置通知
        setupNotification()
    }
    
    ///设置导航栏指示器
    fileprivate func setupNavIndicaterView() {
        
        //设置代理
        navIndicaterView!.delegate = self
        //添加到父控件
        view.addSubview(navIndicaterView!)
        
        //布局navIndicaterView
        navIndicaterView!.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dict = ["navIndicaterView" : navIndicaterView!] as [String : UIView]
        cons += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[navIndicaterView]-0-|", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[navIndicaterView(55)]", options: NSLayoutFormatOptions.init(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    ///设置时间按钮控件
    fileprivate func setupDateButtonView() {
        //设置时间选择器最大时间
        datePicker!.maximumDate = Date()
        
        //设置dateBtnView的锚点, 初始化transform
        dateBtnView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        dateBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        dateBtnView.alpha = 0.00001
        
        //设置时间按钮控件边框
        dateBtnContentView.layer.cornerRadius = 5
    }
    
    ///设置文本框
    fileprivate func setupTextField() {
        let arr = NSArray(array: [beginDateTF, endDateTF, customerSearchTF, stateSearchTF, forSaleDrawerTF, forSaleProductTF, forSaleCustomerTF, owedSearchCustomerTF, owedSearchProductTF, owedSearchStateTF])
        arr.enumerateObjects({ (obj, _, _) in
            let textField = obj as! UITextField
            
            //设置代理
            textField.delegate = self
            
            //设置订单分类的inputView
            if (textField == stateSearchTF) || (textField == owedSearchStateTF) {
                textField.text = "所有"
                textField.inputView = stateSearchPickerView
            }
            
            //设置 beginDateTF, endDateTF 的 inputView
            if (textField == self.beginDateTF) || (textField == self.endDateTF) {
                
                //设置inputView
                textField.inputView = datePicker
            }
        })
    }
    
    ///设置ScrollCollectionView
    fileprivate func setupScrollCollectionView() {
        
        let colectionViewArr = [orderManageColView, forSaleColView, owedColView, saleHistoryColView, customerRankColView, productRankColView]
        
        comScrollView.contentSize = CGSize(width: ScreenW * (CGFloat(colectionViewArr.count)), height: 0)
        comScrollView.isPagingEnabled = true
        comScrollView.showsHorizontalScrollIndicator = false
        comScrollView.delegate = self
        
        for index in 0...(colectionViewArr.count - 1) {
            
            let collectionView = colectionViewArr[index]
            //设置代理数据源
            collectionView.delegate = self
            collectionView.dataSource = self
            
            //注册cell
            collectionView.register(UINib(nibName: rigisterReuseNames[index], bundle: nil), forCellWithReuseIdentifier: rigisterReuseNames[index])
            
            //设置上拉下拉
            collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: collectionViewsMjheaderSelectors[index])
            if collectionView != forSaleColView {
                collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: collectionViewsMjfooterSelectors[index])
                //没有数据自动隐藏footer
                collectionView.mj_footer.isAutomaticallyHidden = true
            }
            
            //添加collectionView
            comScrollView.addSubview(collectionView)
            
            collectionView.backgroundColor = customBGWhiteColor
        }
        
        //赋值第一个collectionView
        currentCollectionView = orderManageColView
        
        //设置orderManageColView长安手势
        setupOrderBuildRecognizer()
    }
    
    ///设置其他UI
    fileprivate func setupOtherUI() {
        
        //设置hudView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMComOperationController.hudViewDidClick))
        hudView.addGestureRecognizer(tapGesture)
        
        //设置返回按钮
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        //设置起止日期为今天
        let todayDate = Date()
        endDateTF.text = todayDate.yyyyMMddStr()
        let disDate = todayDate.beforeOrAfter(1, before: true)
        beginDateTF.text = disDate.yyyyMMddStr()
    }
    
    ///设置待售布匹搜索控件UI
    fileprivate func setupForSaleSearchViewUI() {
        
        //加载待售布匹开单人模型数组
        loadForSaleDrawerModels()
        
        //设置开单人选择文本框输入控件
        forSaleDrawerTF.inputView = stateSearchPickerView
        
        //隐藏待售布匹搜索控件
        forSaleSearchView.isHidden = true
    }
    
    ///设置通知监听
    fileprivate func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(SAMComOperationController.receiveStockSearchOwedNotification(_:)), name: NSNotification.Name.init(SAMStockProductCellLongPressWarnningImageNotification), object: nil)
    }
    
    ///接收到查询库存警报通知调用的方法
    func receiveStockSearchOwedNotification(_ notification: NSNotification) {
        let productName = notification.userInfo!["productIDName"] as! String
        comOperationIndicaterViewDidSelected(index: 2)
        owedSearchProductTF.text = productName
        owedColView.mj_header.beginRefreshing()
    }
    
    //MARK: - 设置orderManageColView长按手势
    fileprivate func setupOrderBuildRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SAMComOperationController.longPressOrderColView(longPress:)))
        orderManageColView.addGestureRecognizer(longPress)
    }
    
    //MARK: - viewWillAppear , Disappear 设置导航栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //设置所有collectionView的frame
        if orderManageColView.bounds.width != ScreenW {
            let colectionViewArr = [orderManageColView, forSaleColView, owedColView, saleHistoryColView, customerRankColView, productRankColView]
            for index in 0...(colectionViewArr.count - 1) {
                
                let collectionView = colectionViewArr[index]
                collectionView.frame = comScrollView.bounds
                collectionView.frame.origin.x = ScreenW * CGFloat(index)
            }
        }
    }
    
    //MARK: - 获取 客户 或者 状态 搜索字符串
    fileprivate func searchConIn(textField: UITextField) -> String {
        let searchStr = textField.text?.lxm_stringByTrimmingWhitespace()
        if searchStr == "" { //没有内容
            return ""
        }
        return (searchStr?.components(separatedBy: " ")[0])!
    }
    
    //MARK: - 用户点击事件
    ///时间控件按钮展示
    @IBAction func dropDownBtnClick(_ sender: UIButton) {
        
        //退出第一相应textField
        endFirstTextFieldEditing()
        
        if !dropDownBtn.isSelected {
            
            //显示hudView
            hudView.isHidden = false
            
            //动画展示dateBtnView
            UIView.animate(withDuration: 0.3, animations: {
                self.dateBtnView.transform = CGAffineTransform.identity
                self.dateBtnView.alpha = 1
            }, completion: { (_) in
                self.dropDownBtn.isSelected = !self.dropDownBtn.isSelected
            })
        }else {
            //动画隐藏dateBtnView
            UIView.animate(withDuration: 0.3, animations: {
                self.dateBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                self.dateBtnView.alpha = 0.00001
            }, completion: { (_) in
                self.dropDownBtn.isSelected = !self.dropDownBtn.isSelected
                
                //隐藏HUDView
                self.hideHUDView()
            })
        }
    }
    
    ///搜索按钮点击
    @IBAction func searchBtnClick(_ sender: AnyObject) {
        
        //结束当前第一响应者编辑状态
        endFirstTextFieldEditing()
        
        //开始刷新
        switch currentColIndex {
        case 0:
            orderManageColView.mj_header.beginRefreshing()
        case 1:
            forSaleColView.mj_header.beginRefreshing()
        case 2:
            
            owedSearchBtnClick()
        case 3:
            saleHistoryColView.mj_header.beginRefreshing()
        case 4:
            customerRankColView.mj_header.beginRefreshing()
        case 5:
            productRankColView.mj_header.beginRefreshing()
        default :
            return
        }
    }
    
    fileprivate func owedSearchBtnClick() {
        
        SAMOwedStockNode = 0.0
        didSetStockNode = true
        let alertVC = UIAlertController(title: "低于多少米，显示灰色😄", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertVC.addTextField { (textField) in
            
            textField.placeholder = "请输入米数"
            textField.addTarget(self, action: #selector(SAMComOperationController.owedSotckNodeDidChangeValue(textField:)), for: UIControlEvents.editingChanged)
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        alertVC.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
            self.didSetStockNode = false
        }))
        alertVC.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: { (action) in
            
            self.owedColView.mj_header.beginRefreshing()
        }))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func owedSotckNodeDidChangeValue(textField: UITextField) {
        
        let countStr = textField.text?.lxm_stringByTrimmingWhitespace()
        let coutnNStr = NSString.init(string: countStr!)
        SAMOwedStockNode = coutnNStr.doubleValue
    }
    
    ///4个时间按钮的点击
    @IBAction func todayBtnClick(_ sender: AnyObject) {
        
        dateBtnViewdidClick(0.0)
    }
    @IBAction func yesterdayBtnClick(_ sender: AnyObject) {
        
        dateBtnViewdidClick(1.0)
    }
    @IBAction func last7daysBtnClick(_ sender: AnyObject) {
        
        dateBtnViewdidClick(7.0)
    }
    @IBAction func last30daysBtnClick(_ sender: AnyObject) {
        
        dateBtnViewdidClick(30.0)
    }
    
    //MARK: - 4个时间按钮点击时调用
    fileprivate func dateBtnViewdidClick(_ days: Double) {
        
        //隐藏时间按钮控件
        dropDownBtnClick(dropDownBtn)
        
        //获取今天日期字符串
        let todayDate = Date()
        let todayStr = todayDate.yyyyMMddStr()
        
        //获取目标日期字符串
        let disDate = todayDate.beforeOrAfter(days, before: true)
        let disStr = disDate.yyyyMMddStr()
        
        //设置字符串
        endDateTF.text = todayStr
        beginDateTF.text = disStr
    }
    
    //时间选择器 选择时间
    func dateChanged(_ datePicker: UIDatePicker) {
        
        //设置文本框时间
        firstTF?.text = datePicker.date.yyyyMMddStr()
    }
    
    //MARK: - 结束textField编辑状态
    fileprivate func endFirstTextFieldEditing() {
        if firstTF != nil {
            firstTF?.resignFirstResponder()
        }
    }
    
    //MARK: - 点击了hudView
    func hudViewDidClick() {
        
        //结束textfield编辑状态
        endFirstTextFieldEditing()
        
        //关闭dateButtonView
        if dropDownBtn.isSelected {
            dropDownBtnClick(dropDownBtn)
        }
    }
    
    //MARK: - 隐藏HUDView
    fileprivate func hideHUDView() {
        if firstTF == nil && dropDownBtn.isSelected == false {
            hudView.isHidden = true
        }
    }
    
    //MARK: - 长按订单collectionView监听方法，创建订单
    func longPressOrderColView(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            //退出编辑状态
            endFirstTextFieldEditing()
            let buildOrderVC = SAMOrderOwedOperationController.buildOrder(productModels: nil, type: .buildOrder)
            navigationController!.pushViewController(buildOrderVC, animated: true)
        }
    }
    
    //MARK: - 属性懒加载
    ///当前collectionView的序号
    fileprivate var currentColIndex = 0
    ///当前collectionView
    fileprivate var currentCollectionView: UICollectionView?
    
    ///订单管理collectionView
    fileprivate let orderManageColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///待售布匹collectionView
    fileprivate let forSaleColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///缺货登记collectionView
    fileprivate let owedColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///销售历史collectionView
    fileprivate let saleHistoryColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///客户排行collectionView
    fileprivate let customerRankColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationRankColletionViewFlowlayout())
    ///产品排行collectionView
    fileprivate let productRankColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationRankColletionViewFlowlayout())
    
    ///各collectionView下拉刷新触动的方法
    fileprivate let collectionViewsMjheaderSelectors = [#selector(SAMComOperationController.loadNewOrderModels), #selector(SAMComOperationController.loadNewforSaleModels), #selector(SAMComOperationController.loadNewOwedModels), #selector(SAMComOperationController.loadNewSaleHistoryModels), #selector(SAMComOperationController.loadNewCustomerRankModels), #selector(SAMComOperationController.loadNewProductRankModels)]
    
    ///各collectionView上拉刷新触动的方法
    fileprivate let collectionViewsMjfooterSelectors = [#selector(SAMComOperationController.loadMoreOrderModels), #selector(SAMComOperationController.loadMoreforSaleModels), #selector(SAMComOperationController.loadMoreOwedModels), #selector(SAMComOperationController.loadMoreSaleHistoryModels), #selector(SAMComOperationController.loadMoreCustomerRankModels), #selector(SAMComOperationController.loadMoreProductRankModels)]
    
    ///所有collectionView注册的nibName
    fileprivate let rigisterReuseNames = ["SAMComOperationCell", "SAMComOperationCell", "SAMComOperationCell", "SAMComOperationCell", "SAMComOperationViewRankCell", "SAMComOperationViewRankCell"]
    
    ///所有接口字符串
    fileprivate let requestURLStrs = ["getOrderMainData.ashx", "getReadySellProductListNew.ashx", "getOOSRecordList.ashx", "getSellMainData.ashx", "getSellStaticCGUnit.ashx", "getSellStaticProduct.ashx"]
    
    ///订单请求参数
    fileprivate var orderRequestParameters: [String: String]?
    ///待售布匹请求参数
    fileprivate var forSaleRequestParameters: [String: String]?
    ///缺货登记请求参数
    fileprivate var oweRequestParameters: [String: String]?
    ///销售历史请求参数
    fileprivate var saleHistoryRequestParameters: [String: String]?
    ///客户排行请求参数
    fileprivate var customerRankRequestParameters: [String: String]?
    ///产品排行请求参数
    fileprivate var productRankRequestParameters: [String: String]?
    
    ///当前数据的页码数组
    fileprivate var requestSearchPageIndexs = [0, 0, 0, 0, 0, 0]
    ///一次数据请求获取的数据最大条数
    fileprivate let requestSearchPageSize = 15
    ///当前数据的页码
    fileprivate var requestSearchPageIndex = 1
    
    ///订单管理collectionView数据模型数组
    fileprivate let orderManageModels = NSMutableArray()
    ///待售布匹collectionView数据模型数组
    fileprivate let forSaleModels = NSMutableArray()
    ///缺货登记collectionView数据模型数组
    fileprivate let owedModels = NSMutableArray()
    ///销售历史collectionView数据模型数组
    fileprivate let saleHistoryModels = NSMutableArray()
    ///客户排行collectionView数据模型数组
    fileprivate let customerRankModels = NSMutableArray()
    ///产品排行collectionView数据模型数组
    fileprivate let productRankModels = NSMutableArray()
    
    ///缺货登记搜索ID分类
    fileprivate let owedProductIDSearchArr = NSMutableArray()
    ///缺货登记数据模型分类数组
    fileprivate let owedClassifyArr = NSMutableArray()
    fileprivate var owedStockSearchProgressHud: SAMHUD?
    ///是否主动设置的缺货登记库存节点
    fileprivate var didSetStockNode = false
    
    fileprivate let owedProductIDSearchArr1 = NSMutableArray()
    fileprivate let owedClassifyArr1 = NSMutableArray()
    ///缺货登记已经查询了数据数组的数量
    fileprivate var owedArrSearchCount1 = 0 {
        
        didSet{
            
            if owedArrSearchCount1 == 0{
                return
            }
            
            setHUDProgress()
            
            if owedArrSearchCount1 == owedClassifyArr1.count { //搜索完毕
                
                getOwedStockComplete()
                
            }else {
                
                self.loadStock1()
            }
            
        }
    }
    fileprivate let owedProductIDSearchArr2 = NSMutableArray()
    fileprivate let owedClassifyArr2 = NSMutableArray()
    ///缺货登记已经查询了数据数组的数量
    fileprivate var owedArrSearchCount2 = 0 {
        
        didSet{
            
            if owedArrSearchCount2 == 0{
                return
            }
            
            setHUDProgress()
            
            if owedArrSearchCount2 == owedClassifyArr2.count { //搜索完毕
                
                getOwedStockComplete()
                
            }else {
                
                self.loadStock2()
            }
            
        }
    }
    
    fileprivate let owedProductIDSearchArr3 = NSMutableArray()
    fileprivate let owedClassifyArr3 = NSMutableArray()
    ///缺货登记已经查询了数据数组的数量
    fileprivate var owedArrSearchCount3 = 0 {
        
        didSet{
            
            if owedArrSearchCount3 == 0{
                return
            }
            
            setHUDProgress()
            
            if owedArrSearchCount3 == owedClassifyArr3.count { //搜索完毕
                
                getOwedStockComplete()
                
            }else {
                
                self.loadStock3()
            }
            
        }
    }
    
    fileprivate let owedProductIDSearchArr4 = NSMutableArray()
    fileprivate let owedClassifyArr4 = NSMutableArray()
    ///缺货登记已经查询了数据数组的数量
    fileprivate var owedArrSearchCount4 = 0 {
        
        didSet{
            
            if owedArrSearchCount4 == 0{
                return
            }
            
            setHUDProgress()
            
            if owedArrSearchCount4 == owedClassifyArr4.count { //搜索完毕
                
                getOwedStockComplete()
                
            }else {
                
                self.loadStock4()
            }
            
        }
    }
    
    fileprivate let owedProductIDSearchArr5 = NSMutableArray()
    fileprivate let owedClassifyArr5 = NSMutableArray()
    ///缺货登记已经查询了数据数组的数量
    fileprivate var owedArrSearchCount5 = 0 {
        
        didSet{
            
            if owedArrSearchCount5 == 0{
                return
            }
            
            setHUDProgress()
            
            if owedArrSearchCount5 == owedClassifyArr5.count { //搜索完毕
                
                getOwedStockComplete()
                
            }else {
                
                self.loadStock5()
            }
            
        }
    }
    
    
    ///导航栏指示器
    fileprivate lazy var navIndicaterView: SAMComOperationIndicaterView? = {
        let indicaterView = SAMComOperationIndicaterView.instance()
        return indicaterView
    }()
    
    ///时间选择器
    fileprivate lazy var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(SAMComOperationController.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    ///订单状态选择pickerView
    fileprivate lazy var stateSearchPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    ///搜索状态数组
    fileprivate var searchStates = [["所有", "未开单", "已开单"], [], ["所有", "欠货中", "已完成", "已删除"], [], [], []]
    
    ///待售布匹开单人模型数组
    fileprivate var forSaleDrawerModels = NSMutableArray()
    fileprivate var forSaleDrawerSelectedModel: SAMForSaleDrawerModel?
    
    ///第一响应者
    fileprivate var firstTF: UITextField?
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchConView: UIView!
    @IBOutlet weak var beginDateTF: SAMLoginTextField!
    @IBOutlet weak var endDateTF: SAMLoginTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var customerSearchTF: SAMLoginTextField!
    @IBOutlet weak var stateSearchTF: SAMLoginTextField!
    
    //待售布匹的搜索控件，覆盖在主文本框控件上
    @IBOutlet weak var forSaleSearchView: UIView!
    @IBOutlet weak var forSaleStaticTF: SAMLoginTextField!
    @IBOutlet weak var forSaleDrawerTF: SAMLoginTextField!
    @IBOutlet weak var forSaleCustomerTF: SAMLoginTextField!
    @IBOutlet weak var forSaleProductTF: SAMLoginTextField!
    
    //缺货登记控件，包含在主文本框控件内
    @IBOutlet weak var owedSearchView: UIView!
    @IBOutlet weak var owedSearchCustomerTF: UITextField!
    @IBOutlet weak var owedSearchProductTF: UITextField!
    @IBOutlet weak var owedSearchStateTF: UITextField!
    
    @IBOutlet weak var dateBtnView: UIView!
    @IBOutlet weak var dateBtnContentView: UIView!
    
    @IBOutlet weak var hudView: UIView!
    @IBOutlet weak var comScrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        view = Bundle.main.loadNibNamed("SAMComOperationController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - UICollectionViewDelegate
extension SAMComOperationController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView != comScrollView {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        if (offsetX < ScreenW * 5) && (offsetX > 0) && !navIndicaterView!.didClicked {
            navIndicaterView!.setIndicaterViewLeftDistance(dicstance: offsetX / 6)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView != comScrollView {
            return
        }
        
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView != comScrollView {
            return
        }
        
        //记录当前位置
        currentColIndex = Int(scrollView.contentOffset.x) / Int(ScreenW)
        
        //记录当前collectionView
        currentCollectionView = [orderManageColView, forSaleColView, owedColView, saleHistoryColView, customerRankColView, productRankColView][currentColIndex]
        
        //检查navIndicaterView当前选中按钮
        navIndicaterView?.checkSelectedIndex(shouldSelectedIndex: currentColIndex)
        
        switch currentColIndex {
        case 0:
            beginDateTF.isEnabled = true
            endDateTF.isEnabled = true
            customerSearchTF.placeholder = "客户名称"
            stateSearchTF.isEnabled = true
            stateSearchTF.placeholder = "状态"
            stateSearchTF.inputView = stateSearchPickerView
            
            scrolltoForSaleView(isForSale: false)
            owedSearchView.isHidden = true
            
        case 1:
            scrolltoForSaleView(isForSale: true)
            
        case 2:
            beginDateTF.isEnabled = true
            endDateTF.isEnabled = true
            customerSearchTF.placeholder = "客户名称"
            stateSearchTF.isEnabled = true
            stateSearchTF.placeholder = "状态"
            stateSearchTF.inputView = stateSearchPickerView
            
            scrolltoForSaleView(isForSale: false)
            owedSearchView.isHidden = false
            
        case 3:
            beginDateTF.isEnabled = true
            endDateTF.isEnabled = true
            customerSearchTF.placeholder = "客户名称"
            stateSearchTF.isEnabled = false
            stateSearchTF.placeholder = "---"
            
            scrolltoForSaleView(isForSale: false)
            owedSearchView.isHidden = true
            
        case 4:
            beginDateTF.isEnabled = true
            endDateTF.isEnabled = true
            customerSearchTF.placeholder = "客户名称"
            stateSearchTF.placeholder = "部门"
            stateSearchTF.isEnabled = false
            
            scrolltoForSaleView(isForSale: false)
            owedSearchView.isHidden = true
            
        case 5:
            beginDateTF.isEnabled = true
            endDateTF.isEnabled = true
            customerSearchTF.placeholder = "产品名称"
            stateSearchTF.placeholder = "分类"
            stateSearchTF.isEnabled = false
            
            scrolltoForSaleView(isForSale: false)
            owedSearchView.isHidden = true
            
        default:
            break
        }
        
        customerSearchTF.text = ""
        
        //刷新stateSearchPickerView
        if searchStates[currentColIndex].count == 0 {
            stateSearchTF.text = ""
        }else {
            pickerView(stateSearchPickerView, didSelectRow: 0, inComponent: 0)
        }
    }
    
    //当前是否是待售布匹搜索界面
    fileprivate func scrolltoForSaleView(isForSale: Bool) {
        forSaleSearchView.isHidden = !isForSale
        dropDownBtn.isEnabled = !isForSale
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case self.orderManageColView:
            orderManageColViewdidSelected(indexpath: indexPath)
        case self.forSaleColView:
            forSaleColViewdidSelected(indexpath: indexPath)
        case self.owedColView:
            owedColViewdidSelected(indexpath: indexPath)
        case self.saleHistoryColView:
            saleHistoryColViewdidSelected(indexpath: indexPath)
        case self.customerRankColView:
            customerRankColViewdidSelected(indexpath: indexPath)
        case self.productRankColView:
            productRankColViewdidSelected(indexpath: indexPath)
        default :
            break
        }
    }
}

//MARK: - UICollectionViewDataSource
extension SAMComOperationController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.orderManageColView:
            return self.orderManageModels.count
        case self.forSaleColView:
            return self.forSaleModels.count
        case self.owedColView:
            return self.owedModels.count
        case self.saleHistoryColView:
            return self.saleHistoryModels.count
        case self.customerRankColView:
            return self.customerRankModels.count
        case self.productRankColView:
            return self.productRankModels.count
        default :
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case self.orderManageColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[0], for: indexPath) as! SAMComOperationCell
            let model = orderManageModels[indexPath.row] as! SAMOrderModel
            cell.orderInfoModel = model
            return cell
            
        case self.forSaleColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[1], for: indexPath) as! SAMComOperationCell
            let model = forSaleModels[indexPath.row] as! SAMForSaleModel
            cell.forSaleInfoModel = model
            return cell
            
        case self.owedColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[2], for: indexPath) as! SAMComOperationCell
            let model = owedModels[indexPath.row] as! SAMOwedInfoModel
            cell.owedInfoModel = model
            return cell
            
        case self.saleHistoryColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[3], for: indexPath) as! SAMComOperationCell
            let model = saleHistoryModels[indexPath.row] as! SAMSaleOrderInfoModel
            cell.saleOrderInfoModel = model
            return cell
            
        case self.customerRankColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[4], for: indexPath) as! SAMComOperationViewRankCell
            let model = customerRankModels[indexPath.row] as! SAMCustomerRankModel
            cell.customerRankModel = model
            return cell
            
        case self.productRankColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[5], for: indexPath) as! SAMComOperationViewRankCell
            let model = productRankModels[indexPath.row] as! SAMProductRankModel
            cell.productRankModel = model
            return cell
            
        default :
            return UICollectionViewCell()
        }
    }
}

//MARK: - 导航栏指示器代理
extension SAMComOperationController: SAMComOperationIndicaterViewDelegate {
    func comOperationIndicaterViewDidSelected(index: Int) {
        
        endFirstTextFieldEditing()
        comScrollView.setContentOffset(CGPoint(x: ScreenW * CGFloat(index), y: 0), animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension SAMComOperationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //停止当前collectionView的滚动
        currentCollectionView!.setContentOffset(currentCollectionView!.contentOffset, animated: true)
        
        //展现hudView
        hudView.isHidden = false
        
        //判断dateBtnView是否展现
        if dropDownBtn.isSelected {
            
            //隐藏界面
            dropDownBtnClick(dropDownBtn)
        }
        
        //设置第一响应者
        firstTF = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //清空firstTF
        firstTF = nil
        
        //隐藏hudView
        hideHUDView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //结束第一响应者编辑状态
        endFirstTextFieldEditing()
        return true
    }
}

//MARK: - PickerViewDataSource PickerViewDelegate
extension SAMComOperationController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentColIndex == 1 { //待售布匹搜索控件
            return forSaleDrawerModels.count
            
        }else {
            return searchStates[currentColIndex].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentColIndex == 1 { //待售布匹搜索控件
            let model = forSaleDrawerModels[row] as! SAMForSaleDrawerModel
            return model.userName
            
        }else {
            return searchStates[currentColIndex][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentColIndex == 1 { //待售布匹搜索控件
            //记录当前选中
            forSaleDrawerSelectedModel = forSaleDrawerModels[row] as? SAMForSaleDrawerModel
            forSaleDrawerTF.text = forSaleDrawerSelectedModel?.userName
            
        }else {
            stateSearchTF.text = searchStates[currentColIndex][row]
            owedSearchStateTF.text = searchStates[currentColIndex][row]
        }
    }
}

//MARK: - 订单请求方法
extension SAMComOperationController {
    
    func loadNewOrderModels() {
        
        //结束下拉刷新
        orderManageColView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndexs[0] = 1
        
        let employeeID = SAMUserAuth.shareUser()!.employeeID!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndexs[0])
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let statusStr = searchConIn(textField: stateSearchTF)
        orderRequestParameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "status": statusStr]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[0], parameters: orderRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.orderManageModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.orderManageColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndexs[0] += 1
                }
                self!.orderManageModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.orderManageColView.mj_header.endRefreshing()
                
                //刷新数据
                self!.orderManageColView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.orderManageColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreOrderModels() {
        
        //结束下拉刷新
        orderManageColView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndexs[0])
        orderRequestParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[0], parameters: orderRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.orderManageColView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.orderManageColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndexs[0] += 1
                    
                    //处理下拉
                    self!.orderManageColView.mj_footer.endRefreshing()
                }
                self!.orderManageModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.orderManageColView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.orderManageColView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 待售布匹请求方法
extension SAMComOperationController {
    
    func loadNewforSaleModels() {
        //如果没有选中的用户模型
        if forSaleDrawerSelectedModel == nil {
            loadForSaleDrawerModels()
            _ = SAMHUD.showMessage("网络错误，请重试", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //创建请求参数
        let userID = forSaleDrawerSelectedModel!.id
        let CGUnitName = searchConIn(textField: forSaleCustomerTF)
        let productIDName = searchConIn(textField: forSaleProductTF)
        let parameters = ["userID": userID, "CGUnitName": CGUnitName, "productIDName": productIDName]
        
        //加载统计信息
        loadForSaleStaticInfo(staticParameters: parameters)
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[1], parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.forSaleModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else { //有数据模型
                let arr = SAMForSaleModel.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.forSaleModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                //结束上拉
                self!.forSaleColView.mj_header.endRefreshing()
                //刷新数据
                self!.forSaleColView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.forSaleColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    ///加载开单人列表请求方法
    fileprivate func loadForSaleDrawerModels() {
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getUserList.ashx", parameters: nil, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else { //有数据模型
                //清空原先数据
                self!.forSaleDrawerModels.removeAllObjects()
                //添加数据
                let arr = SAMForSaleDrawerModel.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.forSaleDrawerModels.addObjects(from: arr as [AnyObject])
                //赋值数据
                self!.forSaleDrawerSelectedModel = self!.forSaleDrawerModels[0] as? SAMForSaleDrawerModel
                
            }
        }) { (Task, Error) in
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    ///加载待售布匹统计信息
    fileprivate func loadForSaleStaticInfo(staticParameters: Any?) {
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getReadySellProductStatic.ashx", parameters: staticParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as! [[String: AnyObject]]
            let countP = dictArr[0]["countP"] as! String
            let countM = dictArr[0]["countM"] as! String
            
            //回主线程
            DispatchQueue.main.async(execute: {
                self!.forSaleStaticTF.text = countP + "/" + countM
            })
            
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.forSaleColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreforSaleModels() {}
}

//MARK: - 缺货登记请求方法
extension SAMComOperationController {
    
    func loadNewOwedModels() {
        
        //结束下拉刷新
        owedColView.mj_footer.endRefreshing()
        
        //创建请求参数
        let userID = SAMUserAuth.shareUser()!.id!
        let CGUnitName = searchConIn(textField: owedSearchCustomerTF)
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let iState = searchConIn(textField: owedSearchStateTF)
        let productIDName = searchConIn(textField: owedSearchProductTF)
        
        let pageSize = "20"
        let pageIndex = "0"
        
        oweRequestParameters = ["userID": userID, "CGUnitName": CGUnitName, "startDate": startDate, "endDate": endDate, "iState": iState, "productIDName": productIDName, "pageSize": pageSize, "pageIndex": pageIndex]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[2], parameters: oweRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            //清空原先数据
            self!.owedModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                self!.owedColView.reloadData()
            }else { //有数据模型
                
                let arr = SAMOwedInfoModel.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.owedModels.addObjects(from: arr as [AnyObject])
                self!.owedColView.mj_footer.endRefreshingWithNoMoreData()
                self!.countOwed()
                self!.searchOwedStock()
            }
        }) {[weak self] (Task, Error) in
            
            //处理上拉
            self!.owedColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreOwedModels() {}
    
    fileprivate func searchOwedStock() {
        
        ///初始化数据
        if !didSetStockNode {
            SAMOwedStockNode = 0.0
        }
        didSetStockNode = false
        owedProductIDSearchArr.removeAllObjects()
        owedClassifyArr.removeAllObjects()
        
        //数据分类
        for owedModelIndex in 1...(owedModels.count - 1) {
            
            let owedModel = owedModels[owedModelIndex] as! SAMOwedInfoModel
            let searchStrArr = owedModel.productIDName.components(separatedBy: "-")
            let searchStr = searchStrArr[0] + "-" + searchStrArr[1]
            
            if !owedProductIDSearchArr.contains(searchStr) {
                
                owedProductIDSearchArr.add(searchStr)
                
                let mArr = NSMutableArray()
                mArr.add(owedModel)
                owedClassifyArr.add(mArr)
                
            }else {
                
                let index = owedProductIDSearchArr.index(of: searchStr)
                let mArr = owedClassifyArr[index] as! NSMutableArray
                mArr.add(owedModel)
            }
        }
        
        setupProgressHUD()
        
        owedProductIDSearchArr1.removeAllObjects()
        owedClassifyArr1.removeAllObjects()
        owedArrSearchCount1 = 0
        
        owedProductIDSearchArr2.removeAllObjects()
        owedClassifyArr2.removeAllObjects()
        owedArrSearchCount2 = 0
        
        owedProductIDSearchArr3.removeAllObjects()
        owedClassifyArr3.removeAllObjects()
        owedArrSearchCount3 = 0
        
        owedProductIDSearchArr4.removeAllObjects()
        owedClassifyArr4.removeAllObjects()
        owedArrSearchCount4 = 0
        
        owedProductIDSearchArr5.removeAllObjects()
        owedClassifyArr5.removeAllObjects()
        owedArrSearchCount5 = 0
        
        if owedProductIDSearchArr.count < 6 {
            owedProductIDSearchArr1.addObjects(from: owedProductIDSearchArr as! [Any])
            owedClassifyArr1.addObjects(from: owedClassifyArr as! [Any])
            loadStock1()
            return
        }
        
        let perCount = owedProductIDSearchArr.count / 5
        for index in 0...(owedProductIDSearchArr.count - 1) {
            
            if index < perCount {
                
                owedProductIDSearchArr1.add(owedProductIDSearchArr[index])
                owedClassifyArr1.add(owedClassifyArr[index])
                
            }else if (index >= perCount) && (index < perCount * 2) {
                
                owedProductIDSearchArr2.add(owedProductIDSearchArr[index])
                owedClassifyArr2.add(owedClassifyArr[index])
                
            }else if (index >= perCount * 2) && (index < perCount * 3) {
                
                owedProductIDSearchArr3.add(owedProductIDSearchArr[index])
                owedClassifyArr3.add(owedClassifyArr[index])
                
            }else if (index >= perCount * 3) && (index < perCount * 4) {
                
                owedProductIDSearchArr4.add(owedProductIDSearchArr[index])
                owedClassifyArr4.add(owedClassifyArr[index])
                
            }else {
                
                owedProductIDSearchArr5.add(owedProductIDSearchArr[index])
                owedClassifyArr5.add(owedClassifyArr[index])
            }
        }
        
        loadStock1()
        loadStock2()
        loadStock3()
        loadStock4()
        loadStock5()
        
    }
    
    fileprivate func setupProgressHUD() {
        
        owedStockSearchProgressHud = SAMHUD.showAdded(to: KeyWindow!, animated: true)
        owedStockSearchProgressHud!.mode = MBProgressHUDMode.annularDeterminate
        let userName = UserDefaults.standard.object(forKey: "userNameStrKey") as? String
        var remarkText: String?
        if userName == "任玉" {
            
            remarkText = String.init(format: "别急嘛~ 小玉😳", userName!)
        }else if userName == "王超超" {
            
            remarkText = String.init(format: "别急嘛~ 超超😉", userName!)
        }else {
            
            remarkText = "正在解析..."
        }
        owedStockSearchProgressHud!.labelText = NSLocalizedString(remarkText!, comment: "HUD loading title")
    }
    
    fileprivate func setHUDProgress() {
        
        if owedStockSearchProgressHud == nil {
            return
        }
        
        let progress = (Float)(owedArrSearchCount1 + owedArrSearchCount2 + owedArrSearchCount3 + owedArrSearchCount4 + owedArrSearchCount5) / (Float)(owedClassifyArr.count)
        
        if progress < 1.0 {
            owedStockSearchProgressHud!.progress = progress
            
        }else {
            
            owedStockSearchProgressHud!.hide(true)
            owedStockSearchProgressHud = nil
        }
    }
    
    fileprivate func getOwedStockComplete() {
        
        print(owedArrSearchCount1 + owedArrSearchCount2 + owedArrSearchCount3 + owedArrSearchCount4 + owedArrSearchCount5)
        print(owedClassifyArr.count)
        
        if owedArrSearchCount1 + owedArrSearchCount2 + owedArrSearchCount3 + owedArrSearchCount4 + owedArrSearchCount5 == owedClassifyArr.count{
            
            //回主线程，刷新数据
            DispatchQueue.main.async(execute: {
                self.owedColView.mj_header.endRefreshing()
                self.owedColView.reloadData()
            })
        }
    }
    
    
    fileprivate func loadStock1() {
        
        let productNameSearchStr = owedProductIDSearchArr1[owedArrSearchCount1]
        let conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject, "pageSize": "600" as AnyObject, "pageIndex": "1" as AnyObject, "showAlert": "false" as AnyObject]
        
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters, progress: nil, success: {[weak self] (Task, Json) in
            
            self!.owedArrSearchCount1 += 1
            
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            if count == 0 { //没有模型数据
                
            }else { //有数据模型
                
                let stockModelArr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let productIDSearchStr = conSearchParameters["productIDName"] as! String
                let searchStrIndex = self!.owedProductIDSearchArr1.index(of: productIDSearchStr)
                let owedModelArr = self!.owedClassifyArr1[searchStrIndex] as! NSMutableArray
                
                for owedModelIndex in 0...(owedModelArr.count - 1) {
                    
                    let owedModel = owedModelArr[owedModelIndex] as! SAMOwedInfoModel
                    for stockModelIndex in 0...(stockModelArr.count - 1) {
                        
                        let stockModel = stockModelArr[stockModelIndex] as! SAMStockProductModel
                        if stockModel.productIDName == owedModel.productIDName {
                            
                            owedModel.stockCountM = stockModel.countM
                            break
                        }
                    }
                }
            }
            
            }, failure: {[weak self] (Task, Error) in
                
                self!.owedArrSearchCount1 += 1
        })
    }
    
    fileprivate func loadStock2() {
        
        let productNameSearchStr = owedProductIDSearchArr2[owedArrSearchCount2]
        let conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject, "pageSize": "600" as AnyObject, "pageIndex": "1" as AnyObject, "showAlert": "false" as AnyObject]
        
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters, progress: nil, success: {[weak self] (Task, Json) in
            
            self!.owedArrSearchCount2 += 1
            
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            if count == 0 { //没有模型数据
                
            }else { //有数据模型
                
                let stockModelArr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let productIDSearchStr = conSearchParameters["productIDName"] as! String
                let searchStrIndex = self!.owedProductIDSearchArr2.index(of: productIDSearchStr)
                let owedModelArr = self!.owedClassifyArr2[searchStrIndex] as! NSMutableArray
                
                for owedModelIndex in 0...(owedModelArr.count - 1) {
                    
                    let owedModel = owedModelArr[owedModelIndex] as! SAMOwedInfoModel
                    for stockModelIndex in 0...(stockModelArr.count - 1) {
                        
                        let stockModel = stockModelArr[stockModelIndex] as! SAMStockProductModel
                        if stockModel.productIDName == owedModel.productIDName {
                            
                            owedModel.stockCountM = stockModel.countM
                            break
                        }
                    }
                }
            }
            
            }, failure: {[weak self] (Task, Error) in
                
                self!.owedArrSearchCount2 += 1
        })
    }
    
    fileprivate func loadStock3() {
        
        let productNameSearchStr = owedProductIDSearchArr3[owedArrSearchCount3]
        let conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject, "pageSize": "600" as AnyObject, "pageIndex": "1" as AnyObject, "showAlert": "false" as AnyObject]
        
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters, progress: nil, success: {[weak self] (Task, Json) in
            
            self!.owedArrSearchCount3 += 1
            
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            if count == 0 { //没有模型数据
                
            }else { //有数据模型
                
                let stockModelArr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let productIDSearchStr = conSearchParameters["productIDName"] as! String
                let searchStrIndex = self!.owedProductIDSearchArr3.index(of: productIDSearchStr)
                let owedModelArr = self!.owedClassifyArr3[searchStrIndex] as! NSMutableArray
                
                for owedModelIndex in 0...(owedModelArr.count - 1) {
                    
                    let owedModel = owedModelArr[owedModelIndex] as! SAMOwedInfoModel
                    for stockModelIndex in 0...(stockModelArr.count - 1) {
                        
                        let stockModel = stockModelArr[stockModelIndex] as! SAMStockProductModel
                        if stockModel.productIDName == owedModel.productIDName {
                            
                            owedModel.stockCountM = stockModel.countM
                            break
                        }
                    }
                }
            }
            
            }, failure: {[weak self] (Task, Error) in
                
                self!.owedArrSearchCount3 += 1
        })
    }
    
    fileprivate func loadStock4() {
        
        let productNameSearchStr = owedProductIDSearchArr4[owedArrSearchCount4]
        let conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject, "pageSize": "600" as AnyObject, "pageIndex": "1" as AnyObject, "showAlert": "false" as AnyObject]
        
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters, progress: nil, success: {[weak self] (Task, Json) in
            
            self!.owedArrSearchCount4 += 1
            
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            if count == 0 { //没有模型数据
                
            }else { //有数据模型
                
                let stockModelArr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let productIDSearchStr = conSearchParameters["productIDName"] as! String
                let searchStrIndex = self!.owedProductIDSearchArr4.index(of: productIDSearchStr)
                let owedModelArr = self!.owedClassifyArr4[searchStrIndex] as! NSMutableArray
                
                for owedModelIndex in 0...(owedModelArr.count - 1) {
                    
                    let owedModel = owedModelArr[owedModelIndex] as! SAMOwedInfoModel
                    for stockModelIndex in 0...(stockModelArr.count - 1) {
                        
                        let stockModel = stockModelArr[stockModelIndex] as! SAMStockProductModel
                        if stockModel.productIDName == owedModel.productIDName {
                            
                            owedModel.stockCountM = stockModel.countM
                            break
                        }
                    }
                }
            }
            
            }, failure: {[weak self] (Task, Error) in
                
                self!.owedArrSearchCount4 += 1
        })
    }
    
    fileprivate func loadStock5() {
        
        let productNameSearchStr = owedProductIDSearchArr5[owedArrSearchCount5]
        let conSearchParameters = ["productIDName": productNameSearchStr as AnyObject, "minCountM": "0" as AnyObject, "parentID": "-1" as AnyObject, "storehouseID": "-1" as AnyObject, "pageSize": "600" as AnyObject, "pageIndex": "1" as AnyObject, "showAlert": "false" as AnyObject]
        
        SAMNetWorker.sharedNetWorker().get("getStock.ashx", parameters: conSearchParameters, progress: nil, success: {[weak self] (Task, Json) in
            
            self!.owedArrSearchCount5 += 1
            //获取模型数组
            let Json = Json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            if count == 0 { //没有模型数据
                
            }else { //有数据模型
                
                let stockModelArr = SAMStockProductModel.mj_objectArray(withKeyValuesArray: dictArr)!
                let productIDSearchStr = conSearchParameters["productIDName"] as! String
                let searchStrIndex = self!.owedProductIDSearchArr5.index(of: productIDSearchStr)
                let owedModelArr = self!.owedClassifyArr5[searchStrIndex] as! NSMutableArray
                
                for owedModelIndex in 0...(owedModelArr.count - 1) {
                    
                    let owedModel = owedModelArr[owedModelIndex] as! SAMOwedInfoModel
                    for stockModelIndex in 0...(stockModelArr.count - 1) {
                        
                        let stockModel = stockModelArr[stockModelIndex] as! SAMStockProductModel
                        if stockModel.productIDName == owedModel.productIDName {
                            
                            owedModel.stockCountM = stockModel.countM
                            break
                        }
                    }
                }
            }
            
            }, failure: {[weak self] (Task, Error) in
                
                self!.owedArrSearchCount5 += 1
        })
    }
    
    
    fileprivate func countOwed() {
        
        //对数组内所有数据模型进行遍历
        var countP = 0
        var countM = 0.0
        for obj in owedModels {
            let model = obj as! SAMOwedInfoModel
            countP += model.countP
            countM += model.countM
        }
        let countModel = SAMOwedInfoModel()
        countModel.countP = countP
        countModel.countM = countM
        countModel.CGUnitName = "当前页面统计"
        countModel.iState = "统计"
        countModel.stockCountM = 1000000
        owedModels.insert(countModel, at: 0)
    }
}

//MARK: - 销售历史请求方法
extension SAMComOperationController {
    
    func loadNewSaleHistoryModels() {
        
        //结束下拉刷新
        saleHistoryColView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndexs[3] = 1
        let employeeID = SAMUserAuth.shareUser()!.employeeID!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndexs[3])
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        saleHistoryRequestParameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[3], parameters: saleHistoryRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.saleHistoryModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMSaleOrderInfoModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.saleHistoryColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    let textfielt = UITextField();
                    
                    self!.requestSearchPageIndexs[3] += 1
                }
                self!.saleHistoryModels.addObjects(from: arr as [AnyObject])
            }
            
            //结束上拉
            self!.saleHistoryColView.mj_header.endRefreshing()
            
            //回主线程
            DispatchQueue.main.async(execute: {
                //刷新数据
                self!.saleHistoryColView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.saleHistoryColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreSaleHistoryModels() {
        
        //结束下拉刷新
        saleHistoryColView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndexs[3])
        saleHistoryRequestParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[3], parameters: saleHistoryRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.saleHistoryColView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMSaleOrderInfoModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.saleHistoryColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndexs[3] += 1
                    
                    //处理下拉
                    self!.saleHistoryColView.mj_footer.endRefreshing()
                }
                self!.saleHistoryModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.saleHistoryColView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.saleHistoryColView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 客户排行请求方法
extension SAMComOperationController {
    
    //加载数据
    func loadNewCustomerRankModels() {
        
        //结束下拉刷新
        customerRankColView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndexs[4] = 1
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let deptName = ""
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndexs[4])
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let userID = SAMUserAuth.shareUser()!.id!
        customerRankRequestParameters = ["CGUnitName": CGUnitName, "deptName": deptName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "userID": userID]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[4], parameters: customerRankRequestParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.customerRankModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMCustomerRankModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.customerRankColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndexs[4] += 1
                }
                self!.customerRankModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.customerRankColView.mj_header.endRefreshing()
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self!.customerRankColView.reloadData()
                }, completion: { (_) in
                })
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.customerRankColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //加载更多数据
    func loadMoreCustomerRankModels() {
        //结束下拉刷新
        customerRankColView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndexs[4])
        customerRankRequestParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[4], parameters: customerRankRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.customerRankColView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMCustomerRankModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.customerRankColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndexs[4] += 1
                    
                    //处理下拉
                    self!.customerRankColView.mj_footer.endRefreshing()
                }
                self!.customerRankModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.customerRankColView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.customerRankColView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 产品排行请求方法
extension SAMComOperationController {
    
    //加载数据
    func loadNewProductRankModels() {
        
        //结束下拉刷新
        productRankColView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndexs[5] = 1
        let categoryName = ""
        let productIDName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndexs[5])
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        productRankRequestParameters = ["categoryName": categoryName, "productIDName": productIDName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[5], parameters: productRankRequestParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.productRankModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMProductRankModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.productRankColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndexs[5] += 1
                }
                self!.productRankModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.productRankColView.mj_header.endRefreshing()
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self!.productRankColView.reloadData()
                }, completion: { (_) in
                })
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.productRankColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //加载更多数据
    func loadMoreProductRankModels() {
        //结束下拉刷新
        productRankColView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndexs[5])
        productRankRequestParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[5], parameters: productRankRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.productRankColView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMProductRankModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.productRankColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndexs[5] += 1
                    
                    //处理下拉
                    self!.productRankColView.mj_footer.endRefreshing()
                }
                self!.productRankModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.productRankColView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.productRankColView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }    }
}

//MARK: - 控制器里前四个collectionView用到的FlowLayout
private class SAMComOperationColletionViewFlowlayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView?.showsVerticalScrollIndicator = false
        itemSize = CGSize(width: ScreenW, height: 95)
    }
}

//MARK: - 控制器里排行collectionView用到的FlowLayout
private class SAMComOperationRankColletionViewFlowlayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView?.showsVerticalScrollIndicator = false
        itemSize = CGSize(width: ScreenW, height: 55)
    }
}

//MARK: - 各个colectionView点击事件处理
extension SAMComOperationController {
    
    //订单管理
    fileprivate func orderManageColViewdidSelected(indexpath: IndexPath) {
        
        //取出数据模型
        let selectedModel = self.orderManageModels[indexpath.item] as! SAMOrderModel
        
        //当前已经发货
        if selectedModel.isAgreeSend! == "是" {
            orderCheck(orderModel: selectedModel)
            
        }else { //当前没有发货
            //alertvc
            let alertVC = UIAlertController(title: "请选择操作！", message: nil, preferredStyle: .alert)
            
            //发货按钮
            alertVC.addAction(UIAlertAction(title: "发货", style: .destructive, handler: { (_) in
                self.orderAgreeSend(orderModel: selectedModel)
            }))
            //编辑查看按钮
            alertVC.addAction(UIAlertAction(title: "编辑/查看", style: .cancel, handler: { (_) in
                self.orderCheck(orderModel: selectedModel)
            }))
            
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    ///订单管理，查看订单方法
    fileprivate func orderCheck(orderModel: SAMOrderModel) {
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("", comment: "HUD loading title")
        
        orderModel.loadMoreInfo(success: {
            hud?.hide(true)
            let vc = SAMOrderOwedOperationController.checkOrder(orderInfoModel: orderModel, type: .checkOrder)
            self.navigationController!.pushViewController(vc, animated: true)
        }) {
            hud?.hide(true)
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    ///订单管理，发货方法
    fileprivate func orderAgreeSend(orderModel: SAMOrderModel) {
        
        let alertVC = UIAlertController(title: "确定发货？", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            
            //设置加载hud
            let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)!
            hud.labelText = NSLocalizedString("请等待...", comment: "HUD loading title")
            
            SAMNetWorker.sharedNetWorker().get("OrderBillAgreeSend.ashx", parameters: ["billNumber": orderModel.billNumber!], progress: nil, success: { (task, json) in
                
                //获取状态字符串
                let Json = json as! [String: AnyObject]
                let dict = Json["head"] as! [String: String]
                let state = dict["status"]
                
                if state == "success" { //发货成功
                    hud.hide(true)
                    let _ = SAMHUD.showMessage("发货成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                    
                }else { //发货失败
                    hud.hide(true)
                    let _ = SAMHUD.showMessage("发货失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                }
            }) { (task, error) in
                
                hud.hide(true)
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }
        })
        )
        
        present(alertVC, animated: true, completion: nil)
    }
    
    //待售布匹
    fileprivate func forSaleColViewdidSelected(indexpath: IndexPath) {
        let vc = SAMForSaleOrderDetailController.instance(forSaleModels: forSaleModels, selectedIndex: indexpath)
        navigationController!.present(vc, animated: true, completion: nil)
    }
    //缺货登记
    fileprivate func owedColViewdidSelected(indexpath: IndexPath) {
        let selectedModel = owedModels[indexpath.item] as! SAMOwedInfoModel
        let vc = SAMOrderOwedOperationController.checkOwe(oweInfoModel: selectedModel, type: .checkOwe)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    //销售历史
    fileprivate func saleHistoryColViewdidSelected(indexpath: IndexPath) {
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("正在加载...", comment: "HUD loading title")
        
        //取出模型
        let selectedModel = saleHistoryModels[indexpath.item] as! SAMSaleOrderInfoModel
        
        //创建控制器
        let detailVC = SAMOrderDetailController.instance()
        
        //传递订单模型
        detailVC.orderInfoModel = selectedModel
        
        //加载订单详情列表数组模型数组
        detailVC.loadOrderDetailListModels()
        
        //加载订单详情数组模型
        detailVC.loadOrderDetailModel({
            
            DispatchQueue.main.async(execute: {
                //隐藏hud
                hud!.hide(true)
                //成功回调闭包
                self.navigationController?.pushViewController(detailVC, animated: true)
            })
        }, noData: {
            
            DispatchQueue.main.async(execute: {
                //隐藏hud
                hud!.hide(true)
                
                //提示用户
                let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }) {
            
            DispatchQueue.main.async(execute: {
                //隐藏hud
                hud!.hide(true)
                
                //提示用户
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }
        
    }
    //客户排行
    fileprivate func customerRankColViewdidSelected(indexpath: IndexPath) {
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("", comment: "HUD loading title")
        
        let model = customerRankModels[indexpath.item] as! SAMCustomerRankModel
        let vc = SAMRankDetailController.instance(customerRankModel: model, productRankModel: nil)
        vc.willSearchRankDetailInfo(startDateStr: beginDateTF.text!, endDateStr: endDateTF.text!, success: {
            hud?.hide(true)
            self.navigationController!.present(vc, animated: true, completion: nil)
            
        }, noData: {
            hud?.hide(true)
            let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            
        }) {
            hud?.hide(true)
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    //产品排行
    fileprivate func productRankColViewdidSelected(indexpath: IndexPath) {
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("", comment: "HUD loading title")
        
        let model = productRankModels[indexpath.item] as! SAMProductRankModel
        let vc = SAMRankDetailController.instance(customerRankModel: nil, productRankModel: model)
        vc.willSearchRankDetailInfo(startDateStr: beginDateTF.text!, endDateStr: endDateTF.text!, success: {
            hud?.hide(true)
            self.navigationController!.present(vc, animated: true, completion: nil)
            
        }, noData: {
            hud?.hide(true)
            let _ = SAMHUD.showMessage("没有数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            
        }) {
            hud?.hide(true)
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

