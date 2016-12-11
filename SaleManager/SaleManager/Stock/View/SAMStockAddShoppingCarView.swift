//
//  SAMStockAddShoppingCarView.swift
//  SaleManager
//
//  Created by apple on 16/12/10.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

///键盘展示时图片宽度
private let keyboardShowingProductImageWidth: CGFloat = 60
///键盘展示时购物车控件的高度
private let keyboardShowingShoppingCarFrame = CGRect(x: 0, y: ScreenH - 550, width: ScreenW, height: 550)

///键盘隐藏时图片宽度
private let keyboardHidedProductImageWidth: CGFloat = 90
///键盘隐藏时购物车控件的高度
private let keyboardHidedShoppingCarFrame = CGRect(x: 0, y: ScreenH - 350, width: ScreenW, height: 350)

protocol SAMStockAddShoppingCarViewDelegate: NSObjectProtocol {
    func shoppingCarViewDidClickDismissButton()
    func shoppingCarViewDidClickTextField(textField: UITextField)
    func shoppingCarViewDidClickEnsureButton()
}

class SAMStockAddShoppingCarView: UIView {

    ///代理
    weak var delegate: SAMStockAddShoppingCarViewDelegate?
    
    ///接收的数据模型
    var stockProductModel: SAMStockProductModel? {
        didSet{
            //设置产品名称
            if stockProductModel!.productIDName != "" {
                productNumberLabel.text = stockProductModel!.productIDName
            }else {
                productNumberLabel.text = "---"
            }
            
            //设置标题匹数
            pishuLabel.text = String(format: "%d", stockProductModel!.countP)
            
            //设置标题米数
            mishuLabel.text = String(format: "%.1f", stockProductModel!.countM)
            
            //设置最大匹数提醒label
            pishuMaxLabel.text = String(format: "最大%d匹！", stockProductModel!.countP)
            pishuMaxLabel.alpha = 0.0001
            pishuMaxLabel.transform = CGAffineTransformIdentity
            
            //设置最大米数提醒label
            mishuMaxLabel.text = String(format: "最大%.1f米！", stockProductModel!.countM)
            mishuMaxLabel.alpha = 0.0001
            mishuMaxLabel.transform = CGAffineTransformIdentity
            
            //设置四个文本框
            pishuTF.text = "0"
            mishuTF.text = "1"
            priceTF.text = "0"
            remarkTF.text = ""
        }
    }
    
    //MARK: - 对外提供的类方法
    class func carView() -> SAMStockAddShoppingCarView {
        let view = NSBundle.mainBundle().loadNibNamed("SAMStockAddShoppingCarView", owner: nil, options: nil)![0] as! SAMStockAddShoppingCarView
        return view
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置产品图片边框
        productImage.layer.borderWidth = 2
        productImage.layer.borderColor = UIColor.whiteColor().CGColor
        productImage.layer.cornerRadius = 5
        
        //设置textField代理，监听方法
        let arr = NSArray(array: [pishuTF, mishuTF, priceTF, remarkTF])
        arr.enumerateObjectsUsingBlock { (obj, index, _) in
            let textField = obj as! UITextField
            textField.delegate = self
            
            if textField != remarkTF {
                textField.addTarget(self, action: #selector(SAMStockAddShoppingCarView.textFieldDidChangeValue(_:)), forControlEvents: .EditingChanged)
            }
        }
        
        //监听键盘弹出通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAMStockAddShoppingCarView.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //TODO: 设置确定按钮的各种状态照片
    }
    
    //MARK: - 对外提供即将展示控件调用的方法
    func shoppingCarViewWillShow(stockProductImage: UIImage, productModel: SAMStockProductModel) {
        
        //赋值图片
        productImage.image = stockProductImage
        
        //赋值数据模型
        stockProductModel = productModel
        
        //设置确认按钮不可用
        ensureButton.enabled = false
    }
    
