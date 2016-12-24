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
        
        //初始化UI
        setupBasicUI()
        
        //设置ScrollView
        setupScrollView()
        
        //设置导航栏指示控制器
        setupNavIndicaterView()
    }
    
    //MARK: - 初始化UI
    fileprivate func setupBasicUI() {
        
        //设置时间选择器最大时间
        datePicker!.maximumDate = Date()
        
        //设置dateBtnView的锚点, transform
        dateBtnView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        dateBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        dateBtnView.alpha = 0.00001
        
        //设置时间按钮控件边框
        dateBtnContentView.layer.cornerRadius = 5
        
        //设置文本框
        let arr = NSArray(array: [beginDateTF, endDateTF, customerSearchTF, stateSearchTF])
        arr.enumerateObjects({ (obj, _, _) in
            let textField = obj as! UITextField
            
            //设置代理
            textField.delegate = self
            
            //设置订单分类的inputView
            if textField == stateSearchTF {
                textField.text = "所有"
                textField.inputView = stateSearchPickerView
            }
            
            //设置 beginDateTF, endDateTF 的 inputView
            if (textField == self.beginDateTF) || (textField == self.endDateTF) {
                
                //设置inputView
                textField.inputView = datePicker
                
                //监听事件
                textField.addTarget(self, action: #selector(SAMComOperationController.textFieldidChangeText), for: .editingChanged)
            }
        })
        
        //设置hudView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMComOperationController.hudViewDidClick))
        hudView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - 设置ScrollView
    fileprivate func setupScrollView() {
        
        
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
            collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: collectionViewsMjfooterSelectors[index])
            
            //没有数据自动隐藏footer
            collectionView.mj_footer.isAutomaticallyHidden = true
            
            //添加collectionView
            comScrollView.addSubview(collectionView)
            
            collectionView.backgroundColor = customBGWhiteColor
        }
    }
    
    //MARK: - 设置导航栏指示器
    fileprivate func setupNavIndicaterView() {
        navIndicaterView!.delegate = self
        navigationItem.titleView = navIndicaterView
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.1) {
            self.navIndicaterView!.alpha = 1
        }
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navIndicaterView!.alpha = 0.0000001
        }
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
    
    //MARK: - 点击时间下拉按钮
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
    
    //MARK: - 搜索按钮点击
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
            owedColView.mj_header.beginRefreshing()
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
    
    //MARK: - 4个时间按钮的点击
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
        
        //调用文本框内容监听方法
        textFieldidChangeText()
    }
    
    //时间选择器 选择时间
    func dateChanged(_ datePicker: UIDatePicker) {
        
        //设置文本框时间
        firstTF?.text = datePicker.date.yyyyMMddStr()
        
        //调用文本框内容监听方法
        textFieldidChangeText()
    }
    
    //MARK: - 文本框改变内容
    func textFieldidChangeText() {
        if beginDateTF.hasText && endDateTF.hasText { //起始和截止时间文本框都有时间才让搜索按钮可用
            searchBtn.isEnabled = true
        }else {
            searchBtn.isEnabled = false
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
    
    //MARK: - 结束textField编辑状态
    fileprivate func endFirstTextFieldEditing() {
        if firstTF != nil {
            firstTF?.resignFirstResponder()
        }
    }
    
    //MARK: - 隐藏HUDView
    fileprivate func hideHUDView() {
        if firstTF == nil && dropDownBtn.isSelected == false {
            hudView.isHidden = true
        }
    }
    
    //MARK: - 导航控制器push其他控制器的时候调
    
    //MARK: - 属性懒加载
    ///订单管理collectionView
    fileprivate let orderManageColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///待售布匹collectionView
    fileprivate let forSaleColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///缺货登记collectionView
    fileprivate let owedColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///销售历史collectionView
    fileprivate let saleHistoryColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///客户排行collectionView
    fileprivate let customerRankColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    ///产品排行collectionView
    fileprivate let productRankColView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMComOperationColletionViewFlowlayout())
    
    ///当前collectionView的序号
    fileprivate var currentColIndex = 0
    
    ///订单管理collectionView数据模型数组
    fileprivate var orderManageModels = NSMutableArray()
    ///待售布匹collectionView数据模型数组
    fileprivate var forSaleModels = NSMutableArray()
    ///缺货登记collectionView数据模型数组
    fileprivate var owedModels = NSMutableArray()
    ///销售历史collectionView数据模型数组
    fileprivate var saleHistoryModels = NSMutableArray()
    ///客户排行collectionView数据模型数组
    fileprivate var customerRankModels = NSMutableArray()
    ///产品排行collectionView数据模型数组
    fileprivate var productRankModels = NSMutableArray()
    
    ///各collectionView下拉刷新触动的方法
    fileprivate let collectionViewsMjheaderSelectors = [#selector(SAMComOperationController.loadNewOrderModels), #selector(SAMComOperationController.loadNewforSaleModels), #selector(SAMComOperationController.loadNewOwedModels), #selector(SAMComOperationController.loadNewSaleHistoryModels), #selector(SAMComOperationController.loadNewCustomerRankModels), #selector(SAMComOperationController.loadNewProductRankModels)]
    
    ///各collectionView上拉刷新触动的方法
    fileprivate let collectionViewsMjfooterSelectors = [#selector(SAMComOperationController.loadMoreOrderModels), #selector(SAMComOperationController.loadMoreforSaleModels), #selector(SAMComOperationController.loadMoreOwedModels), #selector(SAMComOperationController.loadMoreSaleHistoryModels), #selector(SAMComOperationController.loadMoreCustomerRankModels), #selector(SAMComOperationController.loadMoreProductRankModels)]
    
    ///所有collectionView注册的nibName
    fileprivate let rigisterReuseNames = ["SAMOrderManagerCell", "SAMOrderManagerCell", "SAMOwedCell", "SAMSaleInfoCell", "SAMOrderManagerCell", "SAMOrderManagerCell"]
    
    ///所有接口字符串
    fileprivate let requestURLStrs = ["getOrderMainData.ashx", "getSellMainData.ashx", "getOOSRecordList.ashx", "getSellMainData.ashx", "SAMOrderManagerCell", "SAMOrderManagerCell"]
    
    ///当前数据的页码数组
    fileprivate var requestSearchPageIndexs = [0, 0, 0, 0, 0, 0]
    ///一次数据请求获取的数据最大条数
    fileprivate let requestSearchPageSize = 15
    
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
    
    ///导航栏指示器
    fileprivate lazy var navIndicaterView: SAMComOperationIndicaterView? = {
        let navBar = self.navigationController!.navigationBar
        let indicaterView = SAMComOperationIndicaterView.instance()
        indicaterView.frame = navBar.bounds
        navBar.addSubview(indicaterView)
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
    
    ///第一响应者
    fileprivate var firstTF: UITextField?
    
    ///条件搜索请求URLStr
    fileprivate let orderInfoRequestURLStr = "getOrderMainData.ashx"
    ///条件搜索参数字典
    fileprivate var orderInfoRequestParameters: [String: AnyObject]?
    
    ///当前数据的页码
    fileprivate var requestSearchPageIndex = 1
    
    ///数据模型数组
    fileprivate let InfoModels = NSMutableArray()
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchConView: UIView!
    @IBOutlet weak var beginDateTF: SAMLoginTextField!
    @IBOutlet weak var endDateTF: SAMLoginTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var customerSearchTF: SAMLoginTextField!
    @IBOutlet weak var stateSearchTF: SAMLoginTextField!
    @IBOutlet weak var searchBtn: UIButton!
    
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
        let offsetX = scrollView.contentOffset.x
        if (offsetX < ScreenW * 5) && (offsetX > 0) && !navIndicaterView!.didClicked {
            navIndicaterView!.setIndicaterViewLeftDistance(dicstance: offsetX / 6)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //记录当前位置
        if scrollView == comScrollView {
            currentColIndex = Int(scrollView.contentOffset.x) / Int(ScreenW)
        }
        if currentColIndex == 3 {
            stateSearchTF.isEnabled = false
        }else {
            stateSearchTF.isEnabled = true
        }
        //检查navIndicaterView当前选中按钮
        navIndicaterView?.checkSelectedIndex(shouldSelectedIndex: currentColIndex)
        
        //刷新stateSearchPickerView
        stateSearchPickerView.reloadAllComponents()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
        case self.orderManageColView:
            break
        case self.forSaleColView:
            break
        case self.owedColView:
            break
        case self.saleHistoryColView:
            saleHistoryColViewdidSelected(indexpath: indexPath)
        case self.customerRankColView:
            break
        case self.productRankColView:
            break
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
                print(self.orderManageModels.count)
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[0], for: indexPath) as! SAMOrderManagerCell
            let model = orderManageModels[indexPath.row] as! SAMOrderModel
            cell.orderInfoModel = model
            return cell
            
        case self.forSaleColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[1], for: indexPath) as! SAMOrderManagerCell
            let model = forSaleModels[indexPath.row] as! SAMOrderModel
            cell.orderInfoModel = model
            return cell
            
        case self.owedColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[2], for: indexPath) as! SAMOwedCell
            let model = owedModels[indexPath.row] as! SAMOwedInfoModel
            cell.owedInfoModel = model
            return cell
            
        case self.saleHistoryColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[3], for: indexPath) as! SAMSaleInfoCell
            let model = saleHistoryModels[indexPath.row] as! SAMSaleOrderInfoModel
            cell.saleOrderInfoModel = model
            return cell
            
        case self.customerRankColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[4], for: indexPath) as! SAMOrderManagerCell
            let model = customerRankModels[indexPath.row] as! SAMOrderModel
            cell.orderInfoModel = model
            return cell
            
        case self.productRankColView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rigisterReuseNames[5], for: indexPath) as! SAMOrderManagerCell
            let model = productRankModels[indexPath.row] as! SAMOrderModel
            cell.orderInfoModel = model
            return cell
            
        default :
            return UICollectionViewCell()
        }
    }
}

