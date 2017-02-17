//
//  SAMOrderInfoEditController.swift
//  SaleManager
//
//  Created by apple on 16/12/17.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMOrderInfoEditController: UIViewController {

    //对外提供的类方法
    class func editInfo(orderTitleModel: SAMOrderBuildTitleModel, employeeModel: SAMOrderBuildEmployeeModel?) -> SAMOrderInfoEditController {
        
        let editVC = SAMOrderInfoEditController()
        editVC.orderTitleModel = orderTitleModel
        editVC.orderBuildEmployeeModel = employeeModel
        return editVC
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始主标题
        navigationItem.title = orderTitleModel?.cellTitle
        
        //设置左按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(SAMOrderInfoEditController.leftButtonClick))
        
        //设置右按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        if orderTitleModel?.cellTitle == "业务员" {
            rightButton.isEnabled = true
        }else {
            rightButton.isEnabled = false
        }
        
        //监听文本框，并设置代理
        contentTextField.addTarget(self, action: #selector(SAMOrderInfoEditController.textFieldEditChange), for: .editingChanged)
        contentTextField.delegate = self
        
        //设置订单业务员数据模型数组
        if SAMOrderBuildEmployeeModel.shareModelArr().count == 0 {
            SAMOrderBuildEmployeeModel.setupModels()
        }
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        //赋值文本框
        contentTextField.text = orderTitleModel?.cellContent
        
        //设置不同内容设置键盘类型
        if orderTitleModel!.cellTitle == "备注" {
            contentTextField.keyboardType = UIKeyboardType.default
        }else if orderTitleModel!.cellTitle == "交货日期" {
            contentTextField.inputView = datePicker
        }else if orderTitleModel!.cellTitle == "业务员" {
            contentTextField.inputView = employeePicker
        }else {
            contentTextField.keyboardType = UIKeyboardType.decimalPad
        }
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentTextField.becomeFirstResponder()
    }
    
    //MARK: - 左边按钮点击事件
    func leftButtonClick() {
        navigationController!.popViewController(animated: true)
    }
    
    //MARK: - 右边按钮点击事件
    func rightButtonClick() {
        contentTextField.resignFirstResponder()
        orderTitleModel?.cellContent = contentTextField.text!.lxm_stringByTrimmingWhitespace()!
        navigationController!.popViewController(animated: true)
    }
    
    //MARK: - 文本框监听方法
    func textFieldEditChange() {
        if contentTextField.text == orderTitleModel?.cellContent {
            rightButton.isEnabled = false
        }else {
            rightButton.isEnabled = true
        }
    }
    
    //时间选择器 选择时间
    func dateChanged(_ datePicker: UIDatePicker) {
        
        //设置文本框时间
        contentTextField.text = datePicker.date.yyyyMMddStr()
        
        //调用文本框监听方法
        textFieldEditChange()
    }
    
    //MARK: - 属性
    ///编辑的数据模型
    fileprivate var orderTitleModel: SAMOrderBuildTitleModel? {
        didSet{
            isEditTitle = (orderTitleModel?.cellTitle == "备注" || orderTitleModel?.cellTitle == "交货日期") ? true : false
        }
    }
    
    ///接收的订单业务员数据模型
    fileprivate var orderBuildEmployeeModel: SAMOrderBuildEmployeeModel?
    
    ///当前是编辑文字，否则是编辑数字
    fileprivate var isEditTitle: Bool = true
    
    ///右边按钮
    fileprivate lazy var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("保存", for: .normal)
        button.setTitleColor(UIColor(red: 22 / 255.0, green: 122 / 255.0, blue: 189 / 255.0, alpha: 1.0), for: .normal)
        button.setTitleColor(UIColor(red: 82 / 255.0, green: 182 / 255.0, blue: 249 / 255.0, alpha: 1.0), for: .disabled)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15)
        button.addTarget(self, action: #selector(SAMOrderInfoEditController.rightButtonClick), for: .touchUpInside)
        button.sizeToFit()

        return button
    }()
    
    ///时间选择器
    fileprivate lazy var datePicker: UIDatePicker? = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(SAMOrderInfoEditController.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    ///业务员选择器
    fileprivate lazy var employeePicker: UIPickerView? = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()

    //MARK: - xib链接属性
    @IBOutlet weak var contentTextField: UITextField!
    
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
        view = Bundle.main.loadNibNamed("SAMOrderInfoEditController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - 文本框代理 UITextFieldDelegate
extension SAMOrderInfoEditController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if orderTitleModel?.cellTitle == "业务员" {
            
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //如果当前是文本编辑
        if isEditTitle {
            return true
        }
        
        //获取当前文本
        let str = textField.text
        if str == "" {
            return true
        }
        
        //如果第一个是小数点就删除小数点
        if str == "." {
            textField.text = ""
            return true
        }
        
        //如果第一个是0
        if str == "0" {
            
            //如果第二个是小数点，允许输入
            if string == "." {
                
                return true
            }else { //如果第二个不是是小数点，删除第一个0
                
                textField.text = ""
                return true
            }
        }
        
        //如果输入小数点，且当前文本已经有小数点，不让输入
        if (str!.contains(".")) && (string == ".") {
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //如果是文本编辑就直接返回
        if isEditTitle {
            return
        }
        
        //获取文本字符串
        var str = textField.text
        
        //如果是空字符串，就赋值文本框，返回
        if str == ""  {
            contentTextField.text = "0"
            return
        }
        
        //截取最后一个小数点
        str = str?.lxm_stringByTrimmingLastIfis(".")
        
        //如果截取后没有字符，或者为0，则赋值
        if str == "" || str == "0"  {
            contentTextField.text = "0"
            return
        }
        
        //赋值文本框
        textField.text = str
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //结束第一响应者
        textField.resignFirstResponder()
        
        return true
    }
}

//MARK: - PickerViewDataSource PickerViewDelegate
extension SAMOrderInfoEditController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SAMOrderBuildEmployeeModel.shareModelArr().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = SAMOrderBuildEmployeeModel.shareModelArr()[row] as! SAMOrderBuildEmployeeModel
        return model.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = SAMOrderBuildEmployeeModel.shareModelArr()[row] as! SAMOrderBuildEmployeeModel
        contentTextField.text = model.name
        orderBuildEmployeeModel?.employeeID = model.employeeID
        orderBuildEmployeeModel?.name = model.name
    }
}

