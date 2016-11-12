//
//  SAMLoginController.swift
//  SaleManager
//
//  Created by apple on 16/11/11.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

private let animationDuration = 0.7

class SAMLoginController: UIViewController {
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化设置UI
        setupUI()
        
        //记录原始数据
        logoOriBotDis = logoBotDis.constant
        logoAnimBotDis = (ScreenH - logoView.bounds.height) * 0.6
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
        
        //缩小logo 方便执行后续动画
        logoView.transform = CGAffineTransformMakeScale(0.001, 0.001)
    }
    
    //MARK: - 登录按钮点击
    @IBAction func loginBtnClick(sender: AnyObject) {
        loginAnim()
    }
    
    //点击界面退出编辑状态
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        endEditing()
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
    
    //MARK: - 所有动画集合
    ///动态回复log
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //动态回复logo
        UIView.animateWithDuration(1.0) {
            self.logoView.transform = CGAffineTransformIdentity
        }
    }
    ///服务器地址确认按钮点击后执行动画
    @IBAction func severBtnClick(sender: AnyObject) {
        endEditing()
        UIView.animateWithDuration(animationDuration) {
            self.loginView.transform = CGAffineTransformIdentity
            self.serverView.transform = CGAffineTransformIdentity
        }
    }
    ///返回服务器设置界面按钮点击动画
    @IBAction func loginBackBtnClick(sender: UIButton) {
        endEditing()
        UIView.animateWithDuration(animationDuration) {
            self.loginView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
            self.serverView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
        }
    }
    ///正在登陆中的动画
    private func loginAnim() {
        UIView.animateWithDuration(animationDuration, animations: {
            self.loginView.transform = CGAffineTransformMakeScale(0.001, 0.001)
            self.logoBotDis.constant = self.logoAnimBotDis
            self.view.layoutIfNeeded()
            }) { (_) in
                self.setupLoginCircleAnim()
        }
    }
    //MARK: - 调试所用
    @IBAction func liuclick(sender: AnyObject) {
        loginDefeatAnim()
    }
    @IBAction func qiclick(sender: AnyObject) {
        UIView.animateWithDuration(animationDuration, animations: { 
            self.logoView.transform = CGAffineTransformMakeScale(2.0, 2.0)
            self.logoView.alpha = 0.001
            }) { (_) in
                let alertVC = UIAlertController(title: "谢谢观赏", message: "君君真漂亮🙄😣😖😫", preferredStyle: .Alert)
                alertVC.addAction(UIAlertAction(title: "对呀对呀😍", style: .Default, handler: { (_) in
                    let arr = [1, 2, 3]
                    arr[4]
                }))
                alertVC.addAction(UIAlertAction(title: "屁😂", style: .Cancel, handler: { (_) in
                    let arr = [1, 2, 3]
                    arr[4]
                }))
                self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    //MARK: - 调试所用结束
    ///登陆失败的动画
    private func loginDefeatAnim() {
        UIView.animateWithDuration(animationDuration, animations: {
            self.loginAnimLayer!.removeFromSuperlayer()
            self.loginAnimLayer = nil
            self.loginView.transform = CGAffineTransformIdentity
            self.logoBotDis.constant = self.logoOriBotDis
            self.view.layoutIfNeeded()
        }) { (_) in
            print("登陆失败")
        }
    }
    
    //设置登陆圆圈动画
    private func setupLoginCircleAnim() {
        loginAnimLayer = CAReplicatorLayer()
        loginAnimLayer!.frame = logoView.bounds
        logoView.layer.addSublayer(loginAnimLayer!)
        
        //小圆圈layer
        let layer = CALayer()
        layer.transform = CATransform3DMakeScale(0, 0, 0)
        layer.position = CGPointMake(loginView.bounds.size.width / 2, 20)
        layer.bounds = CGRectMake(0, 0, 10, 10)
        layer.cornerRadius = 5
        layer.backgroundColor = UIColor.greenColor().CGColor;
        loginAnimLayer!.addSublayer(layer)
        
        //设置缩放动画
        let anim = CABasicAnimation()
        anim.keyPath = "transform.scale"
        anim.fromValue = 1
        anim.toValue = 0
        anim.repeatCount = MAXFLOAT
        let animDuration = 1
        anim.duration = CFTimeInterval(animDuration)
        layer.addAnimation(anim, forKey: nil)
        
        //添加layer
        let count : CGFloat = 20
        let angle = CGFloat(M_PI * 2) / count
        loginAnimLayer!.instanceCount = Int(count)
        loginAnimLayer!.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
        
        loginAnimLayer!.instanceDelay = Double(animDuration) / Double(count);
    }
    
    //MARK: - 懒加载集合
    private var logoOriBotDis: CGFloat = 0
    private var logoAnimBotDis: CGFloat = 0
    
    private var loginAnimLayer: CAReplicatorLayer?
    
    //MARK: - xib链接属性
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var PwdTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverAddTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoBotDis: NSLayoutConstraint!
    
    
    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func loadView() { //从XIB加载View,此方法不写在模拟器上正常，但真机调试会出现BUG
        view = NSBundle.mainBundle().loadNibNamed("SAMLoginController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

