//
//  SAMCustomerViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJExtension
import MJRefresh

///控制器类型
enum CustomerControllerType{
    case Normal //正常控制器
    case OrderBuild //创建订单时候调用控制器
}

///CustomerCell重用标识符
private let SAMCustomerCellReuseIdentifier = "SAMCustomerCellReuseIdentifier"
///cell正常背景色
private let SAMCustomerCellNormalColor = UIColor.white
///cell正常size
private let SAMCustomerCellNormalSize = CGSize(width: ScreenW, height: 91)
///cell选中背景色
private let SAMCustomerCellSelectedColor = customBlueColor
///cell选中size
private let SAMCustomerCellSelectedSize = CGSize(width: ScreenW, height: 160)

///回访Cell重用标识符
private let SAMCustomerVistSearchCellReuseIdentifier = "SAMCustomerVistSearchCellReuseIdentifier"

class SAMCustomerViewController: UIViewController {
    
    //MARK: 对外提供的类工厂方法，同时设置控制器类型
    class func instance(controllerType: CustomerControllerType) -> SAMCustomerViewController {
        let vc = SAMCustomerViewController()
        vc.controllerType = controllerType
        return vc
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
    }
    
    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        //设置导航标题
        switch controllerType {
        case .Normal:
            let titleButton = UIButton(type: .custom)
            titleButton.setTitle("客户管理", for: .normal)
            titleButton.setTitleColor(UIColor(red: 60 / 255.0, green: 60 / 255.0, blue: 60 / 255.0, alpha: 1.0), for: .normal)
            titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            titleButton.sizeToFit()
            titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0)
            navigationItem.titleView = titleButton
        case .OrderBuild:
            navigationItem.title = "选择客户"
        }
        
        //检查查询权限
        if !hasCXAuth {
            view.addSubview(CXAuthView)
            return
        }
        
        //设置hudView
        setupHudView()
        
        //设置文本框
        setupTextField()
        
        //设置客户搜索控件
        setupCustomerSearchView()
        
        //设置时间按钮控件
        setupDateButtonView()
        
        //设置导航栏添加客户按钮
        setupNormalNavButtons()
        
        //设置订单新建跳转过来的 客户选择按钮
        setupOrderBuildCustomerChooseBtn()
        
        //初始化collectionView
        setupCollectionTableView()
    }
    
    ///设置HUDView
    fileprivate func setupHudView() {
        //设置hudView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMCustomerViewController.hudViewDidClick))
        hudView.addGestureRecognizer(tapGesture)
        
        // 设置顶部距离
        hudViewTopDistance.constant = customerSearchView.bounds.height
    }
    
    ///设置文本框
    fileprivate func setupTextField() {
        //设置文本框
        let arr = NSArray(array: [beginDateTF, endDateTF, customerSearchTF, vistCustomerSearchTF])
        arr.enumerateObjects({ (obj, _, _) in
            let textField = obj as! UITextField
            
            //设置代理
            textField.delegate = self
            
            //设置 beginDateTF, endDateTF 的 inputView
            if (textField == self.beginDateTF) || (textField == self.endDateTF) {
                
                //设置inputView
                textField.inputView = datePicker
                
                //监听事件
                textField.addTarget(self, action: #selector(SAMCustomerViewController.textFieldidChangeText), for: .editingChanged)
            }
        })
    }
    
    ///设置普通搜索框
    fileprivate func setupCustomerSearchView() {
        
        //设置搜索按钮外观
        customerSearchBtn.layer.borderWidth = 1
        customerSearchBtn.layer.cornerRadius = 5
        customerSearchBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        //设置searchTF的放大镜
        let imageView = UIImageView(image: UIImage(named: "search_mirro"))
        customerSearchTF.leftView = imageView
        customerSearchTF.leftViewMode = UITextFieldViewMode.always
    }
    
    ///设置dateButtonView时间便捷选择控件
    fileprivate func setupDateButtonView() {
        
        //如果是新建订单跳转过来，直接隐藏时间按钮
        if controllerType == CustomerControllerType.OrderBuild {
            dateBtnView.isHidden = true
            return
        }
        
        //设置dateBtnView的锚点, transform
        dateBtnView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        dateBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        dateBtnView.alpha = 0.00001
        //设置时间按钮控件边框
        dateBtnContentView.layer.cornerRadius = 5
    }
    
    ///设置添加导航栏添加客户按钮
    fileprivate func setupNormalNavButtons() {
    
        //如果不是正常控制器类型，返回
        if controllerType != .Normal {
            return
        }
        
        var addItem: UIBarButtonItem?
        var changeItem: UIBarButtonItem?
        
        //检查新增权限，而且有查询权限才设置该按钮
        if hasXZAuth {
            let addBtn = UIButton(type: .custom)
            addBtn.setBackgroundImage(UIImage(named: "customerAddButtton"), for: UIControlState())
            addBtn.addTarget(self, action: #selector(SAMCustomerViewController.addCustomer), for: .touchUpInside)
            addBtn.sizeToFit()
            
            addItem = UIBarButtonItem(customView: addBtn)
        }
        
        //检查回访查询权限，而且有查询权限才设置该按钮
        if hasHFCXAuth {
            changeItem = UIBarButtonItem(customView: changeSearchStyleButton)
        }
        
        var navRightItems = [UIBarButtonItem]()
        
        if addItem != nil {
            navRightItems.append(addItem!)
        }
        if changeItem != nil {
            navRightItems.append(changeItem!)
        }
        
        //查询归属按钮
        navRightItems.append(UIBarButtonItem(customView: customerBelongButton))
        
        navigationItem.rightBarButtonItems = navRightItems
    }
    
    ///设置订单新建跳转过来的 选择按钮
    fileprivate func setupOrderBuildCustomerChooseBtn() {
    
        //如果是新建订单类型，设置完成按钮
        if controllerType == .OrderBuild {
            let addBtn = UIButton(type: .custom)
            addBtn.setTitle("选择", for: .normal)
            
            addBtn.setTitleColor(UIColor(red: 75 / 255.0, green: 75 / 255.0, blue: 75 / 255.0, alpha: 1.0), for: .normal)
            addBtn.addTarget(self, action: #selector(SAMCustomerViewController.chooseCustomer), for: .touchUpInside)
            addBtn.sizeToFit()
            
            let chooseItem = UIBarButtonItem(customView: addBtn)
            navigationItem.rightBarButtonItem = chooseItem
        }
    }
    
    //设置collectionView
    fileprivate func setupCollectionTableView() {
        
        //检查查询权限
        if !hasCXAuth {
            return
        }
        
        customerCollectionView.showsVerticalScrollIndicator = false
        
        //设置代理数据源
        customerCollectionView.delegate = self
        customerCollectionView.dataSource = self
        
        //注册cell
        customerCollectionView.register(UINib(nibName: "SAMCustomerCollectionCell", bundle: nil), forCellWithReuseIdentifier: SAMCustomerCellReuseIdentifier)
        
        //设置上拉下拉
        customerCollectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadNewCustomerInfo))
        customerCollectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadMoreCustomerInfo))
        //没有数据自动隐藏footer
        customerCollectionView.mj_footer.isAutomaticallyHidden = true
        
        //检查回访查询权限
        if !hasHFCXAuth {
            return
        }
        
        vistTableView.showsVerticalScrollIndicator = false
        
        //设置代理数据源
        vistTableView.delegate = self
        vistTableView.dataSource = self
        
        vistTableView.estimatedRowHeight = 100
        vistTableView.rowHeight = UITableViewAutomaticDimension
        
        //注册cell
        vistTableView.register(UINib(nibName: "SAMCustomerVistSearchCell", bundle: nil), forCellReuseIdentifier: SAMCustomerVistSearchCellReuseIdentifier)
        
        //设置上拉下拉
        vistTableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadVistSearchInfo))
    }
    
    //MARK: - 加载新数据
    func loadNewCustomerInfo(){
        //结束下拉刷新
        customerCollectionView.mj_footer.endRefreshing()
        
        //恢复形变CELL
        if self.selectedCustomerCell != nil {
            self.selectedCustomerCell?.rightSwipeCell()
        }
        
        //获取搜索条件
        customerLastSearchStr = searchCon(textField: customerSearchTF)
        
        //创建请求参数
        pageIndex = 1
        var id = SAMUserAuth.shareUser()?.employeeID
        let index = String(format: "%d", pageIndex)
        let size = String(format: "%d", pageSize)
        
        if isSearchCustomerBelong { //客户归属搜索
            id = "-1"
            customerCollectionView.allowsSelection = false
        }else {
            customerCollectionView.allowsSelection = true
        }
        
        let parameters = ["employeeID": id, "con": customerLastSearchStr, "pageSize": size, "pageIndex": index]
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getCustomerList.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            //清除数据
            self!.selectedIndexPath = nil
            self!.selectedCustomerCell = nil
            self!.isSearchCustomerBelong = false
            SAMCustomerModel.modelArr().removeAllObjects()

            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: String]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("暂无客户", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else { //有数据模型
                let arr = (SAMCustomerModel.mj_objectArray(withKeyValuesArray: dictArr)!)
                SAMCustomerModel.modelArr().addObjects(from: arr as [AnyObject])
                
                if SAMCustomerModel.modelArr().count < self!.pageSize { //设置footer状态，提示用户没有更多信息
                    self!.customerCollectionView.mj_footer.endRefreshingWithNoMoreData()
                    
                }else { //设置pageIndex，可能还有更多信息
                    self!.pageIndex += 1
                }
            }
            
            //回主线程处理UI事件
            DispatchQueue.main.async(execute: {
                //结束上拉
                self!.customerCollectionView.mj_header.endRefreshing()
                self!.customerCollectionView.reloadData()
            })
            
            }) {[weak self] (Task, Error) in
                //处理上拉
                self!.customerCollectionView.mj_header.endRefreshing()
                self!.isSearchCustomerBelong = false
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 加载搜索回访数据
    func loadVistSearchInfo(){
        
        //判断搜索条件，如果没有搜索条件，提示用户并返回
        let searchStr = searchCon(textField: vistCustomerSearchTF)
        
        //创建请求参数
        let userID = SAMUserAuth.shareUser()?.id!
        let CGUnitName = searchStr
        let startDate = beginDateTF.text!
        let endDate = endDateTF.text!
        let patameters = ["userID": userID, "CGUnitName": CGUnitName, "startDate": startDate, "endDate": endDate]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getCGUnitFollowList.ashx", parameters: patameters, progress: nil, success: {[weak self] (Task, json) in

            //清空原先数据
            SAMCustomerVistModel.modelArr().removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("暂无回访", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMCustomerVistModel.mj_objectArray(withKeyValuesArray: dictArr)!
                SAMCustomerVistModel.modelArr().addObjects(from: arr as [AnyObject])
            }
            
            //结束下拉，刷新数据
            DispatchQueue.main.async(execute: {
                self!.vistTableView.mj_header.endRefreshing()
                self!.vistTableView.reloadData()
            })
            
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.vistTableView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 获取搜索字符串
    func searchCon(textField: UITextField) -> String {
        let searchStr = textField.text?.lxm_stringByTrimmingWhitespace()
        if searchStr == "" { //没有内容
            return ""
        }
        return searchStr!.components(separatedBy: " ")[0]
    }
    
    //MARK: - 加载更多数据
    func loadMoreCustomerInfo() {
        //结束下拉刷新
        customerCollectionView.mj_header.endRefreshing()
        
        //恢复形变CELL
        if self.selectedCustomerCell != nil {
            self.selectedCustomerCell?.rightSwipeCell()
        }
        
        //创建请求参数
        let id = SAMUserAuth.shareUser()?.employeeID
        let index = String(format: "%d", pageIndex)
        let size = String(format: "%d", pageSize)
        let parameters = ["employeeID": id!, "con": customerLastSearchStr, "pageSize": size, "pageIndex": index]
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getCustomerList.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            if dictArr?.count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多客户", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                //设置footer
                self!.customerCollectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMCustomerModel.mj_objectArray(withKeyValuesArray: dictArr)!
                SAMCustomerModel.modelArr().addObjects(from: arr as [AnyObject])
                
                if arr.count < self!.pageSize {
                    
                    //设置footer状态
                    self!.customerCollectionView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    
                    //设置pageIndex
                    self!.pageIndex += 1
                    
                    //处理下拉
                    self!.customerCollectionView.mj_footer.endRefreshing()
                }
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.customerCollectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理下拉
            self!.customerCollectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 用户点击事件
    ///正常查询下搜索按钮点击
    @IBAction func customerSearchBtnClick(_ sender: UIButton) {
        
        //结束搜索框编辑状态
        endFirstTextFieldEditing()
        
        //启动下拉刷新
        customerCollectionView.mj_header.beginRefreshing()
    }
    
    ///正常查询下添加客户按钮点击
    func addCustomer() {
        hudViewDidClick()
        let customerAddVC = SAMCustomerAddController.instance(customerModel: nil, type: .addCustomer)
        customerAddVC.transitioningDelegate = self
        customerAddVC.modalPresentationStyle = UIModalPresentationStyle.custom
        //展示控制器
        present(customerAddVC, animated: true, completion: nil)
    }
    
    ///正常客户查询 和 回访查询状态切换按钮监听事件
    func changeSearchStyle() {
        hudViewDidClick()
        changeSearchStyleButton.isSelected = !changeSearchStyleButton.isSelected
        
        if changeSearchStyleButton.isSelected { //转换到回访搜索界面
            tabBarController!.view.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.contentViewLeadingDistance.constant = -ScreenW
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
                self.tabBarController!.view.isUserInteractionEnabled = true
                self.hudViewTopDistance.constant = self.vistSearchView.bounds.height
                self.navigationItem.title = "回访查询"
            })
        }else { //转换到正常搜索界面
            
            tabBarController!.view.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.contentViewLeadingDistance.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
                self.tabBarController!.view.isUserInteractionEnabled = true
                self.hudViewTopDistance.constant = self.customerSearchView.bounds.height
                self.navigationItem.title = "客户管理"
            })
        }
    }
    
    ///客户归属搜索按钮点击事件
    func customerBelongBtnClick() {
        isSearchCustomerBelong = true
        
        //结束搜索框编辑状态
        endFirstTextFieldEditing()
        //启动下拉刷新
        customerCollectionView.mj_header.beginRefreshing()
    }
    
    ///当前为新建订单类型，选择客户按钮点击
    func chooseCustomer() {
        
        if selectedIndexPath == nil { //如果当前没有选择的客户，提示用户，并返回
            let _ = SAMHUD.showMessage("请选择客户", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        let model = SAMCustomerModel.modelArr()[(selectedIndexPath!.row)] as! SAMCustomerModel
        
        //携带数据发出通知
        NotificationCenter.default.post(name: NSNotification.Name.init(SAMCustomerViewControllerDidSelectCustomerNotification), object: nil, userInfo: ["customerModel": model])
        
        navigationController!.popViewController(animated: true)
    }
    
    ///点击时间下拉按钮
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
    
    ///回访搜索按钮
    @IBAction func vistSearchBtnClick(_ sender: UIButton) {
        vistTableView.mj_header.beginRefreshing()
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
            visitSearchBtn.isEnabled = true
        }else {
            visitSearchBtn.isEnabled = false
        }
    }
    
    //MARK: - 属性
    ///控制器类型
    fileprivate var controllerType: CustomerControllerType = .Normal
    
    ///一次数据请求获取的数据最大条数
    fileprivate let pageSize = 15
    ///当前数据的页码
    fileprivate var pageIndex = 1
    ///最近一次查询的参数
    fileprivate var customerLastSearchStr = ""
    
    ///当前选中IndexPath
    fileprivate var selectedIndexPath : IndexPath?
    fileprivate var selectedCustomerCell: SAMCustomerCollectionCell?
    
    ///第一响应者
    fileprivate var firstTF: UITextField?
    
    ///当前是否是搜索客户归属
    fileprivate var isSearchCustomerBelong = false
    
    ///查询权限
    fileprivate lazy var hasCXAuth: Bool = SAMUserAuth.checkAuth(["KH_CX_APP"])
    ///新增权限
    fileprivate lazy var hasXZAuth: Bool = SAMUserAuth.checkAuth(["KH_XZ_APP"])
    ///修改权限
    fileprivate lazy var hasXGAuth: Bool = SAMUserAuth.checkAuth(["KH_XG_APP"])
    ///禁用权限
    fileprivate lazy var hasJYAuth: Bool = SAMUserAuth.checkAuth(["KH_JY_APP"])
    
    ///回访查询权限
    fileprivate lazy var hasHFCXAuth: Bool = SAMUserAuth.checkAuth(["HF_CX_APP"])
    
    ///查询权限遮挡View
    fileprivate lazy var CXAuthView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        let imageView = UIImageView(image: UIImage(named: "cxAuthImage"))
        view.addSubview(imageView)
        imageView.center = CGPoint(x: ScreenW * 0.5, y: ScreenH * 0.5)
        return view
    }()
    
    ///时间选择器
    fileprivate lazy var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(SAMComOperationController.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    ///导航栏切换搜索状态按钮
    fileprivate lazy var changeSearchStyleButton: UIButton = {
        let changeBtn = UIButton(type: .custom)
        changeBtn.setBackgroundImage(UIImage(named: "customerChangeStyle_normal"), for: .normal)
        changeBtn.setBackgroundImage(UIImage(named: "customerChangeStyle_selected"), for: .selected)
        changeBtn.addTarget(self, action: #selector(SAMCustomerViewController.changeSearchStyle), for: .touchUpInside)
        changeBtn.sizeToFit()
        return changeBtn
    }()
    
    ///导航栏客户归属搜索按钮
    fileprivate lazy var customerBelongButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("归属", for: .normal)
        btn.setTitleColor(UIColor(red: 65 / 255.0, green: 65 / 255.0, blue: 65 / 255.0, alpha: 1.0), for: .normal)
        btn.addTarget(self, action: #selector(SAMCustomerViewController.customerBelongBtnClick), for: .touchUpInside)
        btn.sizeToFit()
        return btn
    }()
    
    //MARK: - xib链接控件
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var customerSearchView: UIView!
    @IBOutlet weak var customerSearchTF: SAMLoginTextField!
    @IBOutlet weak var customerSearchBtn: UIButton!
    @IBOutlet weak var customerCollectionView: UICollectionView!
    
    @IBOutlet weak var vistSearchView: UIView!
    @IBOutlet weak var vistCustomerSearchTF: SAMLoginTextField!
    @IBOutlet weak var beginDateTF: SAMLoginTextField!
    @IBOutlet weak var endDateTF: SAMLoginTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var visitSearchBtn: UIButton!
    @IBOutlet weak var vistTableView: UITableView!
    
    @IBOutlet weak var dateBtnView: UIView!
    @IBOutlet weak var dateBtnContentView: UIView!
    
    @IBOutlet weak var hudView: UIView!

    @IBOutlet weak var hudViewTopDistance: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeadingDistance: NSLayoutConstraint!
    
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
        view = Bundle.main.loadNibNamed("SAMCustomerViewController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - 数据源CollectionViewDataSource
extension SAMCustomerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SAMCustomerModel.modelArr().count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMCustomerCellReuseIdentifier, for: indexPath) as! SAMCustomerCollectionCell
        //设置样式
        if indexPath == selectedIndexPath {
            cell.containterView.backgroundColor = SAMCustomerCellSelectedColor
        } else {
            cell.containterView.backgroundColor = SAMCustomerCellNormalColor
        }
        //传递数据模型
        let model = SAMCustomerModel.modelArr()[indexPath.row] as! SAMCustomerModel
        cell.customerModel = model
        cell.delegate = self
        return cell
    }
}

