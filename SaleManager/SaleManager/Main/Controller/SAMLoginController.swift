//
//  SAMLoginController.swift
//  SaleManager
//
//  Created by apple on 16/11/11.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

///用于读写 服务器地址 的Key
private let severAddStrKey = "severAddStrKey"
///用于读写 用户名 的Key
private let userNameStrKey = "userNameStrKey"
///登录界面用到动画的基础时长
private let animationDuration = 0.7

class SAMLoginController: UIViewController {
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //检查登录状态
        checkSeverStr()
        
        //初始化设置UI
        setupUI()
        
        //记录原始数据
        logoOriBotDis = logoBotDis.constant
        logoAnimBotDis = (ScreenH - logoView.bounds.height) * 0.6
    }
    
    //MARK: - 检查登录状态
    private func checkSeverStr() {
        
        //读取 服务器地址 并对结果进行判断
        severAddStr = NSUserDefaults.standardUserDefaults().stringForKey(severAddStrKey)
        if severAddStr == nil { //没有服务器地址
            
            //修改形变，显示服务器地址填写界面
            loginView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
            serverView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
        }else { //有服务器地址
            
            //对serverAddTF设值，显示用户名界面
            serverAddTF.text = severAddStr
            
            //判断 是否有用户名（有用户名的前提是本地有服务器地址）
            userNameStr = NSUserDefaults.standardUserDefaults().stringForKey(userNameStrKey)
            if userNameStr != nil { //有用户名
                
                userNameTF.text = userNameStr
                remNameBtn.selected = true
            }
            
            //检查按钮状态
            checkBtnState(serverAddTF)
        }
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
        
        //缩小logo，方便执行后续动画
        logoView.transform = CGAffineTransformMakeScale(0.001, 0.001)
        
        //禁止用户交互
        view.userInteractionEnabled = false
    }
    
    //MARK: - 界面交互点击事件处理
    
    //记住名字按钮点击
    @IBAction func remNameBtnClick(sender: AnyObject) {
        remNameBtn.selected = !remNameBtn.selected
    }
    
    //登录按钮点击
    @IBAction func loginBtnClick(sender: AnyObject) {
        
        //记录用户名和密码
        userNameStr = userNameTF.text
        PWDStr = PwdTF.text
        
        UIView.animateWithDuration(0.4, animations: {
            
                //退出编辑状态
                self.endEditing()
            }) { (_) in
                //执行动画
                self.loginAnim()
        }
    }
    
    //点击界面退出编辑状态
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        endEditing()
    }
    
    //服务器地址确认按钮点击 和 返回服务器设置界面按钮点击 处理在下面动画项中
    
    //MARK: - 结束界面编辑状态
    func endEditing() {
        view.endEditing(false)
    }
    
    //MARK: - 检查 确认、登录 按钮的状态
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
    
    //MARK: - 发送用户登录请求
    private func loginRequest() {
        
        //创建请求路径，请求参数
        let URLStr = String(format: "http://%@/handleLogin.ashx", severAddStr!)
        let parameters = ["userName": userNameStr!, "pwd": PWDStr!]
        
        //发送请求
        SAMNetWorker.sharedLoginNetWorker().GET(URLStr, parameters: parameters, progress: nil, success: { (Task, Json) in
            
            //判断返回数据状态
            let status = Json!["head"]! as! [String: String]
            if status["status"]! == "fail" { //用户名或者密码错误
                
                self.showLoginDefeatInfo("用户名或者密码错误")
            } else { //登录成功
                
                //模型化数据
                let arr = Json!["body"] as! [[String: String]]
                let dict = arr[0]
                let id = dict["id"]
                let employeeID = dict["employeeID"]
                let appPower = dict["appPower"]
                let deptID = dict["deptID"]
                SAMUserAuth.auth(id, employeeID: employeeID, appPower: appPower, deptID: deptID)
                
                //执行登录成功动画
                self.loginSuccessAnim()
            }
            }) { (Task, Error) in
                
                self.showLoginDefeatInfo("请检查网络")
        }
    }
    
    //MARK: - 登录出现错误时候提示的消息
    private func showLoginDefeatInfo(title: String!) {
        
        //执行动画
        loginDefeatAnim()
        
        //展示错误信息
        SAMHUD.showMessage(title, superView: view, hideDelay: animationDuration * 2, animated: true)
    }
    
    //MARK: - 所有动画集合
    
    ///进入界面动态恢复log
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //动态回复logo
        UIView.animateWithDuration(animationDuration, animations: {
            
            self.logoView.transform = CGAffineTransformIdentity
            }) { (_) in
                
                //恢复页面用户交互
                self.view.userInteractionEnabled = true
        }
    }
    
    ///服务器地址确认按钮点击后执行动画
    @IBAction func severBtnClick(sender: AnyObject) {
        
        //退出界面编辑状态
        endEditing()
        
        //记录服务器地址
        severAddStr = serverAddTF.text
        
        //执行动画
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 7, options: .CurveEaseIn, animations: {
            self.loginView.transform = CGAffineTransformIdentity
            self.serverView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    ///返回服务器设置界面按钮点击动画
    @IBAction func loginBackBtnClick(sender: UIButton) {
        
        //退出界面编辑状态
        endEditing()
        
        //执行动画
        UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 7, options: .CurveEaseIn, animations: {
            self.loginView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
            self.serverView.transform = CGAffineTransformMakeTranslation(ScreenW, 0)
            }, completion: nil)
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
    
    ///设置登陆圆圈动画
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
        layer.backgroundColor = UIColor.greenColor().CGColor
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
        loginAnimLayer!.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        loginAnimLayer!.instanceDelay = Double(animDuration) / Double(count)
        
        //向服务器发送登录请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000000000 * animationDuration)), dispatch_get_global_queue(0, 0)) {
            self.loginRequest()
        }
    }
    
    ///登陆失败的动画
    private func loginDefeatAnim() {
        UIView.animateWithDuration(animationDuration, animations: {
            self.loginAnimLayer!.removeFromSuperlayer()
            self.loginAnimLayer = nil
            self.loginView.transform = CGAffineTransformIdentity
            self.logoBotDis.constant = self.logoOriBotDis
            self.view.layoutIfNeeded()
        }) { (_) in
        }
    }
    
    ///登陆成功的动画
    private func loginSuccessAnim() {
        UIView.animateWithDuration(animationDuration, animations: {
            self.logoView.transform = CGAffineTransformMakeScale(2.0, 2.0)
            self.logoView.alpha = 0.001
        }) { (_) in
            
            //存储登录数据
            NSUserDefaults.standardUserDefaults().setObject(self.severAddStr, forKey: severAddStrKey)
            if self.remNameBtn.selected == true {
                NSUserDefaults.standardUserDefaults().setObject(self.userNameStr, forKey: userNameStrKey)
            }else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: userNameStrKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            
            //创建全局使用的netWorker单例
            SAMNetWorker.globalNetWorker(self.severAddStr!)
            
            //发出登录成功的通知
            NSNotificationCenter.defaultCenter().postNotificationName(LoginSuccessNotification, object: nil, userInfo: nil)
        }
    }
    
    //MARK: - 属性
    ///服务器地址
    private var severAddStr: String?
    ///用户名
    private var userNameStr: String?
    ///密码
    private var PWDStr: String?
    
    ///logoView的原始底部距离
    private var logoOriBotDis: CGFloat = 0
    ///logoView的动画底部距离
    private var logoAnimBotDis: CGFloat = 0
    ///登录中小绿圈动画Layer
    private var loginAnimLayer: CAReplicatorLayer?
    
    //MARK: - xib链接属性
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var PwdTF: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var remNameBtn: UIButton!
    
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverAddTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoBotDis: NSLayoutConstraint!
    
    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("SAMLoginController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

