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
    func codeScandidScan(codeScanner: LXMCodeViewController, result: String?)
}

///扫描线一次动画
private let scanLineAnimtionDuration = 2.0

class LXMCodeViewController: UIViewController {

    /// 代理
    weak var delegate: LXMCodeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //监听 UIApplicationWillEnterForegroundNotification 通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LXMCodeViewController.viewwillShowFromBackground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    //MARK: - 初始化UI
    private func setupUI() {
        
        //设置导航条
        navigationItem.title = "二维码"
        
        //设置扫描框顶部距离
        containerViewTopDis.constant = navigationController!.navigationBar.bounds.maxY + 100
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //开始扫描
        self.startScan()
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //虚化导航条，底部条
        UIView.animateWithDuration(0.6, animations: {
            
            self.navigationController?.navigationBar.subviews[0].alpha = 0.4
            self.tabBarController?.tabBar.subviews[0].alpha = 0.4
        }) { (_) in
        }
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.subviews[0].alpha = 1
        self.tabBarController?.tabBar.subviews[0].alpha = 1
        self.stopScan()
    }
    
    //MARK: - 开始扫描
    private func startScan() {
        
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
        deviceOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        //设置二维码区域
        let containerViewX = containerView.frame.origin.x
        let containerViewY = containerView.frame.origin.y
        let containerViewWH = containerView.bounds.width
        deviceOutput.rectOfInterest = CGRectMake(containerViewY / ScreenH, containerViewX / ScreenW, containerViewWH / ScreenH, containerViewWH / ScreenW)
        
        //添加预览图层
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        
        //开始扫描线动画
        startScanLineAnimation()
        
        //开始扫描
        session.startRunning()
    }
    
    //MARK: - 扫描线动画
    private func startScanLineAnimation() {
        
        //还原位置
        scanLineTopDis.constant = 0
        view.layoutIfNeeded()
        
        UIView.animateWithDuration(scanLineAnimtionDuration) {
            //修改约束
            self.scanLineTopDis.constant = self.containerView.bounds.height
            
            //设置重复次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            //强制更新
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - 停止扫描
    private func stopScan() {
        if session.running {
            session.stopRunning()
        }
        stopAnimation()
    }
    
    //MARK: - 停止动画
    private func stopAnimation() {
        view.layer.removeAllAnimations()
    }
    
    //MARK: - 后台进入APP直接显示该界面时调用
    func viewwillShowFromBackground () {
        viewWillAppear(true)
    }
    
    //MARK: - 懒加载集合
    /// 会话
    private lazy var session = AVCaptureSession()
    
    /// 输入设备
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        guard let deviceInput = try? AVCaptureDeviceInput(device: device!) else {
            return nil
        }
        return deviceInput
    }()
    
    /// 输出设备
    private lazy var deviceOutput = AVCaptureMetadataOutput()
    
    /// 预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.frame = UIScreen.mainScreen().bounds
        return previewLayer
    }()
    
    //MARK: - xib连接属性
    @IBOutlet weak var containerViewTopDis: NSLayoutConstraint!
    @IBOutlet weak var scanLineTopDis: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scanLineImage: UIImageView!
    
    //MARK: - 其他方法
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("LXMCodeViewController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension LXMCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        //没有数据直接返回
        if metadataObjects.count == 0 || metadataObjects == nil {
            return
        }
        
        //处理数据
        if metadataObjects.count > 0 && metadataObjects != nil {
            
            let metadataObj = metadataObjects.last as? AVMetadataMachineReadableCodeObject
            
            if (metadataObj?.type == AVMetadataObjectTypeQRCode) && (metadataObj?.isKindOfClass(AVMetadataMachineReadableCodeObject.self))! {
                
                let result = metadataObjects.last?.stringValue
                
                //停止扫描
                stopScan()
                
                //给代理传值， 下面一句已经包含了responseto
                delegate?.codeScandidScan(self, result: result)
                
                let alert = UIAlertController(title: "成功", message: result, preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
                    self.startScan()
                }))
                presentViewController(alert, animated: true, completion: nil)
                
                //TODO: - 扫描成功后给个提示音后再跳转界面
                
            }
        }
    }
}
