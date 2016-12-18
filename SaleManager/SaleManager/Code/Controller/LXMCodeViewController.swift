//
//  LXMCodeViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import AVFoundation

protocol LXMCodeViewControllerDelegate: NSObjectProtocol {
    func codeScandidScan(_ codeScanner: LXMCodeViewController, result: String?)
}

///扫描线一次动画
private let scanLineAnimtionDuration = 2.0

class LXMCodeViewController: UIViewController {

    /// 代理
    weak var delegate: LXMCodeViewControllerDelegate?
    
    ///对外提供的类工厂方法
    class func instance() -> LXMCodeViewController {
        return LXMCodeViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //监听 UIApplicationWillEnterForegroundNotification 通知
        NotificationCenter.default.addObserver(self, selector: #selector(LXMCodeViewController.viewwillShowFromBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        //设置导航条
        navigationItem.title = "二维码"
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //开始扫描
        self.startScan()
    }
    
    //MARK: - viewWillDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //停止扫描
        self.stopScan()
    }
    
    //MARK: - 开始扫描
    fileprivate func startScan() {
        
        //开始扫描线动画
        startScanLineAnimation()
        
        //判断是不是第一次扫描
        if session.inputs.count > 0 && session.inputs.count > 0 {
            session.startRunning()
        }
        
        // 判断输入能否添加到会话中
        if !session.canAddInput(deviceInput) {
            return
        }
        
        // 盘算输出能否添加到会话中
        if !session.canAddOutput(deviceOutput) {
            return
        }
        
        // 添加输入，输出
        session.addInput(deviceInput!)
        session.addOutput(deviceOutput)
        
        // 设置输出能够解析的数据类型
        deviceOutput.metadataObjectTypes = deviceOutput.availableMetadataObjectTypes
        deviceOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //设置二维码区域
        let containerViewX = containerView.frame.origin.x
        let containerViewY = containerView.frame.origin.y
        let containerViewWH = containerView.bounds.width
        deviceOutput.rectOfInterest = CGRect(x: containerViewY / ScreenH, y: containerViewX / ScreenW, width: containerViewWH / ScreenH, height: containerViewWH / ScreenW)
        
        //添加预览图层
        view.layer.insertSublayer(previewLayer, at: 0)
        
        //开始扫描
        session.startRunning()
    }
    
    //MARK: - 扫描线动画
    fileprivate func startScanLineAnimation() {
        
        //还原位置
        scanLineTopDis.constant = 0
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: scanLineAnimtionDuration, animations: {
            //修改约束
            self.scanLineTopDis.constant = self.containerView.bounds.height
            
            //设置重复次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            //强制更新
            self.view.layoutIfNeeded()
        }) 
    }
    
    //MARK: - 停止扫描
    fileprivate func stopScan() {
        if session.isRunning {
            session.stopRunning()
        }
        stopAnimation()
    }
    
    //MARK: - 停止动画
    fileprivate func stopAnimation() {
        view.layer.removeAllAnimations()
    }
    
    //MARK: - 后台进入APP直接显示该界面时调用
    func viewwillShowFromBackground () {
        viewWillAppear(true)
    }
    
    //MARK: - 懒加载集合
    /// 会话
    fileprivate lazy var session = AVCaptureSession()
    
    /// 输入设备
    fileprivate lazy var deviceInput: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!) else {
            return nil
        }
        return deviceInput
    }()
    
    /// 输出设备
    fileprivate lazy var deviceOutput = AVCaptureMetadataOutput()
    
    /// 预览图层
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer?.frame = UIScreen.main.bounds
        return previewLayer!
    }()
    
    //MARK: - xib连接属性
    @IBOutlet weak var scanLineTopDis: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scanLineImage: UIImageView!
    
    //MARK: - 其他方法
    fileprivate init() { //重写该方法，为单例服务
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
        view = Bundle.main.loadNibNamed("LXMCodeViewController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LXMCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //没有数据直接返回
        if metadataObjects.count == 0 || metadataObjects == nil {
            return
        }
        
        //处理数据
        if metadataObjects.count > 0 && metadataObjects != nil {
            
            let metadataObj = metadataObjects.last as? AVMetadataMachineReadableCodeObject
            
            if (metadataObj?.type == AVMetadataObjectTypeQRCode) && (metadataObj?.isKind(of: AVMetadataMachineReadableCodeObject.self))! {
                
                //获取扫面字符串
                let result = metadataObj!.stringValue
                
                //停止扫描
                stopScan()
                
                //给代理传值， 下面一句已经包含了responseto
                delegate?.codeScandidScan(self, result: result)
                
                let alert = UIAlertController(title: "成功", message: result, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    self.startScan()
                }))
                present(alert, animated: true, completion: nil)
                
                //TODO: - 扫描成功后给个提示音后再跳转界面
                
            }
        }
    }
}
