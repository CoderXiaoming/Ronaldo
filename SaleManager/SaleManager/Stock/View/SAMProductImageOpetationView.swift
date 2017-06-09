//
//  SAMProductImageOpetationView.swift
//  SaleManager
//
//  Created by apple on 16/12/4.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

protocol SAMProductImageOpetationViewDelegate: NSObjectProtocol {
    func opetationViewDidClickCameraBtn()
    func opetationViewDidClickSelectBtn()
    func opetationViewDidClickSaveBtn()
    func opetationViewDidClickCancelBtn()
    func opetationViewDidClickSaveProductStockImageBtn()
}

class SAMProductImageOpetationView: UIView {

    weak var delegate: SAMProductImageOpetationViewDelegate?
    
    //对外提供类方法实例化对象
    class func instacne() -> SAMProductImageOpetationView? {
       let view = Bundle.main.loadNibNamed("SAMProductImageOpetationView", owner: nil, options: nil)![0] as! SAMProductImageOpetationView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if !hasTP_SZ_Auth {
            selectImageButton.isHidden = true
            topSeperaterView.isHidden = true
            cameraButton.isHidden = true
            centerSeperaterView.isHidden = true
        }
    }
    
    //MARK: - 点击事件
    @IBAction func cameraBtnClick(_ sender: AnyObject) {
        delegate?.opetationViewDidClickCameraBtn()
    }
    @IBAction func selectBtnClick(_ sender: AnyObject) {
        delegate?.opetationViewDidClickSelectBtn()
    }
    @IBAction func saveStockImageBtnClick(_ sender: UIButton) {
        delegate?.opetationViewDidClickSaveProductStockImageBtn()
    }
    @IBAction func saveBtnClick(_ sender: AnyObject) {
        delegate?.opetationViewDidClickSaveBtn()
    }
    @IBAction func cancelBtnClick(_ sender: AnyObject) {
        delegate?.opetationViewDidClickCancelBtn()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var topSeperaterView: UIView!
    @IBOutlet weak var centerSeperaterView: UIView!
    //MARK: - 属性
    ///新增图片权限
    fileprivate lazy var hasTP_SZ_Auth: Bool = SAMUserAuth.checkAuth(["TP_SZ_APP"])
}
