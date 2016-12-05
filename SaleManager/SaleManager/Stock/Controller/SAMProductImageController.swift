//
//  SAMProductImageController.swift
//  SaleManager
//
//  Created by apple on 16/12/1.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

///operationView的高度
private let OperationViewHeight: CGFloat = 187.0
///operationView的动画时长
private let OperationViewShowHideAnimationDuration = 0.3

class SAMProductImageController: UIViewController {

    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            //加载产品图片控制器的大图
            if stockProductModel?.imageURL1 != nil {
                productImage?.sd_setImageWithURL(stockProductModel?.imageURL1!, placeholderImage: nil)
            }else {
                //TODO: 没有图片展示提示图片
            }
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化UI
        setupUI()
        
        //根据权限添加右上角按钮
        if hasTP_SZ_Auth {
            setupRightItem()
        }
    }

    //MARK: - 初始化UI
    private func setupUI() {
        
        //设置主标题
        navigationItem.title = "产品图片"
        
        //添加scrollView 设置frame
        let height = ScreenH - navigationController!.navigationBar.frame.maxY
        scrollView?.frame = CGRect(x: 0, y: 0, width: ScreenW, height: height)
        view.addSubview(scrollView!)
        
        //设置产品图片尺寸
        let y = (scrollView!.bounds.height - ScreenW) * 0.5
        productImage?.frame = CGRectMake(0, y, ScreenW, ScreenW)
        
        //添加产品图片到scrollView
        scrollView?.addSubview(productImage!)
    }
    
    //MARK: - 添加右上角按钮
    private func setupRightItem() {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(SAMProductImageController.moreInfoBtnClick), forControlEvents: .TouchUpInside)
        btn.setTitle("更多操作", forState: .Normal)
        btn.sizeToFit()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasTP_SZ_Auth {
            //设置hudView
            setupHUDView()
            
            //设置oprationView
            setupOperationView()
        }
    }
    
    
    
    //MARK: - 初始化设置HUDView
    private func setupHUDView() {
        
        //添加到主窗口上
        hudView = UIView()
        hudView!.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        KeyWindow!.addSubview(hudView!)
        
        //设置frame
        hudView?.frame = UIScreen.mainScreen().bounds
        
        hudView?.alpha = 0.00001
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMProductImageController.hideOperationView))
        hudView?.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - 初始化设置OperationView
    private func setupOperationView() {
        
        //添加operationView
        operationView = SAMProductImageOpetationView.instacne()
        operationView?.delegate = self
        KeyWindow!.addSubview(operationView!)
        
        //设置frame
        let y = ScreenH - OperationViewHeight
        operationView?.frame = CGRect(x: 0, y: y, width: ScreenW, height: OperationViewHeight)
        
        //设置初始隐藏transform
        operationView?.transform = CGAffineTransformMakeTranslation(0, OperationViewHeight)
    }
    
    //MARK: - 导航栏右上角按钮点击事件
    func moreInfoBtnClick() {
        
        //展示operationView
        showOperationView()
    }
    
    //MARK: - 展示operationView
    func showOperationView() {
        UIView.animateWithDuration(OperationViewShowHideAnimationDuration, animations: {
            self.operationView?.transform = CGAffineTransformIdentity
            self.hudView?.alpha = 1
        }) { (_) in
        }
    }
    
    //MARK: - 隐藏operationView
    func hideOperationView() {
        UIView.animateWithDuration(OperationViewShowHideAnimationDuration, animations: {
            self.operationView?.transform = CGAffineTransformMakeTranslation(0, OperationViewHeight)
            self.hudView?.alpha = 0.0001
        }) { (_) in
        }
    }
    
    //MARK: - 展示图片选择界面
    private func showImagePickerController(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            //设置类型
            imagePickerController?.sourceType = type
            
            //展示界面
            navigationController!.presentViewController(imagePickerController!, animated: true, completion: {
            })
        }
    }
    
    //MARK: - 保存照片后的回调方法
    func didFinishSaveImageWithError(image: UIImage?, error: NSError?, contextInfo: AnyObject) {
        if error == nil {
            SAMHUD.showMessage("保存成功", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
        }else {
            SAMHUD.showMessage("保存失败", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 上传图片
    private func unloadProductImage(image: UIImage) {
        
        //展示提示信息
        let hud = SAMHUD.showHUDAddedTo(view, animated: true)
        hud.labelText = NSLocalizedString("正在上传头像", comment: "HUD loading title")
        
        //创建请求参数
        let patameters = ["codeID": stockProductModel!.codeID!, "imageIndex": 1]
        
        //子线程发送上传请求
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            SAMNetWorker.sharedUnloadImageNetWorker().POST("uploadImage.ashx", parameters: patameters, constructingBodyWithBlock: { (formData) in
                
                //获取图片数据
                let data = UIImageJPEGRepresentation(image, 1.0)!
                formData.appendPartWithFileData(data, name: "1", fileName: "image.jpg", mimeType: "image/jpg")
                
                }, progress: { (progress) in
                    
                }, success: {[weak self] (Task, Json) in
                    
                    //回到主线程
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //获取返回信息
                        let messageDict = Json!["head"] as! [String: String]
                        
                        if messageDict["status"] == "success" { //上传成功
                            
                            //重新设置数据模型
                            let urlDict = Json!["body"] as! [[String: String]]
                            
                            let model = self!.stockProductModel
                            model?.thumbUrl1 = urlDict[0]["thumbUrl"]
                            model?.imageUrl1 = urlDict[0]["imageUrl"]
                            
                            self!.stockProductModel = model
                            
                            //隐藏loadingHUD
                            hud.hide(true)
                            
                            //提示用户上传成功
                            SAMHUD.showMessage("上传成功", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                            
                            //记录上传状态
                            SAMStockHasUnloadProductImage = true
                        }else { //上传失败
                            
                            //隐藏loadingHUD
                            hud.hide(true)
                            
                            SAMHUD.showMessage("上传失败", superView: self!.view, hideDelay: SAMHUDNormalDuration, animated: true)
                        }
                    })
            }) { (Task, Error) in
                
                //隐藏loadingHUD,展示提示信息
                dispatch_async(dispatch_get_main_queue(), {
                    
                    hud.hide(true)
                    SAMHUD.showMessage("网络错误", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                })
            }
        }
    }
    
    //MARK: - viewDidDisappear
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //恢复scrollView的缩放
        scrollView?.zoomScale = 1
        
        if hasTP_SZ_Auth {
            //移除operationView、hudView
            operationView?.removeFromSuperview()
            hudView?.removeFromSuperview()
            operationView = nil
            hudView = nil
        }
    }
    
    //MARK: - 懒加载属性
    ///背景scrollview
    private lazy var scrollView: UIScrollView? = {
        let scrollView = UIScrollView()
        
        scrollView.backgroundColor = UIColor.blackColor()
        
        //设置缩放比例
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        
        //设置代理
        scrollView.delegate = self
        
        return scrollView
    }()
    
    ///展示的大图
    private lazy var productImage: UIImageView? = UIImageView()
    
    ///新增图片权限
    private lazy var hasTP_SZ_Auth: Bool = SAMUserAuth.checkAuth(["TP_SZ_APP"])
    
    ///oprationView
    private var operationView: SAMProductImageOpetationView?
    
    ///HUDView
    private var hudView: UIView?
    
    ///图片选择器
    private lazy var imagePickerController: UIImagePickerController? = {
        let imageVC = UIImagePickerController()
        imageVC.allowsEditing = true
        imageVC.delegate = self
        return imageVC
    }()

    //MARK: - 其他方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UIScrollViewDelegate
extension SAMProductImageController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return productImage
    }
    
    //确保 productImage 在 scrollView的中间
    func scrollViewDidZoom(scrollView: UIScrollView) {
        var centerX = scrollView.center.x
        var centerY = scrollView.center.y
        
        centerX = scrollView.contentSize.width > scrollView.frame.width ? scrollView.contentSize.width / 2 : centerX
        centerY = scrollView.contentSize.height > scrollView.frame.height ? scrollView.contentSize.height / 2 : centerY
        
        productImage!.center = CGPoint(x: centerX, y: centerY)
    }
}

//MARK: - SAMProductImageOpetationViewDelegate
extension SAMProductImageController: SAMProductImageOpetationViewDelegate {
    func opetationViewDidClickCameraBtn() {
        
        //隐藏operationView
        hideOperationView()
        
        //展示控制器界面
        showImagePickerController(UIImagePickerControllerSourceType.Camera)
    }
    func opetationViewDidClickSelectBtn() {
        
        //隐藏operationView
        hideOperationView()
        
        //展示控制器界面
        showImagePickerController(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    func opetationViewDidClickSaveBtn() {
        
        //隐藏operationView
        hideOperationView()
        
        //保存照片
        UIImageWriteToSavedPhotosAlbum(productImage!.image!, self, #selector(SAMProductImageController.didFinishSaveImageWithError(_:error:contextInfo:)), nil)
    }
    func opetationViewDidClickCancelBtn() {
        
        //隐藏operationView
        hideOperationView()
    }
}

//MARK: - UIImagePickerControllerDelegate
extension SAMProductImageController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //获取图片
        let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        
        //退出图片选择控制器控制器
        picker.dismissViewControllerAnimated(true) {
        }
        
        //如果图片不为空，上传图片
        if selectedImage != nil {
            unloadProductImage(selectedImage!)
        }
    }
}
