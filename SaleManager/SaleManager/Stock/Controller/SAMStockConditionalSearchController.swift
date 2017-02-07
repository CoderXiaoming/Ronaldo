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

///加载所有分类的链接
private let loadCategoriesURLStr = "getCategoryList.ashx"
///加载所有仓库的链接
private let loadStorehousesURLStr = "getStorehouseList.ashx"
///分类输入控制器的Cell
private let SAMCategoryInputViewCellIdentifier = "SAMCategoryInputViewCellIdentifier"

class SAMStockConditionalSearchController: UIViewController {
    
    ///对外提供的类工厂方法
    class func instance() -> SAMStockConditionalSearchController {
        return SAMStockConditionalSearchController()
    }
    
    //MARK: - 提供给外界设置点击搜索按钮回调闭包的方法
    func setCompletionCallback(_ callback: @escaping (([String: AnyObject]?) -> ())) {
        
        //赋值回调闭包
        searchCallback = callback
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupBasicUI()
        
        //设置Textfield
        setupTextfield()
    }
    
    ///初始化UI
    fileprivate func setupBasicUI() {
        
        //设置圆角
        view.layer.cornerRadius = 8
        
        //设置 分类/仓库 选择器
//        categoryTF.inputView = categoryPickerView  更改
        categoryTF.inputAccessoryView = categoryInputView
        
        storehouseTF.inputView = storehousePickerView
    }
    
