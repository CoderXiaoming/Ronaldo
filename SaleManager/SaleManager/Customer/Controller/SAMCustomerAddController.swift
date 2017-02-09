//
//  SAMCustomerAddController.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MBProgressHUD

///客户管理控制器类型
enum CustomerAddControlleType {
    case addCustomer
    case eidtCustomer
    case addVist
}

///新增客户URLStr
private let SAMUploadCustomerUrlStr = "CustomerAdd.ashx"
///编辑客户URLStr
private let SAMEditCustomerUrlStr = "CustomerEdit.ashx"

class SAMCustomerAddController: UIViewController {
    
    //MARK: - 对外提供的类工厂方法
    class func instance(customerModel: SAMCustomerModel?, type: CustomerAddControlleType) -> SAMCustomerAddController {
        let vc = SAMCustomerAddController()
        vc.controllerType = type
        vc.editingModel = customerModel
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
        
        //设置圆角
        view.layer.cornerRadius = 8
    
        switch controllerType! {
            case CustomerAddControlleType.addCustomer:
                thirdView.isHidden = true
                titleLabel.text = "新增客户"
                setupTextField()
                requestURLStr = SAMUploadCustomerUrlStr
            
            case CustomerAddControlleType.eidtCustomer:
                thirdView.isHidden = true
                //设置标题
                titleLabel.text = "编辑客户"
                setupTextField()
                setupEditCustomerModel()
                requestURLStr = SAMEditCustomerUrlStr
            
            case CustomerAddControlleType.addVist:
                vistContentTextView.layer.cornerRadius = 5
                vistContentTextView.layer.masksToBounds = true
                vistCustomerLabel.text = editingModel?.CGUnitName
        }
    }
    
    ///设置文本框
    fileprivate func setupTextField() {
    
        //设置textField的代理
        let arr = NSArray(array: [corporationTF, contactTF, cellTF, telTF, provinceTF, cityTF, addTF, addTF2, remarkTF])
        arr.enumerateObjects({ (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.delegate = self
        })
        
        //设置城市选择器
        provinceTF.inputView = cityPickerView
        cityTF.inputView = cityPickerView
    }
    
    ///赋值编辑的客户数据模型
    fileprivate func setupEditCustomerModel() {
    
        //设置公司名字 联系人名字
        if editingModel!.CGUnitName.contains("公司") { //对字符串进行分割
            let strArr = editingModel!.CGUnitName.components(separatedBy: "公司")
            if strArr.count > 1 {
                corporationTF.text = (strArr[0] as String).lxm_stringByTrimmingWhitespace()
                contactTF.text = (strArr[1] as String).lxm_stringByTrimmingWhitespace()
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
        
        //获取公司名称字符串，并进行判断，必须要求公司名称
        var customerStr = corporationTF.text!.lxm_stringByTrimmingWhitespace()!
        if customerStr == "" {
            let _ = SAMHUD.showMessage("请填写公司", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        let contactStr = contactTF.text!.lxm_stringByTrimmingWhitespace()!
        let cellStr = cellTF.text!.lxm_stringByTrimmingWhitespace()!
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
        //TODO: - 修改，要求不拼接公司二字，如果后期需要公司二字，可直接更换下面两句
        //customerStr = String(format: "%@公司 %@", customerStr, contactStr)
        customerStr = String(format: "%@ %@", customerStr, contactStr)
        addStr = addStr + addStr2
        
        //添加确认按钮
        let confirmAction = UIAlertAction(title: "确认", style: .default) { (action) in
            
            //创建请求参数
            var parameters = ["id": SAMUserAuth.shareUser()!.id!, "employeeID": SAMUserAuth.shareUser()!.employeeID!, "customerName": customerStr, "contactPerson": "", "deptID": SAMUserAuth.shareUser()!.deptID!, "mobilePhone": cellStr, "phoneNumber": telStr, "province": provinceStr, "city": cityStr, "address": addStr, "memoInfo": remarkStr]
            
            if self.editingModel != nil {
                parameters["CGUnitID"] = self.editingModel!.id
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
        SAMNetWorker.sharedNetWorker().post(requestURLStr!, parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            
                let Json = json as! [String: AnyObject]
                let state = (Json["head"] as! [String: String])["status"]!
                self!.unloadCompletion(state)
            }) {[weak self] (Task, Error) in
                
                self!.unloadCompletion("error")
        }
    }
    
    //MARK: - 上传资料后回调
    fileprivate func unloadCompletion(_ state: String) {
        
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
    
    ///上传回访界面取消按钮点击
    @IBAction func vistCancelBtnClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    ///上传回访界面确认按钮点击
    @IBAction func vistEnsureBtnClick(_ sender: UIButton) {
        
        //退出编辑状态
        vistContentTextView.resignFirstResponder()
        
        //创建主请求参数
        let strContent = vistContentTextView.text.lxm_stringByTrimmingWhitespace()!
        if strContent == "" {
            let _ = SAMHUD.showMessage("请填写回访内容", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        let CGUnitID = editingModel!.id
        let startDate = Date().yyyyMMddStr()
        let userID = SAMUserAuth.shareUser()?.id!
        
        let MainData = ["CGUnitID": CGUnitID, "startDate": startDate, "strContent": strContent, "userID": userID]
        
        //转换为Json字符串
        let mainJsonData = try! JSONSerialization.data(withJSONObject: MainData, options: JSONSerialization.WritingOptions.prettyPrinted)
        let mainJsonStr = String(data: mainJsonData, encoding: String.Encoding.utf8)!
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("正在保存...", comment: "HUD loading title")
        //发送服务器请求
        SAMNetWorker.sharedNetWorker().post("CGUnitFollowAdd.ashx", parameters: ["MainData": mainJsonStr], progress: nil, success: {[weak self] (task, json) in
            
            //隐藏HUD
            hud?.hide(true)
            
            //获取状态字符串
            let Json = json as! [String: AnyObject]
            let dict = Json["head"] as! [String: String]
            let state = dict["status"]
            
            if state == "success" { //保存成功
                
                let hud = SAMHUD.showMessage("保存成功", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                hud?.delegate = self
            }else { //保存失败
                let _ = SAMHUD.showMessage("保存失败", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }
        }) {[weak self] (task, error) in
            let _ = SAMHUD.showMessage("请检查网络", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }

    }
    
    //MARK: - 结束当前textField编辑状态
    func endFirstResponderEditing() {
        if firstResponder != nil {
            firstResponder?.resignFirstResponder()
        }
    }
    
    //MARK: - 属性
    ///控制器类型
    fileprivate var controllerType: CustomerAddControlleType?
    ///传递需要编辑的客户数据
    fileprivate var editingModel: SAMCustomerModel?
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
    
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var vistCustomerLabel: UILabel!
    @IBOutlet weak var vistContentTextView: UITextView!
    @IBOutlet weak var visitAddEnsureBtn: UIButton!
    
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
        self.dismiss(animated: true, completion: nil)
    }
}

