//
//  SAMStockConditionalSearchController.swift
//  SaleManager
//
//  Created by apple on 16/11/23.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh

///搜索界面转换动画时间
private let changeSearchAnimationDuration = 0.5
///加载所有分类的链接
private let loadCategoriesURLStr = "getCategoryList.ashx"
///加载所有仓库的链接
private let loadStorehousesURLStr = "getStorehouseList.ashx"
///二维码搜索CELL重用标识符
private let SAMStockCodeCellReuseIdentifier = "SAMStockCodeCellReuseIdentifier"
///二维码CELL正常状态下SIZE
private let SAMStockCodeCellNormalSize = CGSize(width: 70, height: 90)
///二维码CELL选择状态下SIZE
private let SAMStockCodeCellSelectedSize = CGSize(width: 100, height: 120)

class SAMStockConditionalSearchController: UIViewController {
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //设置collectionView
        setupCollectionView()
        
        //设置textField的代理
        let arr = NSArray(array: [categoryTF, numberTF, storehouseTF, stockTF, searchTF])
        arr.enumerateObjectsUsingBlock { (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.delegate = self
        }
    }
    
    //MARK: - 初始化UI
    private func setupUI() {
        
        //设置圆角
        view.layer.cornerRadius = 8
        
        //设置 分类/仓库 选择器
        categoryTF.inputView = categoryPickerView
        storehouseTF.inputView = storehousePickerView
        
        //设置搜索按钮外观
        searchCodeBtn.layer.borderWidth = 1
        searchCodeBtn.layer.cornerRadius = 5
        searchCodeBtn.layer.borderColor = customBlueColor.CGColor
        
        //设置searchTF的放大镜
        let imageView = UIImageView(image: UIImage(named: "search_mirro"))
        searchTF.leftView = imageView
        searchTF.leftViewMode = UITextFieldViewMode.Always
    }
    