extension SAMCustomerViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        //结束搜索框编辑状态
        endFirstTextFieldEditing()
        
         //在客户界面，而且当前有选中的Cell
        if (contentViewLeadingDistance.constant == 0) && (selectedCustomerCell != nil) {
            self.selectedCustomerCell?.rightSwipeCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //结束搜索框编辑状态
        endFirstTextFieldEditing()
        
        selectedCustomerCell = collectionView.cellForItem(at: indexPath) as? SAMCustomerCollectionCell
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            //清空记录
            selectedIndexPath = nil
            
            //执行动画
            selectCellAnimation(nil, willNorCell: selectedCustomerCell)
            
            //清空记录
            selectedCustomerCell = nil
        } else { //选中了其他的CELL
            
            var willNorCell: SAMCustomerCollectionCell?
            
            if selectedIndexPath != nil { //没有选中其他CELL
                willNorCell = collectionView.cellForItem(at: selectedIndexPath!) as? SAMCustomerCollectionCell
            }
            
            //记录数据
            selectedIndexPath = indexPath
            
            //执行动画
            selectCellAnimation(selectedCustomerCell, willNorCell: willNorCell)
        }
    }
    
    ///点击了某个cell时执行的动画 点击客户cell的时候调用
    fileprivate func selectCellAnimation(_ willSelCell: SAMCustomerCollectionCell?, willNorCell: SAMCustomerCollectionCell?) {
        
        willSelCell?.showMoreInfo()
        
        UIView.animate(withDuration: 0.2, animations: { 
                //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
                self.customerCollectionView.performBatchUpdates({
                }) { (finished) in
                }
                
                //设置背景颜色
                willSelCell?.containterView.backgroundColor = SAMCustomerCellSelectedColor
                willNorCell?.containterView.backgroundColor = SAMCustomerCellNormalColor
                
                //恢复左滑形变
                willNorCell?.containterView.transform = CGAffineTransform.identity
                
                //一个神奇的方法
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
                //如果点击了最下面一个cell，则滚至最底部
                if self.selectedIndexPath?.row == (SAMCustomerModel.modelArr().count - 1) {
                    self.customerCollectionView.scrollToItem(at: self.selectedIndexPath!, at: .bottom, animated: true)
                }
        }) 
    }
}

