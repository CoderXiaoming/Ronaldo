//
//  SAMRankDetailController.swift
//  SaleManager
//
//  Created by apple on 16/12/31.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJRefresh

class SAMRankDetailController: UIViewController {

    ///对外提供的类工厂方法
    class func instance(customerRankModel: SAMCustomerRankModel?, productRankModel: SAMProductRankModel?) -> SAMRankDetailController {
        let vc = SAMRankDetailController()
        if customerRankModel != nil {
            vc.customerRankModel = customerRankModel
            vc.requestURLStr = "getCustomerProductStatic.ashx"
            
        }else {
            vc.productRankModel = productRankModel
            vc.requestURLStr = "getSellStaticProductDetail.ashx"
        }
        
        return vc
    }
    
    ///对外提供的加载用户排行数据的方法
    func willSearchRankDetailInfo(startDateStr: String, endDateStr: String, success: @escaping ()->(), noData: @escaping ()->(), defeat: @escaping ()->()) {
        
        //赋值
        beginDate = startDateStr
        endDate = endDateStr
        
        //创建请求参数
        if customerRankModel != nil { //客户排行请求
            let CGUnitID = customerRankModel!.id
            let userID = ""
            requestParameters = ["CGUnitID": CGUnitID, "startDate": startDateStr, "endDate": endDateStr, "userID": userID]
            
        }else { //产品排行请求
            let productID = productRankModel!.id
            let pageSize = String(format: "%d", requestPageSize)
            let pageIndex = String(format: "%d", requestPageIndex)
            requestParameters = ["productID": productID, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDateStr, "endDate": endDateStr]
        }
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStr!, parameters: requestParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.rankListModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //回主线程调用没有数据闭包
                DispatchQueue.main.async(execute: { 
                    noData()
                })
            }else { //有数据模型
                
                if self!.customerRankModel != nil { //用户排行
                    let arr = SAMCustomerRankListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                    self!.rankListModels.addObjects(from: arr as [AnyObject])
                    
                }else { //产品排行
                    let arr = SAMProductRankListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                    self!.rankListModels.addObjects(from: arr as [AnyObject])
                    if arr.count < self!.requestPageSize {
                        
                        //记录状态，没有更多数据
                        self!.hasMoreData = false
                    }else { //设置pageIndex，可能还有更多信息
                        
                        self!.requestPageIndex += 1
                        //记录状态，可能有更多数据
                        self!.hasMoreData = true
                    }
                }
                
                //回主线程，调用成功闭包
                DispatchQueue.main.async(execute: {
                    success()
                })
            }
        }) { (Task, Error) in
            //回主线程，调用成功闭包
            DispatchQueue.main.async(execute: {
                defeat()
            })
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置时间按钮控件
        setupDateButtonView()
        
        ///设置文本
        setupTextField()
        
        //设置ScrollView
        setupCollectionView()
        
        //设置其他
        setupOtherUI()
    }
        
    ///设置时间按钮控件
    fileprivate func setupDateButtonView() {
        
        //设置dateBtnView的锚点, transform
        dateBtnView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        dateBtnView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        dateBtnView.alpha = 0.00001
        
        //设置时间按钮控件边框
        dateBtnContentView.layer.cornerRadius = 5
    }
    
    ///设置文本框
    fileprivate func setupTextField() {
        
        let arr = NSArray(array: [beginDateTF, endDateTF])
        arr.enumerateObjects({ (obj, _, _) in
            let textField = obj as! UITextField
            
            //设置代理
            textField.delegate = self
            
            //设置输入控件
            textField.inputView = datePicker
        })
        
        //设置时间选择器最大时间
        datePicker!.maximumDate = Date()
    }
    
    ///设置ScrollCollectionView
    fileprivate func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMComOperationViewRankCell", bundle: nil), forCellWithReuseIdentifier: "SAMComOperationViewRankCell")
        
        //设置上拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMRankDetailController.loadNewInfo))
        
        if productRankModel != nil {
            //设置下拉
            collectionView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(SAMRankDetailController.loadMoreInfo))
            
            //判断是否还有更多数据
            if !hasMoreData {
                collectionView.mj_footer.endRefreshingWithNoMoreData()
            }
        }
    }
    
    ///设置其他UI
    fileprivate func setupOtherUI() {
        
        //设置hudView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMComOperationController.hudViewDidClick))
        hudView.addGestureRecognizer(tapGesture)
        
        //设置文本框文字
        beginDateTF.text = beginDate
        endDateTF.text = endDate
        
        //设置搜索框代理
        searchBar.delegate = self
        if customerRankModel != nil { //客户搜索
            searchBar.placeholder = String(format: "产品排行(%@)", customerRankModel!.CGUnitName)
            
        }else {
            searchBar.placeholder = String(format: "客户排行(%@)", productRankModel!.productIDName)
        }
    }
    
    //MARK: - 加载新数据
    func loadNewInfo() {
        
        //创建请求参数
        if customerRankModel != nil { //客户排行搜索
            let CGUnitID = customerRankModel!.id
            let startDate =  beginDateTF.text!
            let endDate = endDateTF.text!
            let userID = ""
            requestParameters = ["CGUnitID": CGUnitID, "startDate": startDate, "endDate": endDate, "userID": userID]
            
        }else { //产品排行搜索
            collectionView.mj_footer.endRefreshing()    
            let productID = productRankModel!.id
            let pageSize = String(format: "%d", requestPageSize)
            requestPageIndex = 1
            let pageIndex = String(format: "%d", requestPageIndex)
            let startDate =  beginDateTF.text!
            let endDate = endDateTF.text!
            requestParameters = ["productID": productID, "pageSize": pageSize, "pageIndex": pageIndex, "startDate": startDate, "endDate": endDate]
        }
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStr!, parameters: requestParameters!, progress: nil, success: {[weak self] (Task, json) in
            
            //清空原先数据
            self!.rankListModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("暂无数据", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                if self!.customerRankModel != nil { //用户排行
                    let arr = SAMCustomerRankListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                    self!.rankListModels.addObjects(from: arr as [AnyObject])
                    
                }else { //产品排行
                    let arr = SAMProductRankListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                    self!.rankListModels.addObjects(from: arr as [AnyObject])
                    if arr.count < self!.requestPageSize {
                        
                        //改变上拉刷新状态
                        self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                    }else { //设置pageIndex，可能还有更多信息
                        
                        self!.requestPageIndex += 1
                    }
                }
            }
            
            //当前是搜索状态
            if self!.isSearch {
                self!.searchBar(self!.searchBar, textDidChange: self!.searchBar.text!)
            }
            
            //回主线程，刷新数据
            DispatchQueue.main.async(execute: {
                self!.collectionView.mj_header.endRefreshing()
                self!.collectionView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.collectionView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 加载更多数据
    func loadMoreInfo() {
        
        //创建请求参数
        let pageIndex = String(format: "%d", requestPageIndex)
        requestParameters!["pageIndex"] = pageIndex
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(requestURLStr!, parameters: requestParameters, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                let _ = SAMHUD.showMessage("没有更多数据", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                self?.collectionView.mj_footer.endRefreshingWithNoMoreData()
                
            }else { //有数据模型
                let arr = SAMProductRankListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                //判断是否还有更过数据
                if arr.count < self!.requestPageSize { //没有更多数据
                    
                    //设置footer状态
                    self!.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self!.requestPageIndex += 1
                    
                    //处理下拉
                    self!.collectionView.mj_footer.endRefreshing()
                }

                self!.rankListModels.addObjects(from: arr as [AnyObject])
                
                //当前是搜索状态
                if self!.isSearch {
                    self!.searchBar(self!.searchBar, textDidChange: self!.searchBar.text!)
                }
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self!.collectionView.reloadData()
                })
            }
        }) {[weak self] (Task, Error) in
            //处理上拉
            self!.collectionView.mj_header.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
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
    @IBAction func dismissBtnClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
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
    
    //MARK: - 属性
    ///接收的用户排名的数据模型
    fileprivate var customerRankModel: SAMCustomerRankModel?
    ///接收的产品排名的数据模型
    fileprivate var productRankModel: SAMProductRankModel?
    
    ///请求的URL字符串
    fileprivate var requestURLStr: String?
    ///请求参数数组
    fileprivate var requestParameters: [String: String]?
    ///产品请求当前页码
    fileprivate var requestPageIndex = 1
    ///产品请求一页最多数量
    fileprivate var requestPageSize = 20
    
    ///是否有更多数据
    fileprivate var hasMoreData = false
    
    ///搜索开始时间
    fileprivate var beginDate: String?
    ///搜索停止时间
    fileprivate var endDate: String?
    ///第一响应者
    fileprivate var firstTF: UITextField?
    ///时间选择器
    fileprivate lazy var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(SAMRankDetailController.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    ///数据模型数组
    fileprivate let rankListModels = NSMutableArray()
    
    ///符合搜索结果模型数组
    fileprivate let searchResultModels = NSMutableArray()
    
    ///记录当前是否在搜索
    fileprivate var isSearch: Bool = false
    
    //MARK: - XIB链接属性
    @IBOutlet weak var beginDateTF: SAMLoginTextField!
    @IBOutlet weak var endDateTF: SAMLoginTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    @IBOutlet weak var dateBtnView: UIView!
    @IBOutlet weak var dateBtnContentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var hudView: UIView!
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
        view = Bundle.main.loadNibNamed("SAMRankDetailController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - UICollectionViewDelegate
extension SAMRankDetailController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endFirstTextFieldEditing()
    }
}

//MARK: - UICollectionViewDataSource
extension SAMRankDetailController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearch {
            return searchResultModels.count
        }else {
            return rankListModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SAMComOperationViewRankCell", for: indexPath) as! SAMComOperationViewRankCell
        
        if customerRankModel != nil { //客户排行搜索
            var model: SAMCustomerRankListModel?
            if isSearch {
                model = (searchResultModels[indexPath.row] as! SAMCustomerRankListModel)
            }else {
                model = (rankListModels[indexPath.row] as! SAMCustomerRankListModel)
            }
            cell.customerRankListModel = model
            
        }else { //产品排行搜索
            var model: SAMProductRankListModel?
            if isSearch {
                model = (searchResultModels[indexPath.row] as! SAMProductRankListModel)
            }else {
                model = (rankListModels[indexPath.row] as! SAMProductRankListModel)
            }
            cell.productRankListModel = model
        }
        
        return cell
    }
}

//MARK: - collectionView布局代理
extension SAMRankDetailController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: ScreenW, height: 55)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - UITextFieldDelegate
extension SAMRankDetailController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //停止滚动
        collectionView.setContentOffset(collectionView.contentOffset, animated: true)
        
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

//MARK: - 搜索框代理UISearchBarDelegate
extension SAMRankDetailController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //停止滚动
        collectionView!.setContentOffset(collectionView!.contentOffset, animated: true)
        
        //调用方法
        hudViewDidClick()
        
        //显示取消按钮
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //清空搜索结果数组,并赋值
        searchResultModels.removeAllObjects()
        searchResultModels.addObjects(from: rankListModels as [AnyObject])
        
        //获取搜索字符串
        let searchStr = NSString(string: searchText.lxm_stringByTrimmingWhitespace()!)
        
        if searchStr.length > 0 {
            
            //记录正在搜索
            isSearch = true
            
            //获取搜索字符串数组
            let searchItems = searchStr.components(separatedBy: " ")
            
            var andMatchPredicates = [NSPredicate]()
            
            for item in searchItems {
                
                let searchString = item as NSString
                
                //productIDName搜索谓语
                let keyPath = (customerRankModel == nil) ? "CGUnitName" : "productIDName"
                let lhs = NSExpression(forKeyPath: keyPath)
                let rhs = NSExpression(forConstantValue: searchString)
                let firstPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                let orMatchPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstPredicate])
                andMatchPredicates.append(orMatchPredicate)
            }
            
            let finalCompoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: andMatchPredicates)
            
            //存储搜索结果
            let arr = searchResultModels.filtered(using: finalCompoundPredicate)
            
            searchResultModels.removeAllObjects()
            searchResultModels.addObjects(from: arr)
        }else {
            //记录没有搜索
            isSearch = false
        }
        
        //刷新tableView
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //结束搜索框编辑状态
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        isSearch = false
        collectionView.reloadData()
    }
    
    //MARK: - 点击键盘搜索按钮调用
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
