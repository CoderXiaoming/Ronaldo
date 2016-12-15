//
//  SAMStockAddShoppingCarView.swift
//  SaleManager
//
//  Created by apple on 16/12/10.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

///添加产品的URL
private let SAMAddShoppingCarURLStr = "CartAdd.ashx"
///编辑产品的URL
private let SAMEditShoppingCarURLStr = "CartEdit.ashx"

///键盘展示时图片宽度
private let keyboardShowingProductImageWidth: CGFloat = 60
///键盘展示时购物车控件的高度
private let keyboardShowingShoppingCarFrame = CGRect(x: 0, y: ScreenH - 550, width: ScreenW, height: 550)

///键盘隐藏时图片宽度
private let keyboardHidedProductImageWidth: CGFloat = 90
///键盘隐藏时购物车控件的高度
private let keyboardHidedShoppingCarFrame = CGRect(x: 0, y: ScreenH - 350, width: ScreenW, height: 350)

///信息字体小rect
private let shoppingCarViewLabelSmallFont = UIFont.systemFontOfSize(13)
///信息字体大font
private let shoppingCarViewLabelBigFont = UIFont.systemFontOfSize(15)

protocol SAMStockAddShoppingCarViewDelegate: NSObjectProtocol {
    func shoppingCarViewDidClickDismissButton()
    func shoppingCarViewAddOrEditProductSuccess(productImage: UIImage)
}

class SAMStockAddShoppingCarView: UIView {

    ///代理
    weak var delegate: SAMStockAddShoppingCarViewDelegate?
    
    ///全局单例
    static let instance = NSBundle.mainBundle().loadNibNamed("SAMStockAddShoppingCarView", owner: nil, options: nil)![0] as! SAMStockAddShoppingCarView
    
    //MARK: - 对外提供的展示控件调用的方法
    class func shoppingCarViewWillShow(stockProductImage: UIImage, addProductModel: SAMStockProductModel?, editProductModel: SAMShoppingCarListModel?) -> SAMStockAddShoppingCarView {
        
        //赋值图片
        instance.productImage.image = stockProductImage
        
        //清楚所有文本框
        instance.clearAllTextField()
        
        //赋值数据模型
        if addProductModel != nil {
            instance.addProductModel = addProductModel
            instance.editProductModel = nil
            instance.isAddingProduct = true
        }else {
            instance.addProductModel = nil
            instance.editProductModel = editProductModel
            instance.isAddingProduct = false
        }
        
        //设置确认按钮不可用
        instance.ensureButton.enabled = false
        let buttonTitle = instance.isAddingProduct ? "添加" : "修改"
        instance.ensureButton.setTitle(buttonTitle, forState: .Normal)
        