    //MARK: - 初始化collectionView
    private func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.registerNib(UINib(nibName: "SAMStockCodeSearchCell", bundle: nil), forCellWithReuseIdentifier: SAMStockCodeCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMStockConditionalSearchController.loadNewInfo))
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMStockConditionalSearchController.loadMoreInfo))
        //没有数据自动隐藏footer
        collectionView.mj_footer.automaticallyHidden = true
    }

    //MARK: - viewWillAppear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //清空所有文本框
        let arr = NSArray(array: [categoryTF, numberTF, storehouseTF, stockTF])
        arr.enumerateObjectsUsingBlock { (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.text = nil
        }
        
        //重置数据记录
        firstResponder = nil
        selectedStorehouseModel = nil
        selectedCategoryModel = nil
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //对分类、仓库列表进行判断
        if categories.count == 0 || storehouses.count == 0 {
            view.userInteractionEnabled = false
            let hud = SAMHUD.showMessage("网络错误，请重试", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            hud.delegate = self
        }
    }
    
    //MARK: - 记载所有分类、仓库列表
    private func loadCategoryStorehouseList() {
        
        //加载分类列表
        if categories.count == 0 {
            loadList(loadCategoriesURLStr)
        }
        
        //加载仓库列表
        if storehouses.count == 0 {
            loadList(loadStorehousesURLStr)
        }
    }
    
    //MARK: - 单独加载分类/仓库列表
    private func loadList(URLStr: String) {
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(URLStr, parameters: nil, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            
            //对请求链接进行判断
            switch URLStr {
            case loadCategoriesURLStr:
                let arr = SAMStockCategory.mj_objectArrayWithKeyValuesArray(dictArr)!
                self.categories.addObjectsFromArray(arr as [AnyObject])
            case loadStorehousesURLStr:
                let arr = SAMStockStorehouse.mj_objectArrayWithKeyValuesArray(dictArr)!
                self.storehouses.addObjectsFromArray(arr as [AnyObject])
            default :
                break
            }
        }) { (Task, Error) in
    }
    }
    
    //MARK: - 加载数据
    func loadNewInfo() {
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //判断搜索条件，如果没有搜索条件，提示用户并返回
        let searchStr = searchCon()
        if searchStr == nil {
            SAMHUD.showMessage("请输入搜索内容", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //创建请求参数
        pageIndex = 1
        let codeName = searchStr
        let index = String(format: "%d", pageIndex)
        let size = String(format: "%d", pageSize)
        let patametersNew = ["codeName": codeName!, "pageSize": size, "pageIndex": index]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(URLStr, parameters: patametersNew, progress: nil, success: { (Task, Json) in
            
            //清空原先数据
            self.stockCodeModels.removeAllObjects()
            self.selectedIndexPath = nil
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                SAMHUD.showMessage("没有该二维码", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMStockCodeModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                if arr.count < self.pageSize { //设置footer状态，提示用户没有更多信息
                    
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self.pageIndex += 1
                }
                self.parameters = patametersNew
                self.stockCodeModels.addObjectsFromArray(arr as [AnyObject])
            }
            
            //结束上拉
            self.collectionView.mj_header.endRefreshing()
            
            //刷新数据
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
        }) { (Task, Error) in
            //处理上拉
            self.collectionView.mj_header.endRefreshing()
            SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 加载更多数据
    func loadMoreInfo() {
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", pageIndex)
        parameters!["pageIndex"] = index
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(URLStr, parameters: parameters!, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            
            //判断是否有模型数据
            if count == 0 { //没有模型数据
                
                //提示用户
                SAMHUD.showMessage("没有更多二维码", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                
                //设置footer
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMStockCodeModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                
                //判断是否还有更多数据
                if arr.count < self.pageSize { //没有更多数据
                    
                    //设置footer状态
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //可能有更多数据
                    
                    //设置pageIndex
                    self.pageIndex += 1
                    
                    //处理下拉
                    self.collectionView.mj_footer.endRefreshing()
                }
                self.stockCodeModels.addObjectsFromArray(arr as [AnyObject])
                
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
    
    //MARK: - 获取搜索字符串
    func searchCon() -> String? {
        let searchStr = searchTF.text?.stringByTrimmingWhitespace()
        if searchStr == "" { //没有内容
            return nil
        }
        return searchStr?.componentsSeparatedByString(" ")[0]
    }
    
    //MARK: - 用户点击事件处理
    
    //MARK: - 点击了取消按钮
    @IBAction func cancelBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true) { 
        }
    }
    
    //MARK: - 点击了退出键盘按钮
    @IBAction func endEditingBtnClick(sender: AnyObject) {
        endFirstResponderEditing()
    }
    
    //MARK: - 点击了搜索按钮
    @IBAction func searchBtnClick(sender: AnyObject) {
        //退回编辑状态
        endFirstResponderEditing()
    }
    
    //MARK: - 点击了编号框按钮
    @IBAction func numberTFBtnClick(sender: AnyObject) {
        
        //结束编辑状态
        endFirstResponderEditing()
        
        //清空记录数据
        firstResponder = nil
        
        //转变到二维码选择界面
        UIView.animateWithDuration(changeSearchAnimationDuration, animations: {
            self.view.frame.size.height = 400
            self.conSearchView.alpha = 0.0001
            self.codeSearchView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - 二维码搜索按钮点击
    @IBAction func codeSearchBtnClick(sender: AnyObject) {
        
        //退回编辑状态
        endFirstResponderEditing()
        
        //触发下拉刷新数据
        collectionView.mj_header.beginRefreshing()
    }
    
    //MARK: - 点击了返回按钮
    @IBAction func backBtnClick(sender: AnyObject) {
        
        //退回编辑状态
        endFirstResponderEditing()
        
        //动态切换至综合搜索界面
        UIView.animateWithDuration(changeSearchAnimationDuration, animations: {
            self.view.frame.size.height = 195
            self.conSearchView.alpha = 1
            self.codeSearchView.alpha = 0.0001
            self.view.layoutIfNeeded()
        })
    }
    
    
    //MARK: - 结束当前textField编辑状态
    func endFirstResponderEditing() {
        if firstResponder != nil {
            firstResponder?.resignFirstResponder()
        }
    }
    
    //MARK: - 懒加载集合
    //分类模型数组
    private lazy var categories = NSMutableArray()
    //仓库模型数组
    private lazy var storehouses = NSMutableArray()
    //当前选中的分类模型
    private var selectedCategoryModel: SAMStockCategory?
    //当前选中的仓库模型
    private var selectedStorehouseModel: SAMStockStorehouse?
    
    ///当前第一响应textfield
    private var firstResponder: UITextField? {
        didSet{
            endEditingBtn.enabled = (firstResponder == nil) ? false : true
        }
    }
    
    ///分类选择pickerView
    private lazy var categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return pickerView
    }()
    
    ///仓库选择pickerView
    private lazy var storehousePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    ///当前选中模型index
    var selectedIndexPath: NSIndexPath?
    
    ///最近一次查询的参数
    private var parameters: [String: AnyObject]?
    ///请求URLStr
    private let URLStr = "getProductIDCodeList.ashx"
    ///一次数据请求获取的数据最大条数
    private let pageSize = 15
    ///当前数据的页码
    private var pageIndex = 1
    
    ///二维码模型数组
    var stockCodeModels = NSMutableArray()
    
    //MARK: - xib链接属性
    @IBOutlet weak var codeSearchView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: SAMLoginTextField!
    @IBOutlet weak var searchCodeBtn: UIButton!
    
    @IBOutlet weak var conSearchView: UIView!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var storehouseTF: UITextField!
    @IBOutlet weak var stockTF: UITextField!
    @IBOutlet weak var endEditingBtn: UIButton!
    
    //MARK: - 其他方法
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "SAMStockConditionalSearchController", bundle: nibBundleOrNil)
        
        //加载所有分类、仓库列表
        loadCategoryStorehouseList()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - CollectionViewDelegate
extension SAMStockConditionalSearchController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stockCodeModels.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SAMStockCodeCellReuseIdentifier, forIndexPath: indexPath) as! SAMStockCodeSearchCell
//        //设置样式
//        if indexPath == selectedIndexPath {
//            cell.containterView.backgroundColor = CellSelectedColor
//        } else {
//            cell.containterView.backgroundColor = CellNormalColor
//        }
//
        //传递数据模型
        let model = stockCodeModels[indexPath.row] as! SAMStockCodeModel
        print(model.codeName)
        print(model.thumbUrl1)
        cell.codeModel = model
        
        return cell
    }
}

extension SAMStockConditionalSearchController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //结束搜索框编辑状态
//        endTextFieldEditing(searchTF)
//        
//        selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as? SAMCustomerCollectionCell
//        
//        if selectedIndexPath == indexPath { //选中了当前选中的CELL
//            
//            //清空记录
//            selectedIndexPath = nil
//            
//            //执行动画
//            selectCellAnimation(nil, willNorCell: selectedCell)
//            
//            //清空记录
//            selectedCell = nil
//        } else { //选中了其他的CELL
//            
//            var willNorCell: SAMCustomerCollectionCell?
//            
//            if selectedIndexPath != nil { //没有选中其他CELL
//                willNorCell = collectionView.cellForItemAtIndexPath(selectedIndexPath!) as? SAMCustomerCollectionCell
//            }
//            
//            //记录数据
//            selectedIndexPath = indexPath
//            
//            //执行动画
//            selectCellAnimation(selectedCell, willNorCell: willNorCell)
        }
    }
    
    //MARK: - 点击了某个cell时执行的动画
    func selectCellAnimation(willSelCell: SAMCustomerCollectionCell?, willNorCell: SAMCustomerCollectionCell?) {
        
//        UIView.animateWithDuration(0.2, animations: {
//            //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
//            self.collectionView.performBatchUpdates({
//            }) { (finished) in
//            }
//            
//            //设置背景颜色
//            willSelCell?.containterView.backgroundColor = CellSelectedColor
//            willNorCell?.containterView.backgroundColor = CellNormalColor
//            
//            //恢复左滑形变
//            willNorCell?.containterView.transform = CGAffineTransformIdentity
//            
//            //一个神奇的方法
//            self.view.layoutIfNeeded()
//        }) { (_) in
//            
//            //如果点击了最下面一个cell，则滚至最底部
//            if self.selectedIndexPath?.row == (self.customerModels.count - 1) {
//                self.collectionView.scrollToItemAtIndexPath(self.selectedIndexPath!, atScrollPosition: .Bottom, animated: true)
//            }
//        }
//    }
}

//MARK: - collectionView布局代理
extension SAMStockConditionalSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        if indexPath == selectedIndexPath {
//            return CellSelectedSize
//        }
        return SAMStockCodeCellNormalSize
    }
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0
//    }
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        //结束搜索框编辑状态
//        endTextFieldEditing(searchTF)
//    }
}

//MARK: - TextFieldDelegate
extension SAMStockConditionalSearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //点击到完成按钮退出编辑状态
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //记录数据
        firstResponder = textField
        
        endEditingBtn.enabled = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        endEditingBtn.enabled = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //只有 库存数量框、二维码搜索框 允许输入数字
        if textField == stockTF || textField == searchTF {
            return true
        }
        return false
    }
}

extension SAMStockConditionalSearchController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //对pickerView进行判断
        if pickerView == categoryPickerView {
            return categories.count
        }else {
            return storehouses.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        //对pickerView进行判断
        if pickerView == categoryPickerView {
            
            let categoryModel = categories[row] as! SAMStockCategory
            return categoryModel.categoryName
        }else {
            
            let storehouseModel = storehouses[row] as! SAMStockStorehouse
            return storehouseModel.storehouseName
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //对pickerView进行判断 然后记录，再赋值
        if pickerView == categoryPickerView {
            
            let categoryModel = categories[row] as! SAMStockCategory
            selectedCategoryModel = categoryModel
            categoryTF.text = categoryModel.categoryName
        }else {
            
            let storehouseModel = storehouses[row] as! SAMStockStorehouse
            selectedStorehouseModel = storehouseModel
            storehouseTF.text = storehouseModel.storehouseName
        }
    }
}

//MARK: - 监听HUD，看情况退出控制器
extension SAMStockConditionalSearchController: MBProgressHUDDelegate {
    func hudWasHidden(hud: MBProgressHUD!) {
        
        //恢复交互
        view.userInteractionEnabled = true
        
        //退出控制器
        dismissViewControllerAnimated(true, completion: nil)
    }
}