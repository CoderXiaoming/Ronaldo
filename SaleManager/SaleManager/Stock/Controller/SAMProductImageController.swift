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
    var stockProductModel: SAMStockProductModel?
    
    ///对外提供的类工厂方法
    class func instance(stockModel: SAMStockProductModel) -> SAMProductImageController {
        let vc = SAMProductImageController()
        vc.stockProductModel = stockModel
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化UI
        setupUI()
        
        //添加右上角按钮
        setupRightItem()
    }

    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        //设置产品图片
        if stockProductModel?.imageUrl1 != "" {
            productImage?.sd_setImage(with: URL.init(string: stockProductModel!.imageUrl1), placeholderImage: UIImage(named: "photo_loadding"))
        }else {
            productImage?.image = UIImage(named: "photo_loadding")
        }
        
        //设置主标题
        navigationItem.title = "产品图片"
        
        //添加scrollView 设置frame
        let height = ScreenH - navigationController!.navigationBar.frame.maxY
        scrollView?.frame = CGRect(x: 0, y: 0, width: ScreenW, height: height)
        view.addSubview(scrollView!)
        
        //设置产品图片尺寸
        let y = (scrollView!.bounds.height - ScreenW) * 0.5
        productImage?.frame = CGRect(x: 0, y: y, width: ScreenW, height: ScreenW)
        
        //添加产品图片到scrollView
        scrollView?.addSubview(productImage!)
    }
    
    //MARK: - 添加右上角按钮，有权限才添加
    fileprivate func setupRightItem() {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(SAMProductImageController.moreInfoBtnClick), for: .touchUpInside)
        btn.setImage(UIImage(named: "productImageMoreOperetionImage"), for: UIControlState())
        btn.sizeToFit()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //设置hudView
        setupHUDView()
        
        //设置oprationView
        setupOperationView()
    }
    
    //MARK: - 初始化设置HUDView
    fileprivate func setupHUDView() {
        
        //添加到主窗口上
        hudView = UIView()
        hudView!.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        KeyWindow!.addSubview(hudView!)
        
        //设置frame
        hudView?.frame = UIScreen.main.bounds
        
        hudView?.alpha = 0.00001
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SAMProductImageController.hideOperationView))
        hudView?.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - 初始化设置OperationView
    fileprivate func setupOperationView() {
        
        //添加operationView
        operationView = SAMProductImageOpetationView.instacne()
        operationView?.delegate = self
        KeyWindow!.addSubview(operationView!)
        
        //设置frame
        let y = ScreenH - OperationViewHeight
        operationView?.frame = CGRect(x: 0, y: y, width: ScreenW, height: OperationViewHeight)
        
        //设置初始隐藏transform
        operationView?.transform = CGAffineTransform(translationX: 0, y: OperationViewHeight)
    }
    
    //MARK: - 导航栏右上角按钮点击事件
    func moreInfoBtnClick() {
        
        //展示operationView
        showOperationView()
    }
    
    //MARK: - 展示operationView
    func showOperationView() {
        UIView.animate(withDuration: OperationViewShowHideAnimationDuration, animations: {
            self.operationView?.transform = CGAffineTransform.identity
            self.hudView?.alpha = 1
        }, completion: { (_) in
        }) 
    }
    
    //MARK: - 隐藏operationView
    func hideOperationView() {
        UIView.animate(withDuration: OperationViewShowHideAnimationDuration, animations: {
            self.operationView?.transform = CGAffineTransform(translationX: 0, y: OperationViewHeight)
            self.hudView?.alpha = 0.0001
        }, completion: { (_) in
        }) 
    }
    
    //MARK: - 展示图片选择界面
    fileprivate func showImagePickerController(_ type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            //设置类型
            imagePickerController?.sourceType = type
            
            //展示界面
            navigationController!.present(imagePickerController!, animated: true, completion: {
            })
        }
    }
    
    //MARK: - 保存照片后的回调方法
    func didFinishSaveImageWithError(_ image: UIImage?, error: NSError?, contextInfo: AnyObject) {
        if error == nil {
            let _ = SAMHUD.showMessage("保存成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }else {
            let _ = SAMHUD.showMessage("保存失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 上传图片
    fileprivate func unloadProductImage(_ image: UIImage) {
        
        //展示提示信息
        let hud = SAMHUD.showAdded(to: KeyWindow!, animated: true)!
        hud.labelText = NSLocalizedString("正在上传...", comment: "HUD loading title")
        
        //创建请求参数
        let patameters = ["codeID": stockProductModel!.codeID, "imageIndex": 1] as [String : Any]
        
        //子线程发送上传请求
        SAMNetWorker.sharedUnloadImageNetWorker().post("uploadImage.ashx", parameters: patameters, constructingBodyWith: { (formData) in
            
            //获取图片数据
            let data = UIImageJPEGRepresentation(image, 1.0)!
            formData.appendPart(withFileData: data, name: "1", fileName: "image.jpg", mimeType: "image/jpg")
            
            }, progress: { (progress) in
                
            }, success: {[weak self] (Task, json) in
                
                let Json = json as! [String: AnyObject]
                
                //回到主线程
                DispatchQueue.main.async(execute: {
                    
                    //获取返回信息
                    let messageDict = Json["head"] as! [String: String]
                    
                    if messageDict["status"] == "success" { //上传成功
                        
                        //重新设置数据模型
                        let urlDict = Json["body"] as! [[String: String]]
                        
                        let model = self!.stockProductModel
                        model?.thumbUrl1 = urlDict[0]["thumbUrl"]!
                        model?.imageUrl1 = urlDict[0]["imageUrl"]!
                        self!.stockProductModel = model
                        
                        //设置图片
                        self!.productImage?.sd_setImage(with: URL.init(string: self!.stockProductModel!.imageUrl1))
                        
                        //隐藏loadingHUD
                        hud.hide(true)
                        
                        //提示用户上传成功
                        let _ = SAMHUD.showMessage("上传成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                        
                        //记录上传状态
                        SAMStockHasUnloadProductImage = true
                    }else { //上传失败
                        
                        //隐藏loadingHUD
                        hud.hide(true)
                        
                        let _ = SAMHUD.showMessage("上传失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                    }
                })
        }) { (Task, Error) in
            
            //隐藏loadingHUD,展示提示信息
            DispatchQueue.main.async(execute: {
                
                hud.hide(true)
                let _ = SAMHUD.showMessage("网络错误", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            })
        }
    }
    
    //MARK: - 懒加载属性
    ///背景scrollview
    fileprivate lazy var scrollView: UIScrollView? = {
        let scrollView = UIScrollView()
        
        scrollView.backgroundColor = UIColor(red: 241 / 255.0, green: 240 / 255.0, blue: 255 / 255.0, alpha: 1.0)
        
        //设置缩放比例
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        
        //设置代理
        scrollView.delegate = self
        
        return scrollView
    }()
    
    ///展示的大图
    fileprivate lazy var productImage: UIImageView? = UIImageView()
    
    ///oprationView
    fileprivate var operationView: SAMProductImageOpetationView?
    
    ///HUDView
    fileprivate var hudView: UIView?
    
    ///图片选择器
    fileprivate lazy var imagePickerController: UIImagePickerController? = {
        let imageVC = UIImagePickerController()
        imageVC.allowsEditing = true
        imageVC.delegate = self
        return imageVC
    }()

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
}

//MARK: - UIScrollViewDelegate
extension SAMProductImageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return productImage
    }
    
    //确保 productImage 在 scrollView的中间
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
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
        showImagePickerController(UIImagePickerControllerSourceType.camera)
    }
    func opetationViewDidClickSelectBtn() {
        
        //隐藏operationView
        hideOperationView()
        
        //展示控制器界面
        showImagePickerController(UIImagePickerControllerSourceType.photoLibrary)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //获取图片
        let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        
        //退出图片选择控制器控制器
        picker.dismiss(animated: true) {
        }
        
        //如果图片不为空，上传图片
        if selectedImage != nil {
            unloadProductImage(selectedImage!)
        }
    }
}