        return instance
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
    }
    
    
    //MARK: - textField监听的方法
    func textFieldDidChangeValue(textField: UITextField) {
        
        //设置确认按钮可用性
        if pishuTF.hasText() && mishuTF.hasText() && priceTF.hasText() {
            ensureButton.enabled = true
        }else {
            ensureButton.enabled = false
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
                    
                    //设置字体大小
                    self.setTitleLabelBiggerOrSmaller(true)
                    
                    self.layoutIfNeeded()
                    }, completion: { (_) in
                        
                })
            }else { //键盘即将展示
                UIView.animateWithDuration(animDuration, animations: { 
                    //设置主View的Frame
                    self.frame = keyboardShowingShoppingCarFrame
                    
                    //设置产品图片的宽度
                    self.productImageWidthConstraint.constant = keyboardShowingProductImageWidth
                    
                    //设置字体大小
                    self.setTitleLabelBiggerOrSmaller(false)
                    
                    self.layoutIfNeeded()
                    }, completion: { (_) in
                })
            }
        }
    }
    
    //MARK: - 设置文字变大或变小
    private func setTitleLabelBiggerOrSmaller(bigger:Bool) {
        
        let labelArr = NSArray(array: [productNumberLabel, pishuTitleLabel, pishuLabel, mishuTitleLabel, mishuLabel])
        labelArr.enumerateObjectsUsingBlock { (obj, index, _) in
            let label = obj as! UILabel
            
            label.font = bigger ? shoppingCarViewLabelBigFont : shoppingCarViewLabelSmallFont
        }
    }
    
    //MARK: - 属性懒加载
    ///接收的添加产品数据模型
    private var addProductModel: SAMStockProductModel? {
        didSet{
            
            if addProductModel == nil {
                return
            }
            
            //设置产品名称
            if addProductModel!.productIDName != "" {
                productNumberLabel.text = addProductModel!.productIDName
            }else {
                productNumberLabel.text = "---"
            }
            
            //设置标题匹数
            pishuLabel.text = String(format: "%d", addProductModel!.countP)
            
            //设置标题米数
            mishuLabel.text = String(format: "%.1f", addProductModel!.countM)
        
            //设置字体大小
            setTitleLabelBiggerOrSmaller(true)
            
            //设置文本框
            pishuTF.text = "0"
            mishuTF.text = "1"
            priceTF.text = "0"
            remarkTF.text = ""
        }
    }

    ///接收的编辑购物车的数据模型
    private var editProductModel: SAMShoppingCarListModel? {
        didSet{

            if editProductModel == nil {
                return
            }
            //设置匹数， 米数，价格
            pishuTF.text = String(format: "%d", editProductModel!.countP)
            mishuTF.text = String(format: "%.1f", editProductModel!.countM)
            priceTF.text = String(format: "%.1f", editProductModel!.price)
            
            //赋值备注文本框
            if editProductModel!.memoInfo != "" {
                remarkTF.text = editProductModel!.memoInfo
            }else {
                remarkTF.text = ""
            }
            
            //设置字体大小
            setTitleLabelBiggerOrSmaller(true)
        }
    }

    private var firstTF: UITextField?
    
    ///记录当前是 添加商品 还是 编辑商品
    private var isAddingProduct: Bool = false {
        didSet{
            //设置请求路径
            self.requestURLStr = isAddingProduct ? SAMAddShoppingCarURLStr : SAMEditShoppingCarURLStr
        }
    }
    
    ///数据请求链接
    private var requestURLStr: String?
    
    //MARK: - 点击事件处理
    @IBAction func dismissButtonClick(sender: UIButton) {
        
        //结束第一响应者编辑状态
        endFirstTextFieldEditing()
        
        delegate?.shoppingCarViewDidClickDismissButton()
    }
    
    @IBAction func ensureButtonClick(sender: AnyObject) {
        
        //结束第一响应者编辑状态
        endFirstTextFieldEditing()
        
        //设置加载hud
        let hud = SAMHUD.showHUDAddedTo(KeyWindow, animated: true)
        hud.labelText = NSLocalizedString("请等待...", comment: "HUD loading title")
        
        //创建请求参数
        var parameters = [String: AnyObject]()
        parameters["countP"] = pishuTF.text!
        parameters["countM"] = mishuTF.text!
        parameters["price"] = priceTF.text!
        
        if isAddingProduct { //添加购物车状态
            
            parameters["userID"] = SAMUserAuth.shareUser()!.id!
            parameters["productID"] = addProductModel!.id!
        }else { //编辑购物车状态
            
            parameters["id"] = editProductModel!.id!
        }
        
        if remarkTF.hasText() {
            parameters["memoInfo"] = remarkTF.text!
        }else {
            parameters["memoInfo"] = ""
        }
        
        //发送服务器请求，添加到购物车
        SAMNetWorker.sharedNetWorker().POST(requestURLStr!, parameters: parameters, progress: nil, success: { (task, Json) in
            
            
            //获取上传状态
            let dict = Json!["head"] as! [String: String]
            let status = dict["status"]!
            
            if status == "success" { //上传服务器成功
            
                //返回主线程
                dispatch_async(dispatch_get_main_queue(), {
                    //隐藏HUD
                    hud.hide(true)
                    
                    //告诉代理添加产品成功
                    self.delegate?.shoppingCarViewAddOrEditProductSuccess(self.productImage.image!)
                })
            }else { //上传服务器失败
                
                //返回主线程
                dispatch_async(dispatch_get_main_queue(), { 
                    //隐藏HUD
                    hud.hide(true)
                    
                    let hudMessage = self.isAddingProduct ? "添加失败，请重试" : "修改失败，请重试"
                    //提示用户错误信息
                    SAMHUD.showMessage(hudMessage, superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                })
            }
        }) { (task, error) in
            
            //隐藏HUD
            hud.hide(true)
            
            //提示用户错误信息
            SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productNumberLabel: UILabel!
    
    @IBOutlet weak var pishuTitleLabel: UILabel!
    @IBOutlet weak var pishuLabel: UILabel!
    
    @IBOutlet weak var mishuTitleLabel: UILabel!
    @IBOutlet weak var mishuLabel: UILabel!
    
    @IBOutlet weak var pishuTF: UITextField!
    
    @IBOutlet weak var mishuTF: UITextField!
    
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
        
        //如果截取后没有字符，或者为0，则赋值
        if str == "" || str == "0"  {
            if textField == mishuTF {
                textField.text = "1"
            }else {
                textField.text = "0"
            }
            return
        }
        
        //赋值文本框
        textField.text = str
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //结束第一响应者
        endFirstTextFieldEditing()
        
        return true
    }
}