    //MARK: - textField监听的方法
    func textFieldDidChangeValue(textField: UITextField) {
        
        
        /******************  pishuTF  ******************/
        //如果当前是匹数textField，而且有值
        if textField == pishuTF && textField.hasText() {
            let pishuStr = NSString(string: textField.text!)
            let pishu = pishuStr.integerValue
            
            //如果匹数大于库存，则将文本框设置为最大匹数
            if pishu > stockProductModel!.countP {
                
                //修改文本内容
                textField.text = String(format: "%d", stockProductModel!.countP)
                
                //展示提醒内容
                showOrHideRemindLabel(true, label: pishuMaxLabel)
            }else {
                //隐藏提醒内容
                showOrHideRemindLabel(false, label: pishuMaxLabel)
            }
        }
        //如果当前是匹数textField，但没有值
        if textField == pishuTF && !textField.hasText() {
            
            //隐藏提醒内容
            showOrHideRemindLabel(false, label: pishuMaxLabel)
        }
        
        /******************  mishuTF  ******************/
        //如果当前是米数textField，而且有值
        if textField == mishuTF && textField.hasText() {
            let mishuStr = NSString(string: textField.text!)
            let mishu = mishuStr.doubleValue
            
            //如果匹数大于库存，则将文本框设置为最大匹数
            if mishu > stockProductModel!.countM {
                
                //修改文本内容
                textField.text = String(format: "%.1f", stockProductModel!.countM)
                
                //展示提醒内容
                showOrHideRemindLabel(true, label: mishuMaxLabel)
            }else {
                //隐藏提醒内容
                showOrHideRemindLabel(false, label: mishuMaxLabel)
            }
        }
        //如果当前是匹数textField，但没有值
        if textField == pishuTF && !textField.hasText() {
            
            //隐藏提醒内容
            showOrHideRemindLabel(false, label: pishuMaxLabel)
        }
        
        //设置确认按钮可用性
        if pishuTF.hasText() && mishuTF.hasText() && priceTF.hasText() {
            ensureButton.enabled = true
        }else {
            ensureButton.enabled = false
        }
    }
    