//MARK: - vistTableView数据源
extension SAMCustomerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SAMCustomerVistModel.modelArr().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMCustomerVistSearchCellReuseIdentifier) as! SAMCustomerVistSearchCell
        //传递数据模型
        let model = SAMCustomerVistModel.modelArr()[indexPath.row] as! SAMCustomerVistModel
        cell.vistModel = model
        
        return cell
    }
}

extension SAMCustomerViewController: UITableViewDelegate {
}

//MARK: - CollectionView布局代理
extension SAMCustomerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == selectedIndexPath {
            return SAMCustomerCellSelectedSize
        }
        return SAMCustomerCellNormalSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - UITextFieldDelegate
extension SAMCustomerViewController: UITextFieldDelegate {
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


//MARK: - UIViewControllerTransitioningDelegate
extension SAMCustomerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}

//MARK: - SAMCustomerCollectionCellDelegate
extension SAMCustomerViewController: SAMCustomerCollectionCellDelegate {
    func customerCellDidClickVisitShow() {
        selectedCustomerCell!.rightSwipeCell()
    }
    func customerCellDidClickVisitAdd() {
        selectedCustomerCell!.rightSwipeCell()
        //获取选中的模型，并传递
        let customerModel = SAMCustomerModel.modelArr()[selectedIndexPath!.row] as! SAMCustomerModel
        let customerAddVC = SAMCustomerAddController.instance(customerModel: customerModel, type: .addVist)
        customerAddVC.transitioningDelegate = self
        customerAddVC.modalPresentationStyle = UIModalPresentationStyle.custom
        
        //展示控制器
        present(customerAddVC, animated: true, completion: nil)
    }
    func customerCellDidClickEdit() {
        selectedCustomerCell!.rightSwipeCell()
        
        //获取选中的模型，并传递
        let customerModel = SAMCustomerModel.modelArr()[selectedIndexPath!.row] as! SAMCustomerModel
        let customerAddVC = SAMCustomerAddController.instance(customerModel: customerModel, type: .eidtCustomer)
        customerAddVC.transitioningDelegate = self
        customerAddVC.modalPresentationStyle = UIModalPresentationStyle.custom
        
        //展示控制器
        present(customerAddVC, animated: true, completion: nil)
    }
    func customerCellDidClickPhone() {
        
        selectedCustomerCell!.rightSwipeCell()
        
        //获取选中的模型，对手机号码进行筛选
        let customerModel = SAMCustomerModel.modelArr()[selectedIndexPath!.row] as! SAMCustomerModel
        let phoneStr = customerModel.mobilePhone
        if phoneStr == "" {
            let _ = SAMHUD.showMessage("没有手机号码", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }else if !(phoneStr.lxm_stringisWholeNumber()) {
            let _ = SAMHUD.showMessage("非法电话", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //拨打电话
        let phoneURLStr = String(format: "tel://%@", phoneStr)
        let titleStr = String(format: "呼叫 %@", selectedCustomerCell!.customerLabel.text!)
        let messageStr = selectedCustomerCell!.phoneLabel.text!
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .destructive) { (_) in
            UIApplication.shared.openURL(URL(string: phoneURLStr)!)
            })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { (_) in
            })
        
        present(alert, animated: true, completion: nil)
    }
}

