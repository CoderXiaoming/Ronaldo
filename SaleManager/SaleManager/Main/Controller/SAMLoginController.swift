//
//  SAMLoginController.swift
//  SaleManager
//
//  Created by apple on 16/11/11.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

class SAMLoginController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func loadView() { //从XIB加载View,此方法不写在模拟器上正常，但真机调试会出现BUG
        view = NSBundle.mainBundle().loadNibNamed("SAMLoginController", owner: self, options: nil)![0] as! UIView
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化设置UI
        setupUI()
    }
    
    //MARK: - 初始化设置UI
    private func setupUI() {
        //设置两个按钮的边角
        loginBtn.layer.cornerRadius = 7
        confirmBtn.layer.cornerRadius = 7
        
        //设置用户名 密码框的代理 并进行监听
        userNameTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), forControlEvents: .EditingChanged)
        PwdTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), forControlEvents: .EditingChanged)
        serverAddTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), forControlEvents: .EditingChanged)
    }

    //MARK: - 返回服务器设置界面按钮点击
    @IBAction func loginBackBtnClick(sender: UIButton) {
        endEditing()
        UIView.animateWithDuration(0.9) {
            self.loginView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
            self.serverView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
        }
    }
    //MARK: - 服务器地址确认按钮点击
    @IBAction func severBtnClick(sender: AnyObject) {
        endEditing()
        UIView.animateWithDuration(0.9) {
            self.loginView.transform = CGAffineTransformIdentity
            self.serverView.transform = CGAffineTransformIdentity
        }
    }
    //MARK: - 登录按钮点击
    @IBAction func loginBtnClick(sender: AnyObject) {
    }
    
    //MARK: - 结束界面编辑状态
    func endEditing() {
        view.endEditing(false)
    }
    
    //MARK: - 检查确认和登录按钮的状态
    func checkBtnState(textField: UITextField) {
        switch textField {
        case serverAddTF:
            confirmBtn.enabled = serverAddTF.hasText()
        case userNameTF, PwdTF:
            loginBtn.enabled = userNameTF.hasText() && PwdTF.hasText()
        default :
            break
        }
    }
    
    //点击界面退出编辑状态
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        endEditing()
    }
    
    //MARK: - xib链接属性
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var PwdTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverAddTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!

    
    //MARK: - 无关紧要的方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