    //MARK: - 展示或隐藏提示文本
    private func showOrHideRemindLabel(show: Bool, label: UILabel) {
    
        //展示label
        if show {
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                    label.alpha = 1
                    label.transform = CGAffineTransformMakeTranslation(-label.frame.width, 0)
                }, completion: { (_) in
            })
        }else {
            
            //隐藏label
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: {
                label.alpha = 0.00001
                label.transform = CGAffineTransformIdentity
                }, completion: { (_) in
            })
        }
    }
    
    //MARK: - 结束当前第一响应者textField
    func endFirstTextFieldEditing() {
        if firstTF != nil {
            firstTF?.resignFirstResponder()
        }
    }
    
    //MARK: - 清空所有textField
    private func clearAllTextField() {
        
        let arr = NSArray(array: [pishuTF, mishuTF, priceTF, remarkTF])
        arr.enumerateObjectsUsingBlock { (obj, index, _) in
            let textField = obj as! UITextField
            textField.text = ""
        }
    }
    
    //MARK: - 键盘弹出调用的方法
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        //判断父控件是否为空
        if superview != nil {
            
            //获取动画时长
            let animDuration = notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! Double
            //键盘终点frame
            let endKeyboardFrameStr = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"]
            let endKeyboardFrame = endKeyboardFrameStr!.CGRectValue()
            
            let endKeyboardOrignY = endKeyboardFrame.origin.y
            
            if endKeyboardOrignY == ScreenH { //键盘即将隐藏
                
                UIView.animateWithDuration(animDuration, animations: {
                    
                    //设置主View的Frame
                    self.frame = keyboardHidedShoppingCarFrame
                    
                    //设置产品图片的宽度
                    self.productImageWidthConstraint.constant = keyboardHidedProductImageWidth
                    self.layoutIfNeeded()
                    }, completion: { (_) in
                        
                })
            }else { //键盘即将展示
                UIView.animateWithDuration(animDuration, animations: { 
                    //设置主View的Frame
                    self.frame = keyboardShowingShoppingCarFrame
                    
                    //设置产品图片的宽度
                    self.productImageWidthConstraint.constant = keyboardShowingProductImageWidth
                        self.layoutIfNeeded()
                    }, completion: { (_) in
                })
            }
        }
    }
    
    //MARK: - 发送请求，添加到购物车
    private func addToShoppingCar() {
        
        //获取匹数字符串
        let pishuStr = pishuTF.text
        
        //创建请求参数
        var parameters = ["userID": SAMUserAuth.shareUser()!.id!]
        parameters["productID"] = stockProductModel!.id!
        parameters["countP"] = pishuTF.text!
        parameters["countM"] = mishuTF.text!.lxm_stringByTrimmingLastIfis(".")
        parameters["price"] = priceTF.text!.lxm_stringByTrimmingLastIfis(".")
        parameters["memoInfo"] = remarkTF.text!.lxm_stringByTrimmingWhitespace()
        
//        SAMNetWorker.sharedNetWorker().POST("CartAdd.ashx", parameters: <#T##AnyObject?#>, progress: <#T##((NSProgress) -> Void)?##((NSProgress) -> Void)?##(NSProgress) -> Void#>, success: <#T##((NSURLSessionDataTask, AnyObject?) -> Void)?##((NSURLSessionDataTask, AnyObject?) -> Void)?##(NSURLSessionDataTask, AnyObject?) -> Void#>, failure: <#T##((NSURLSessionDataTask?, NSError) -> Void)?##((NSURLSessionDataTask?, NSError) -> Void)?##(NSURLSessionDataTask?, NSError) -> Void#>)
    }
    
    //
    
    //MARK: - 属性懒加载
    private var firstTF: UITextField?
    
    //MARK: - 点击事件处理
    @IBAction func dismissButtonClick(sender: UIButton) {
        
        //结束第一响应者编辑状态
        endFirstTextFieldEditing()
        
        delegate?.shoppingCarViewDidClickDismissButton()
    }
    
    @IBAction func ensureButtonClick(sender: AnyObject) {
        
        //结束第一响应者编辑状态
        endFirstTextFieldEditing()
        
        addToShoppingCar()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productNumberLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    
    @IBOutlet weak var pishuTF: UITextField!
    @IBOutlet weak var pishuMaxLabel: UILabel!
    
    @IBOutlet weak var mishuTF: UITextField!
    @IBOutlet weak var mishuMaxLabel: UILabel!
    
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var remarkTF: UITextField!
    
    @IBOutlet weak var ensureButton: UIButton!
    @IBOutlet weak var productImageWidthConstraint: NSLayoutConstraint!
    deinit {
        //移除通知监听
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension SAMStockAddShoppingCarView: UITextFieldDelegate {

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //如果是注释文本框则直接返回
        if textField == remarkTF {
            return true
        }
        
        //获取当前文本
        let str = textField.text
        if str == "" {
            return true
        }
        
        //如果第一个是小数点就删除小数点
        if str == "." {
            textField.text = ""
            return true
        }
        
        //如果第一个是0
        if str == "0" {
            
            //如果第二个是小数点，允许输入
            if string == "." {
                
                return true
            }else { //如果第二个不是是小数点，删除第一个0
            
                textField.text = ""
                return true
            }
        }
        
        //如果输入小数点，且当前文本已经有小数点，不让输入
        if (str!.containsString(".")) && (string == ".") {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //赋值第一响应者
        firstTF = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        //如果是备注就直接返回
        if textField == remarkTF {
            return
        }
        
        //获取文本字符串
        var str = textField.text
        
        //如果是空字符串，就赋值文本框，返回
        if str == ""  {
            
            if textField == mishuTF {
                textField.text = "1"
            }else {
                textField.text = "0"
            }
            return
        }
        
        //截取最后一个小数点
        str = str?.lxm_stringByTrimmingLastIfis(".")
        
        
        if str == "" || str == "0"  {
            if textField == mishuTF {
                textField.text = "1"
            }else {
                textField.text = "0"
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //结束第一响应者
        endFirstTextFieldEditing()
        
        return true
    }
}
