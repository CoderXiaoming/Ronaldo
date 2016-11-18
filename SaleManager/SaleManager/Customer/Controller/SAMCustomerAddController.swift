//
//  SAMCustomerAddController.swift
//  SaleManager
//
//  Created by apple on 16/11/18.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMCustomerAddController: UIViewController {
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置圆角
        view.layer.cornerRadius = 8
        
        //加载部门，用户列表
        loadDepList()
        loadEmpList()
        
        //设置部门，用户选择器
        depTF.inputView = pickerView
        //TODO: 好像没有员工选择器
        
        
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //清空所有文本框
        let arr = NSArray(array: [customerTF, contactTF, cellTF, depTF, telTF, provinceTF, cityTF, addTF, remarkTF])
        arr.enumerateObjectsUsingBlock { (obj, ind, nil) in
            let tf = obj as! SAMLoginTextField
            tf.text = nil
        }
    }
    
    //MARK: - 加载部门列表
    private func loadDepList() {
        SAMNetWorker.sharedNetWorker().GET("getDeptList.ashx", parameters: nil, progress: nil, success: {[unowned self] (Task, Json) in
            print(Json)
            let dictArr = Json!["body"] as? [[String: String]]
            
            //判断是否有值
            if (dictArr?.count ?? 0) == 0 {
                return
            }
            
            //添加数据模型
            self.depList.removeAll()
            for dict in dictArr! {
                let depStr = dict["deptName"]
                self.depList.append(depStr!)
            }
        }) { (Task, Error) in
        }
    }
    
    //MARK: - 加载员工列表
    private func loadEmpList() {
        
        SAMNetWorker.sharedNetWorker().GET("getEmployeeList.ashx", parameters: nil, progress: nil, success: {[unowned self] (Task, Json) in
            print(Json)
            let dictArr = Json!["body"] as? [[String: String]]
            
            //判断是否有值
            if (dictArr?.count ?? 0) == 0 {
                return
            }
            
            //添加数据模型
            self.empList.removeAll()
            for dict in dictArr! {
                let depStr = dict["employeeName"]
                self.empList.append(depStr!)
            }
        }) { (Task, Error) in
        }
    }
    
    
    
    //MARK: - 点击事件处理
    @IBAction func cancelBtnClick(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func nextPageClick(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .LayoutSubviews, animations: { 
            self.fitstView.transform = CGAffineTransformMakeTranslation(-self.fitstView.bounds.width, 0)
            self.secondView.transform = CGAffineTransformMakeTranslation(-self.fitstView.bounds.width, 0)
            self.fitstView.userInteractionEnabled = false
            self.secondView.userInteractionEnabled = false
            }) { (_) in
                self.fitstView.userInteractionEnabled = true
                self.secondView.userInteractionEnabled = true
        }
    }
    @IBAction func backBtnCLick(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .LayoutSubviews, animations: {
            self.fitstView.transform = CGAffineTransformIdentity
            self.secondView.transform = CGAffineTransformIdentity
            self.fitstView.userInteractionEnabled = false
            self.secondView.userInteractionEnabled = false
        }) { (_) in
            self.fitstView.userInteractionEnabled = true
            self.secondView.userInteractionEnabled = true
        }
    }
    @IBAction func saveBtnClick(sender: AnyObject) {
        //获取字符串
        let customerStr = customerTF.text!.stringByTrimmingWhitespace()!
        if customerStr == "" {
            SAMHUD.showMessage("没有客户内容", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        let contactStr = contactTF.text!
        let cellStr = cellTF.text!
        let depStr = depTF.text!
        let telStr = telTF.text!
        let provinceStr = provinceTF.text!
        let cityStr = cityTF.text!
        let addStr = addTF.text!
        let remarkStr = remarkTF.text!
        
        //创建控制器
        let alert = UIAlertController(title: "请确认", message: nil, preferredStyle: .Alert)
        
       // 所有要展示信息
        let messages = [String(format: "客户：%@", customerStr), String(format: "联系人：%@", contactStr), String(format: "手机：%@", cellStr), String(format: "部门：%@", depStr), String(format: "电话：%@", telStr), String(format: "省份：%@", provinceStr), String(format: "城市：%@", cityStr), String(format: "地址：%@", addStr), String(format: "备注：%@", remarkStr)]
        
        //添加文本框
        for str in messages {
            alert.addTextFieldWithConfigurationHandler { (textField) in
                textField.text = str
                textField.userInteractionEnabled = false
            }
        }
        
        //添加按钮
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (action) in
        }
        let confirmAction = UIAlertAction(title: "确认", style: .Default) { (action) in
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func temp() {
        
    }
    
    //MARK: - 懒加载集合
    ///部门列表
    private lazy var depList = [String]()
    ///员工列表
    private lazy var empList = [String]()
    
    ///选择列表
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    //MARK: - xib链接属性
    @IBOutlet weak var fitstView: UIView!
    @IBOutlet weak var customerTF: SAMLoginTextField!
    @IBOutlet weak var contactTF: SAMLoginTextField!
    @IBOutlet weak var cellTF: SAMLoginTextField!
    @IBOutlet weak var depTF: SAMLoginTextField!
   
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var telTF: SAMLoginTextField!
    @IBOutlet weak var provinceTF: SAMLoginTextField!
    @IBOutlet weak var cityTF: SAMLoginTextField!
    @IBOutlet weak var addTF: SAMLoginTextField!
    @IBOutlet weak var remarkTF: SAMLoginTextField!
    

    //MARK: - 无关紧要的方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("SAMCustomerAddController", owner: self, options: nil)![0] as! UIView
    }
}

extension SAMCustomerAddController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return depList.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return depList[row] ?? ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        depTF.text = depList[row]
    }
}