    ///初始化Textfield
    fileprivate func setupTextfield() {
        
        let arr = NSArray(array: [categoryTF, numberTF, storehouseTF, stockTF])
        arr.enumerateObjects({ (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            
            //设置textField的代理
            tf.delegate = self
        })
        
        //监听分类文本框
        categoryTF.addTarget(self, action: #selector(SAMStockConditionalSearchController.categoryTFdidChangeText), for: .editingChanged)
    }

    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //加载所有分类、仓库列表
        loadCategoryStorehouseList()
        
        //设置退出编辑按钮可用性
        endEditingBtn.isEnabled = false
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //对分类、仓库列表进行判断
        if categories.count == 0 || storehouses.count == 0 {
            view.isUserInteractionEnabled = false
            let hud = SAMHUD.showMessage("网络错误，请重试", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            hud!.delegate = self
        }
    }
    
    //MARK: - 记载所有分类、仓库列表
    fileprivate func loadCategoryStorehouseList() {
        
        //加载分类列表
        loadList(loadCategoriesURLStr)
        
        //加载仓库列表
        loadList(loadStorehousesURLStr)
    }
    
    //MARK: - 单独加载分类/仓库列表
    fileprivate func loadList(_ URLStr: String) {
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(URLStr, parameters: nil, progress: nil, success: {[weak self] (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            
            //对请求链接进行判断
            switch URLStr {
            case loadCategoriesURLStr:
                self!.categories.removeAllObjects()
                let arr = SAMStockCategory.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.categories.addObjects(from: arr as [AnyObject])
            case loadStorehousesURLStr:
                self!.storehouses.removeAllObjects()
                let arr = SAMStockStorehouse.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.storehouses.addObjects(from: arr as [AnyObject])
            default :
                break
            }
        }) { (Task, Error) in
    }
    }
    
    //MARK: - 用户点击事件处理
    ///点击了取消按钮
    @IBAction func cancelBtnClick(_ sender: AnyObject) {
        dismiss(animated: true) {
            //发出通知
            NotificationCenter.default.post(name: NSNotification.Name.init(SAMStockConSearchControllerDismissSuccessNotification), object: nil)
        }
    }
    
    ///点击了退出键盘按钮
    @IBAction func endEditingBtnClick(_ sender: AnyObject) {
        endFirstResponderEditing()
    }
    
    ///点击了搜索按钮
    @IBAction func searchBtnClick(_ sender: AnyObject) {
        //退回编辑状态
        endFirstResponderEditing()
        
        //判断库存数量
        if !(stockTF.text?.lxm_stringisWholeNumber())! {
            let _ = SAMHUD.showMessage("请填写整数库存", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //创建回调参数
        let productIDName = numberTF.text
        let minCountM = stockTF.text
        let parameters = ["productIDName": productIDName, "storehouseID": storehouseID, "parentID": parentID, "minCountM": minCountM!]
        
        //执行回调参数
        if searchCallback != nil {
            searchCallback!(parameters as [String : AnyObject]?)
        }
    }
    
    //MARK: - 结束当前textField编辑状态
    fileprivate func endFirstResponderEditing() {
        if firstResponder != nil {
            firstResponder?.resignFirstResponder()
        }
    }
    
    //MARK: - 懒加载集合
    //分类模型数组
    fileprivate let categories = NSMutableArray()
    //仓库模型数组
    fileprivate let storehouses = NSMutableArray()
    
    ///当前第一响应textfield
    fileprivate var firstResponder: UITextField? {
        didSet{
            endEditingBtn.isEnabled = (firstResponder == nil) ? false : true
        }
    }
    
    ///记录当前是否在搜索分类
    fileprivate var isSearch: Bool = false
    ///当前搜索条件下的分类模型数组
    fileprivate let categorySearchResultModels = NSMutableArray()
    ///当前选中的分类模型
    fileprivate var currentSelectedCategoryModel: SAMStockCategory? {
        didSet{
            if currentSelectedCategoryModel == nil {
                categoryTF.text = ""
                parentID = "-1"
            }else {
                categoryTF.text = currentSelectedCategoryModel?.categoryName
                parentID = currentSelectedCategoryModel!.id!
            }
        }
    }
    
    /*
    ///分类选择pickerView
    fileprivate lazy var categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return pickerView
    }()
     */
    
    ///分类选择输入选择控件
    fileprivate lazy var categoryInputView: UICollectionView = {
        let inputView = UICollectionView(frame: CGRect.zero, collectionViewLayout: SAMCategoryInputColViewFlowLayout())
        inputView.frame = UIScreen.main.bounds
        inputView.frame.size.height = 250
        inputView.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
        
        //注册cell
        inputView.register(UINib(nibName: "SAMCategoryInputViewCell", bundle: nil), forCellWithReuseIdentifier: SAMCategoryInputViewCellIdentifier)
        
        inputView.dataSource = self
        inputView.delegate = self
        return inputView
    }()
    
    ///仓库选择pickerView
    fileprivate lazy var storehousePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    ///点击搜索后回调的闭包
    var searchCallback: (([String: AnyObject]?) -> ())?
    //搜索回调闭包中的分类id参数
    var parentID = "-1"
    //搜索回调闭包中的仓库id参数
    var storehouseID = "-1"
    
    //MARK: - xib链接属性
    @IBOutlet weak var conSearchView: UIView!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var storehouseTF: UITextField!
    @IBOutlet weak var stockTF: UITextField!
    @IBOutlet weak var endEditingBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    
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
        //从xib加载view
        view = Bundle.main.loadNibNamed("SAMStockConditionalSearchController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - TextFieldDelegate
extension SAMStockConditionalSearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //点击到完成按钮退出编辑状态
        textField.resignFirstResponder()
        
        //如果是分类文本框
        if textField == categoryTF {
            let model = currentSelectedCategoryModel
            currentSelectedCategoryModel = model
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //记录数据
        firstResponder = textField
        
        //设置结束搜索按钮状态
        endEditingBtn.isEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingBtn.isEnabled = false
        
        if textField == stockTF {
            //获取文本字符串
            let str = textField.text
            
            //如果是空字符串，就赋值文本框，返回
            if str == ""  {
                textField.text = "0"
                return
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //如果为分类文本框
        if textField == categoryTF {
            return true
        }
        
        //如果为库存文本框
        if textField == stockTF {
            //获取当前文本
            let str = textField.text
            
            //如果第一个是0，删除第一个0
            if str == "0" {
                textField.text = ""
                return true
            }
            
            return true

        }else if textField == numberTF { //如果为产品编号文本框
            return true
        }
        
        return false
    }
    
    //分类文本框监听方法
    func categoryTFdidChangeText() {
        categoryTFdidInput(searchText: categoryTF.text)
    }
    
    fileprivate func categoryTFdidInput(searchText: String?) {
        
        //获取搜索字符串
        let searchStr = NSString(string: (searchText?.lxm_stringByTrimmingWhitespace()!)!)
        
        if searchStr.length > 0 {
            
            //记录正在搜索
            isSearch = true
            
            //获取搜索字符串数组
            let searchItems = searchStr.components(separatedBy: " ")
            
            var andMatchPredicates = [NSPredicate]()
            
            for item in searchItems {
                
                let searchString = item as NSString
                //categoryName搜索谓语
                let lhs = NSExpression(forKeyPath: "categoryName")
                let rhs = NSExpression(forConstantValue: searchString)
                let firstPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                
                let orMatchPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstPredicate])
                andMatchPredicates.append(orMatchPredicate)
            }
            
            let finalCompoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: andMatchPredicates)
            
            //存储搜索结果
            let arr = categories.filtered(using: finalCompoundPredicate)
            categorySearchResultModels.removeAllObjects()
            categorySearchResultModels.addObjects(from: arr)
        }else {
            //记录没有搜索
            isSearch = false
        }
        
        //刷新tableView
        categoryInputView.reloadData()
    }
}

//MARK: PickerViewDelegate PickerViewDataSource
extension SAMStockConditionalSearchController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        /*
        //对pickerView进行判断
        if pickerView == categoryPickerView {
            return categories.count
        }else {
            return storehouses.count
        }
        */
        return storehouses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        /*
        //对pickerView进行判断
        if pickerView == categoryPickerView {
            
            let categoryModel = categories[row] as! SAMStockCategory
            return categoryModel.categoryName
        }else {
            
            let storehouseModel = storehouses[row] as! SAMStockStorehouse
            return storehouseModel.storehouseName
        }
        */
        let storehouseModel = storehouses[row] as! SAMStockStorehouse
        return storehouseModel.storehouseName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        /*
        //对pickerView进行判断 然后记录，再赋值
        if pickerView == categoryPickerView {
            
            //取出对应模型
            let categoryModel = categories[row] as! SAMStockCategory
            
            //赋值textfield
            categoryTF.text = categoryModel.categoryName
            
            //赋值参数
            parentID = categoryModel.id!
        }else {
            
            let storehouseModel = storehouses[row] as! SAMStockStorehouse
            storehouseTF.text = storehouseModel.storehouseName
            storehouseID = storehouseModel.id!
        }
        */
        let storehouseModel = storehouses[row] as! SAMStockStorehouse
        storehouseTF.text = storehouseModel.storehouseName
        storehouseID = storehouseModel.id!
    }
}

//MARK: - 监听HUD，看情况退出控制器
extension SAMStockConditionalSearchController: MBProgressHUDDelegate {
    func hudWasHidden(_ hud: MBProgressHUD!) {
        
        //恢复交互
        view.isUserInteractionEnabled = true
        
        //退出控制器
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - 分类输入控制器collectionView用到的FlowLayout
private class SAMCategoryInputColViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 5
        minimumInteritemSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView?.showsVerticalScrollIndicator = false
        itemSize = CGSize(width: ScreenW * 0.5 - 5, height: 40)
    }
}

//MARK: - 分类输入控制器collectionView用到的 datasource delegate
extension SAMStockConditionalSearchController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? categorySearchResultModels : categories
        
        return sourceArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMCategoryInputViewCellIdentifier, for: indexPath) as! SAMCategoryInputViewCell
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? categorySearchResultModels : categories
        let categoryModel = sourceArr[indexPath.item] as! SAMStockCategory
        cell.categoryModel = categoryModel
        return cell
    }
}

extension SAMStockConditionalSearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categoryTF.resignFirstResponder()
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? categorySearchResultModels : categories
        currentSelectedCategoryModel = sourceArr[indexPath.item] as? SAMStockCategory
    }
}
