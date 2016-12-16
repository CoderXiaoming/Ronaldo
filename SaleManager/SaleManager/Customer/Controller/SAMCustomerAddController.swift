//
//  SAMCustomerAddController.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MBProgressHUD
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


///新增客户URLStr
private let SAMUploadCustomerUrlStr = "CustomerAdd.ashx"
///编辑客户URLStr
private let SAMEditCustomerUrlStr = "CustomerEdit.ashx"

class SAMCustomerAddController: UIViewController {
    
    ///传递需要编辑的客户数据
    var editingModel: SAMCustomerModel? {
        didSet {
            if editingModel == nil {
                requestURLStr = SAMUploadCustomerUrlStr
            }else {
                requestURLStr = SAMEditCustomerUrlStr
            }
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置圆角
        view.layer.cornerRadius = 8
        
        //设置textField的代理
        let arr = NSArray(array: [corporationTF, contactTF, cellTF, telTF, provinceTF, cityTF, addTF, addTF2, remarkTF])
        arr.enumerateObjects({ (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.delegate = self
        })
        
        //设置城市选择器
        provinceTF.inputView = cityPickerView
        cityTF.inputView = cityPickerView
        
        //设置初始请求URL
        if requestURLStr == nil {
            requestURLStr = SAMUploadCustomerUrlStr
        }
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //清空所有文本框
        let arr = NSArray(array: [corporationTF, contactTF, cellTF, telTF, provinceTF, cityTF, addTF, addTF2, remarkTF])
        arr.enumerateObjects({ (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.text = nil
        })
        
        //重置记录
        isAddTFdidReachMax = false
        proIndex = 0
        firstResponder = nil
        
        //判断是不是编辑状态
        if editingModel != nil {
            
            //设置标题
            titleLabel.text = "编辑客户"
            
            //设置公司名字 联系人名字
            if editingModel!.CGUnitName!.contains("公司") { //对字符串进行分割
                let strArr = editingModel!.CGUnitName?.components(separatedBy: "公司")
                if strArr?.count > 1 {
                    corporationTF.text = (strArr![0] as String).lxm_stringByTrimmingWhitespace()
                    contactTF.text = (strArr![1] as String).lxm_stringByTrimmingWhitespace()
                }
            }else {
                corporationTF.text = editingModel?.CGUnitName
            }
            
            cellTF.text = editingModel?.mobilePhone
            telTF.text = editingModel?.phoneNumber
            provinceTF.text = editingModel?.province
            cityTF.text = editingModel?.city
            addTF.text = editingModel?.address
            remarkTF.text = editingModel?.memoInfo
        }else {
            titleLabel.text = "新增客户"
        }
    }
    
    //MARK: - 点击事件处理
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextPageClick(_ sender: AnyObject) {
        //退出编辑状态
        endFirstResponderEditing()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .layoutSubviews, animations: { 
            self.fitstView.transform = CGAffineTransform(translationX: -self.fitstView.bounds.width, y: 0)
            self.secondView.transform = CGAffineTransform(translationX: -self.fitstView.bounds.width, y: 0)
            self.fitstView.isUserInteractionEnabled = false
            self.secondView.isUserInteractionEnabled = false
            
            }) { (_) in
                self.fitstView.isUserInteractionEnabled = true
                self.secondView.isUserInteractionEnabled = true
        }
    }
    @IBAction func backBtnCLick(_ sender: AnyObject) {
        //退出编辑状态
        endFirstResponderEditing()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .layoutSubviews, animations: {
            self.fitstView.transform = CGAffineTransform.identity
            self.secondView.transform = CGAffineTransform.identity
            self.fitstView.isUserInteractionEnabled = false
            self.secondView.isUserInteractionEnabled = false
        }) { (_) in
            self.fitstView.isUserInteractionEnabled = true
            self.secondView.isUserInteractionEnabled = true
        }
    }
    @IBAction func uploadBtnClick(_ sender: AnyObject) {
        //退出编辑状态
        endFirstResponderEditing()
        
        //获取公司名称字符串，并进行判断
        var customerStr = corporationTF.text!.lxm_stringByTrimmingWhitespace()!
        if customerStr == "" {
            let _ = SAMHUD.showMessage("请填写公司", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //获取联系人名称字符串，并进行判断
        let contactStr = contactTF.text!.lxm_stringByTrimmingWhitespace()!
        if contactStr == "" {
            let _ = SAMHUD.showMessage("请填写联系人", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //获取手机字符串，并进行判断
        let cellStr = cellTF.text!.lxm_stringByTrimmingWhitespace()!
        if (cellStr != "") && !cellStr.lxm_stringisWholeNumber() {
            let _ = SAMHUD.showMessage("请填写合法手机号", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        let telStr = telTF.text!.lxm_stringByTrimmingWhitespace()!
        let provinceStr = provinceTF.text!.lxm_stringByTrimmingWhitespace()!
        let cityStr = cityTF.text!.lxm_stringByTrimmingWhitespace()!
        var addStr = addTF.text!.lxm_stringByTrimmingWhitespace()!
        let addStr2 = addTF2.text!.lxm_stringByTrimmingWhitespace()!
        let remarkStr = remarkTF.text!.lxm_stringByTrimmingWhitespace()!
        
        //创建控制器
        let alert = UIAlertController(title: "请确认", message: nil, preferredStyle: .alert)
        
       //所有要展示信息
        let messages = [String(format: "公司：%@", customerStr), String(format: "联系人：%@", contactStr), String(format: "手机：%@", cellStr), String(format: "电话：%@", telStr), String(format: "省份：%@", provinceStr), String(format: "城市：%@", cityStr), String(format: "地址：%@", addStr), String(format: "地址：%@", addStr2), String(format: "备注：%@", remarkStr)]
        
        //添加文本框
        for str in messages {
            alert.addTextField { (textField) in
                textField.text = str
                textField.isUserInteractionEnabled = false
            }
        }
        
        //添加取消按钮
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
        }
        
        //组建客服，地址字符串
        customerStr = String(format: "%@公司 %@", customerStr, contactStr)
        addStr = addStr + addStr2
        
        //添加确认按钮
        let confirmAction = UIAlertAction(title: "确认", style: .default) { (action) in
            
            //创建请求参数
            var parameters = ["id": SAMUserAuth.shareUser()!.id!, "employeeID": SAMUserAuth.shareUser()!.employeeID!, "customerName": customerStr, "contactPerson": "", "deptID": SAMUserAuth.shareUser()!.deptID!, "mobilePhone": cellStr, "phoneNumber": telStr, "province": provinceStr, "city": cityStr, "address": addStr, "memoInfo": remarkStr]
            
            if self.editingModel != nil {
                parameters["CGUnitID"] = self.editingModel!.id!
            }
            
            //发送请求，获取结果
            self.uploadCustomer(parameters)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - 上传用户资料
    fileprivate func uploadCustomer(_ parameters: [String: String]) {
        SAMNetWorker.sharedNetWorker().post(requestURLStr!, parameters: parameters, progress: nil, success: { (Task, json) in
            
                let Json = json as! [String: AnyObject]
                let state = (Json["head"] as! [String: String])["status"]!
                self.unloadCompletion(state)
            }) { (Task, Error) in
                
                self.unloadCompletion("error")
        }
    }
    
    //MARK: - 上传资料后回调
    fileprivate func unloadCompletion(_ state: String) {
        //记录请求完成的状态
        requestCompState = state
        
        //分情况展示提示信息
        switch state {
        case "success":
            
            let message = (editingModel == nil) ? "上传成功" : "修改成功"
            let hud = SAMHUD.showMessage(message, superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            hud?.delegate = self
        case "fail":
            
            let _ = SAMHUD.showMessage("已存在同名客户", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        case "error":
            
            let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        default :
            break
        }
    }
    
    //MARK: - 结束当前textField编辑状态
    func endFirstResponderEditing() {
        if firstResponder != nil {
            firstResponder?.resignFirstResponder()
        }
    }
    
    //MARK: - viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //恢复界面
        self.fitstView.transform = CGAffineTransform.identity
        self.secondView.transform = CGAffineTransform.identity
        
        //还原模型
        editingModel = nil
    }
    
    //MARK: - 懒加载集合
    ///当前第一相应textfield
    fileprivate var firstResponder: UITextField?
    ///addTF已经达到了最大长度
    fileprivate var isAddTFdidReachMax:Bool = false
    ///省会城市列表
    fileprivate lazy var proCityListArr: [LXMProCityList] = {
        var listArr = [LXMProCityList]()
        let filePath = Bundle.main.path(forResource: "provinces.plist", ofType: nil)!
        let dictArr = NSArray(contentsOfFile: filePath)
        let arr = LXMProCityList.mj_objectArray(withKeyValuesArray: dictArr)
        for obj in arr! {
            let list = obj as! LXMProCityList
            listArr.append(list)
        }
        return listArr
    }()
    ///城市选择pickerView
    fileprivate lazy var cityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    ///当前选中省份的序号
    fileprivate var proIndex = 0
    ///请求URLStr
    fileprivate var requestURLStr: String?
    ///请求完毕的状态
    fileprivate var requestCompState: String?
    
    //MARK: - xib链接属性
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fitstView: UIView!
    @IBOutlet weak var corporationTF: SAMLoginTextField!
    @IBOutlet weak var contactTF: SAMLoginTextField!
    @IBOutlet weak var cellTF: SAMLoginTextField!
    @IBOutlet weak var telTF: SAMLoginTextField!
   
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var provinceTF: SAMLoginTextField!
    @IBOutlet weak var cityTF: SAMLoginTextField!
    @IBOutlet weak var addTF: SAMLoginTextField!
    @IBOutlet weak var addTF2: SAMLoginTextField!
    @IBOutlet weak var remarkTF: SAMLoginTextField!
    

    //MARK: - 无关紧要的方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMCustomerAddController", owner: self, options: nil)![0] as! UIView
    }
}

extension SAMCustomerAddController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //如果是第一行地址栏，则跳转第二行地址栏
        if textField == addTF {
            let _ = addTF2.becomeFirstResponder()
            return true
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        firstResponder = textField
    }
    
    //MARK: - 城市选择器不允许输入文字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == provinceTF || textField == cityTF {
            return false
        }
        return true
    }
}

extension SAMCustomerAddController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if  component == 0 {
            return proCityListArr.count
        }else {
            let list = proCityListArr[proIndex] as LXMProCityList
            return list.cities!.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let list = proCityListArr[row]
            return list.name
        }else {
            let list = proCityListArr[proIndex] as LXMProCityList
            return list.cities![row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 滚动省会,刷新城市
        if (component == 0) {
            proIndex = pickerView.selectedRow(inComponent: 0)
            pickerView.reloadComponent(1)
        }
        
        // 给城市文本框赋值
        // 获取选中省会
        let list = proCityListArr[proIndex]
        // 获取选中的城市
        let cityIndex = pickerView.selectedRow(inComponent: 1)
        
        let cityName = list.cities![cityIndex]
        provinceTF.text = list.name
        cityTF.text = cityName
    }
}

//MARK: - 监听HUD，看情况退出控制器
extension SAMCustomerAddController: MBProgressHUDDelegate {
    func hudWasHidden(_ hud: MBProgressHUD!) {
        if requestCompState == "success" {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