//MARK: - 导航栏指示器代理
extension SAMComOperationController: SAMComOperationIndicaterViewDelegate {
    func comOperationIndicaterViewDidSelected(index: Int) {
        
        comScrollView.setContentOffset(CGPoint(x: ScreenW * CGFloat(index), y: 0), animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension SAMComOperationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
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
        
        return searchStates[currentColIndex].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return searchStates[currentColIndex][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        stateSearchTF.text = searchStates[currentColIndex][row]
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
                let _ = SAMHUD.showMessage("没有符合条件的客户", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                print(arr.count)
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
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreOrderModels() {
        
        //结束下拉刷新
        orderManageColView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndexs[0])
        orderRequestParameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[0], parameters: orderInfoRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
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
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 待售布匹请求方法
extension SAMComOperationController {
    
    func loadNewforSaleModels() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndex = 1
        
        
        let employeeID = SAMUserAuth.shareUser()!.employeeID!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndex)
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let statusStr = searchConIn(textField: stateSearchTF)
        let parameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "status": statusStr]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[currentColIndex], parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.InfoModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("没有符合条件的订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndex += 1
                    self!.orderInfoRequestParameters = parameters as [String : AnyObject]?
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.collectionView.mj_header.endRefreshing()
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self!.collectionView.reloadData()
                }, completion: { (_) in
                })
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.collectionView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreforSaleModels() {
        
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndex)
        orderInfoRequestParameters!["pageIndex"] = index as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(orderInfoRequestURLStr, parameters: orderInfoRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndex += 1
                    
                    //处理下拉
                    self!.collectionView.mj_footer.endRefreshing()
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.collectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.collectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 缺货登记请求方法
extension SAMComOperationController {
    
    func loadNewOwedModels() {
        
        //结束下拉刷新
        owedColView.mj_footer.endRefreshing()
        
        //创建请求参数
        let userID = SAMUserAuth.shareUser()!.id!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let iState = searchConIn(textField: stateSearchTF)
        oweRequestParameters = ["userID": userID, "CGUnitName": CGUnitName, "startDate": startDate, "endDate": endDate, "iState": iState]
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
                let _ = SAMHUD.showMessage("暂无数据", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOwedInfoModel.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.owedModels.addObjects(from: arr as [AnyObject])
                self!.owedColView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            //回主线程，刷新数据
            DispatchQueue.main.async(execute: {
                self!.owedColView.mj_header.endRefreshing()
                self!.owedColView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.owedColView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    func loadMoreOwedModels() {}
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
                
                let _ = SAMHUD.showMessage("没有符合条件的订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMSaleOrderInfoModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.saleHistoryColView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
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
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
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
                let _ = SAMHUD.showMessage("没有更多订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
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
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 客户排行请求方法
extension SAMComOperationController {
    
    //加载数据
    func loadNewCustomerRankModels() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndex = 1
        
        
        let employeeID = SAMUserAuth.shareUser()!.employeeID!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndex)
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let statusStr = searchConIn(textField: stateSearchTF)
        let parameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "status": statusStr]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[currentColIndex], parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.InfoModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有符合条件的订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndex += 1
                    self!.orderInfoRequestParameters = parameters as [String : AnyObject]?
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.collectionView.mj_header.endRefreshing()
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self!.collectionView.reloadData()
                }, completion: { (_) in
                })
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.collectionView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //加载更多数据
    func loadMoreCustomerRankModels() {
        
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndex)
        orderInfoRequestParameters!["pageIndex"] = index as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(orderInfoRequestURLStr, parameters: orderInfoRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndex += 1
                    
                    //处理下拉
                    self!.collectionView.mj_footer.endRefreshing()
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.collectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.collectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 产品排行请求方法
extension SAMComOperationController {
    
    //加载数据
    func loadNewProductRankModels() {
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //创建请求参数
        requestSearchPageIndex = 1
        
        
        let employeeID = SAMUserAuth.shareUser()!.employeeID!
        let CGUnitName = searchConIn(textField: customerSearchTF)
        let pageSize = String(format: "%d", requestSearchPageSize)
        let pageIndex = String(format: "%d", requestSearchPageIndex)
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let statusStr = searchConIn(textField: stateSearchTF)
        let parameters = ["employeeID": employeeID, "CGUnitName": CGUnitName, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate, "status": statusStr]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStrs[currentColIndex], parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.InfoModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有符合条件的订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self!.requestSearchPageSize { //设置footer状态，提示用户没有更多信息
                    
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self!.requestSearchPageIndex += 1
                    self!.orderInfoRequestParameters = parameters as [String : AnyObject]?
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
            }
            
            //回主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.collectionView.mj_header.endRefreshing()
                
                UIView.animate(withDuration: 0, animations: {
                    
                    //刷新数据
                    self!.collectionView.reloadData()
                }, completion: { (_) in
                })
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.collectionView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //加载更多数据
    func loadMoreProductRankModels() {
        
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", requestSearchPageIndex)
        orderInfoRequestParameters!["pageIndex"] = index as AnyObject?
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(orderInfoRequestURLStr, parameters: orderInfoRequestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多订单", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMOrderModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self!.requestSearchPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestSearchPageIndex += 1
                    
                    //处理下拉
                    self!.collectionView.mj_footer.endRefreshing()
                }
                self!.InfoModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.collectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.collectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
}

//MARK: - 控制器里所有collectionView用到的FlowLayout
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

//MARK: - 各个colectionView点击事件处理
extension SAMComOperationController {

    //订单管理
    fileprivate func orderManageColViewdidSelected(indexpath: IndexPath) {
    
    }
    //待售布匹
    fileprivate func forSaleColViewdidSelected(indexpath: IndexPath) {
        
    }
    //缺货登记
    fileprivate func owedColViewdidSelected(indexpath: IndexPath) {
        
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
                let _ = SAMHUD.showMessage("没有数据", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }) {
            
            DispatchQueue.main.async(execute: {
                //隐藏hud
                hud!.hide(true)
                
                //提示用户
                let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }

    }
    //客户排行
    fileprivate func customerRankColViewdidSelected(indexpath: IndexPath) {
        
    }
    //产品排行
    fileprivate func productRankColViewdidSelected(indexpath: IndexPath) {
        
    }
}

