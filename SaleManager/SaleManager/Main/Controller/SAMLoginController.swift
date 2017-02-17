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
///用于读写 密码 的Key
private let passWordStrKey = "passWordStrKey"
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
    fileprivate func checkSeverStr() {
        
        //读取 服务器地址 并对结果进行判断
        severAddStr = UserDefaults.standard.string(forKey: severAddStrKey)
        if severAddStr == nil { //没有服务器地址
            
            //修改形变，显示服务器地址填写界面
            loginView.transform = CGAffineTransform(translationX: ScreenW, y: 0)
            serverView.transform = CGAffineTransform(translationX: ScreenW, y: 0)
        }else { //有服务器地址
            
            //对serverAddTF设值，显示用户名界面
            serverAddTF.text = severAddStr
            
            //判断 是否有用户名（有用户名的前提是本地有服务器地址）
            userNameStr = UserDefaults.standard.string(forKey: userNameStrKey)
            if userNameStr != nil { //有用户名
                
                userNameTF.text = userNameStr
                remNameBtn.isSelected = true
            }
            //判断 是否有密码
            PWDStr = UserDefaults.standard.string(forKey: passWordStrKey)
            if PWDStr != nil { //有密码
                
                PwdTF.text = PWDStr
                remPwdBtn.isSelected = true
                loginBtn.isEnabled = true
            }
            
            //检查按钮状态
            checkBtnState(serverAddTF)
        }
    }
    
    //MARK: - 初始化设置UI
    fileprivate func setupUI() {
        
        //设置两个按钮的边角
        loginBtn.layer.cornerRadius = 7
        confirmBtn.layer.cornerRadius = 7
        
        //设置用户名 密码框的代理 并进行监听
        userNameTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), for: .editingChanged)
        PwdTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), for: .editingChanged)
        serverAddTF.addTarget(self, action: #selector(SAMLoginController.checkBtnState(_:)), for: .editingChanged)
        
        //缩小logo，方便执行后续动画
        logoView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        //禁止用户交互
        view.isUserInteractionEnabled = false
    }
    
    //MARK: - 界面交互点击事件处理
    //记住名字按钮点击
    @IBAction func remNameBtnClick(_ sender: AnyObject) {
        remNameBtn.isSelected = !remNameBtn.isSelected
        if !remNameBtn.isSelected {
            remPwdBtn.isSelected = false
        }
    }
    //记住密码按钮点击
    @IBAction func remPwdBtnClick(_ sender: UIButton) {
        remPwdBtn.isSelected = !remPwdBtn.isSelected
        if remPwdBtn.isSelected {
            remNameBtn.isSelected = true
        }
    }
    //登录按钮点击
    @IBAction func loginBtnClick(_ sender: AnyObject) {
        
        //记录用户名和密码
        userNameStr = userNameTF.text
        PWDStr = PwdTF.text
        
        UIView.animate(withDuration: 0.4, animations: {
            
                //退出编辑状态
                self.endEditing()
            }, completion: { (_) in
                //执行动画
                self.loginAnim()
        }) 
    }
    //点击界面退出编辑状态
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    //服务器地址确认按钮点击 和 返回服务器设置界面按钮点击 处理在下面动画项中
    
    //MARK: - 结束界面编辑状态
    fileprivate func endEditing() {
        view.endEditing(false)
    }
    
    //MARK: - 检查 确认、登录 按钮的状态
    func checkBtnState(_ textField: UITextField) {
        switch textField {
        case serverAddTF:
            confirmBtn.isEnabled = serverAddTF.hasText
        case userNameTF, PwdTF:
            loginBtn.isEnabled = userNameTF.hasText && PwdTF.hasText
        default :
            break
        }
    }
    
    //MARK: - 发送用户登录请求
    fileprivate func loginRequest() {
        
        //创建请求路径，请求参数
        let URLStr = String(format: "http://%@/handleLogin.ashx", severAddStr!)
        let parameters = ["userName": userNameStr!, "pwd": PWDStr!]
        
        //发送请求
        SAMNetWorker.sharedLoginNetWorker().get(URLStr, parameters: parameters, progress: nil, success: { (Task, json) in
            //判断返回数据状态
            let Json = json as! [String: AnyObject]
            let status = Json["head"]! as! [String: String]
            if status["status"]! == "fail" { //用户名或者密码错误
                
                self.showLoginDefeatInfo("用户名或者密码错误")
            } else { //登录成功
                
                //模型化数据
                let arr = Json["body"] as! [[String: String]]
                let dict = arr[0]
                let id = dict["id"]
                let employeeID = dict["employeeID"]
                let appPower = dict["appPower"]
                let deptID = dict["deptID"]
                let _ = SAMUserAuth.auth(id, employeeID: employeeID, appPower: appPower, deptID: deptID)
                
                //执行登录成功动画
                self.loginSuccessAnim()
            }
            }) { (Task, Error) in
                
                self.showLoginDefeatInfo("请检查网络")
        }
    }
    
    //MARK: - 登录出现错误时候提示的消息
    fileprivate func showLoginDefeatInfo(_ title: String!) {
        
        //执行动画
        loginDefeatAnim()
        
        //展示错误信息
        let _ = SAMHUD.showMessage(title, superView: view, hideDelay: animationDuration * 2, animated: true)
    }
    
    //MARK: - 所有动画集合
    ///进入界面动态恢复log
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //动态回复logo
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.logoView.transform = CGAffineTransform.identity
            }, completion: { (_) in
                
                //恢复页面用户交互
                self.view.isUserInteractionEnabled = true
        }) 
    }
    
    ///服务器地址确认按钮点击后执行动画
    @IBAction func severBtnClick(_ sender: AnyObject) {
        
        //退出界面编辑状态
        endEditing()
        
        if serverAddTF.text == "yzh@08890918" { //正确激活码
            //执行动画
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 7, options: .curveEaseIn, animations: {
                self.loginView.transform = CGAffineTransform.identity
                self.serverView.transform = CGAffineTransform.identity
            }, completion: nil)
            
            //赋值服务器地址
            severAddStr = "120.27.133.57:2017"
        }else { //错误激活码
            let _ = SAMHUD.showMessage("输入错误", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    ///返回服务器设置界面按钮点击动画
    @IBAction func loginBackBtnClick(_ sender: UIButton) {
        
        //退出界面编辑状态
        endEditing()
        
        //执行动画
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 7, options: .curveEaseIn, animations: {
            self.loginView.transform = CGAffineTransform(translationX: ScreenW, y: 0)
            self.serverView.transform = CGAffineTransform(translationX: ScreenW, y: 0)
            }, completion: nil)
    }
    
    ///正在登陆中的动画
    fileprivate func loginAnim() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.loginView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.logoBotDis.constant = self.logoAnimBotDis
            self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.setupLoginCircleAnim()
        }) 
    }
    
    ///设置登陆圆圈动画
    fileprivate func setupLoginCircleAnim() {
        loginAnimLayer = CAReplicatorLayer()
        loginAnimLayer!.frame = logoView.bounds
        logoView.layer.addSublayer(loginAnimLayer!)
        
        //小圆圈layer
        let layer = CALayer()
        layer.transform = CATransform3DMakeScale(0, 0, 0)
        layer.position = CGPoint(x: loginView.bounds.size.width / 2, y: 20)
        layer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        layer.cornerRadius = 5
        layer.backgroundColor = UIColor.green.cgColor
        loginAnimLayer!.addSublayer(layer)
        
        //设置缩放动画
        let anim = CABasicAnimation()
        anim.keyPath = "transform.scale"
        anim.fromValue = 1
        anim.toValue = 0
        anim.repeatCount = MAXFLOAT
        let animDuration = 1
        anim.duration = CFTimeInterval(animDuration)
        layer.add(anim, forKey: nil)
        
        //添加layer
        let count : CGFloat = 20
        let angle = CGFloat(M_PI * 2) / count
        loginAnimLayer!.instanceCount = Int(count)
        loginAnimLayer!.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        loginAnimLayer!.instanceDelay = Double(animDuration) / Double(count)
        
        //等待一秒后向服务器发送登录请求
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + Double(Int64(1000000000 * animationDuration)) / Double(NSEC_PER_SEC)) {
            self.loginRequest()
        }
    }
    
    ///登陆失败的动画
    fileprivate func loginDefeatAnim() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.loginAnimLayer!.removeFromSuperlayer()
            self.loginAnimLayer = nil
            self.loginView.transform = CGAffineTransform.identity
            self.logoBotDis.constant = self.logoOriBotDis
            self.view.layoutIfNeeded()
        }, completion: { (_) in
        }) 
    }
    
    ///登陆成功的动画
    fileprivate func loginSuccessAnim() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.logoView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.logoView.alpha = 0.001
        }, completion: { (_) in
            
            //存储登录数据
            UserDefaults.standard.set(self.severAddStr, forKey: severAddStrKey)
            if self.remNameBtn.isSelected == true {
                UserDefaults.standard.set(self.userNameStr, forKey: userNameStrKey)
            }else {
                UserDefaults.standard.set(nil, forKey: userNameStrKey)
            }
            if self.remPwdBtn.isSelected == true {
                UserDefaults.standard.set(self.PWDStr, forKey: passWordStrKey)
            }else {
                UserDefaults.standard.set(nil, forKey: passWordStrKey)
            }
            UserDefaults.standard.synchronize()
            
            //创建全局使用的netWorker单例
            let _ = SAMNetWorker.globalNetWorker(self.severAddStr!)
            
            //创建全局使用的上传图片netWorker单例
            let _ = SAMNetWorker.globalUnloadImageNetWorker(self.severAddStr!)
            
            //发出登录成功的通知
            NotificationCenter.default.post(name: Notification.Name(rawValue: LoginSuccessNotification), object: nil, userInfo: nil)
        }) 
    }
    
    //MARK: - 属性
    ///服务器地址
    fileprivate var severAddStr: String?
    ///用户名
    fileprivate var userNameStr: String?
    ///密码
    fileprivate var PWDStr: String?
    
    ///logoView的原始底部距离
    fileprivate var logoOriBotDis: CGFloat = 0
    ///logoView的动画底部距离
    fileprivate var logoAnimBotDis: CGFloat = 0
    ///登录中小绿圈动画Layer
    fileprivate var loginAnimLayer: CAReplicatorLayer?
    
    //MARK: - xib链接属性
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var PwdTF: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var remNameBtn: UIButton!
    @IBOutlet weak var remPwdBtn: UIButton!
    
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverAddTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoBotDis: NSLayoutConstraint!
    
    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMLoginController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

