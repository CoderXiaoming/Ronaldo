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
    class func editInfo(orderTitleModel: SAMOrderBuildTitleModel) -> SAMOrderInfoEditController {
        
        let editVC = SAMOrderInfoEditController()
        editVC.orderTitleModel = orderTitleModel
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
        rightButton.isEnabled = false
        
        //监听文本框
        contentTextField.addTarget(self, action: #selector(SAMOrderInfoEditController.textFieldEditChange), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //赋值文本框
        contentTextField.text = orderTitleModel?.cellContent
        
        //设置不同内容设置键盘类型
        if orderTitleModel!.cellTitle == "客户" || orderTitleModel!.cellTitle == "备注" {
            contentTextField.keyboardType = UIKeyboardType.default
        }else {
            contentTextField.keyboardType = UIKeyboardType.decimalPad
        }
    }
    
    //MARK: - 左边按钮点击事件
    func leftButtonClick() {
        navigationController!.popViewController(animated: true)
    }
    
    //MARK: - 左边按钮点击事件
    func rightButtonClick() {
        
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

    //MARK: - 属性
    ///编辑的数据模型
    fileprivate var orderTitleModel: SAMOrderBuildTitleModel?
    
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
