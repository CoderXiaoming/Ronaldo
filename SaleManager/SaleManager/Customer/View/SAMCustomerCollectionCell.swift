//
//  SAMCustomerCollectionCell.swift
//  SaleManager
//
//  Created by apple on 16/11/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

protocol SAMCustomerCollectionCellDelegate: NSObjectProtocol {
    func customerCellDidClickVisitShow()
    func customerCellDidClickVisitAdd()
    func customerCellDidClickEdit()
    func customerCellDidClickPhone()
}

class SAMCustomerCollectionCell: UICollectionViewCell {

    ///代理
    weak var delegate: SAMCustomerCollectionCellDelegate?
    
    ///接收的数据模型
    var customerModel: SAMCustomerModel? {
        didSet{
            //设置 customerLabel + 客户城市
            customerLabel.text = customerModel!.CGUnitName
            
            //设置客户城市
            customerCityLabel.text = customerModel!.province + "\\" + customerModel!.city
            
            //设置 remarkLabel
            remarkLabel.text = customerModel?.memoInfo
            
            //设置 phoneLabel
            phoneLabel.text = customerModel?.mobilePhone
            
            //设置 归属
            belongLabel.text = customerModel?.employeeName
        }
    }
    
    ///对外提供展示更多数据
    func showMoreInfo() {
        
        //设置 faxLabel
        faxLabel.text = customerModel?.faxNumber
        
        //设置 telLabel
        telLabel.text = customerModel?.phoneNumber
        
        //设置 addLabel
        addLabel.text = customerModel?.address
    }
    
    //MARK: - 初始化操作
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //添加左滑动手势
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SAMCustomerCollectionCell.leftSwipeCell))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        addGestureRecognizer(leftSwipe)
        
        //添加右滑动手势
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SAMCustomerCollectionCell.rightSwipeCell))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        addGestureRecognizer(rightSwipe)
    }
    
    //MARK: - 判断当前是否被选中
    func hasSelected() -> Bool {
        if containterView.backgroundColor!.cgColor == UIColor.white.cgColor {
            return false
        }
        return true
    }
    
    //MARK: - SwipeGesture
    func leftSwipeCell() {
        
        //判断用户归属
        if customerModel!.employeeName != SAMUserAuth.shareUser()!.userName {
            return
        }
        
        //当前未被选中，返回
        if  hasSelected() == false {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.containterView.transform = CGAffineTransform(translationX: -60, y: 0)
        }) 
    }
    func rightSwipeCell() {
        //当前未被选中，返回
        if  hasSelected() == false {
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.containterView.transform = CGAffineTransform.identity
        }) 
    }
    
    //MARK: - 点击事件处理
    @IBAction func editBtnClick(_ sender: AnyObject) {
        delegate?.customerCellDidClickEdit()
    }
    @IBAction func phoneBtnClick(_ sender: AnyObject) {
        delegate?.customerCellDidClickPhone()
    }
    @IBAction func vistEditBtnClick(_ sender: UIButton) {
        delegate?.customerCellDidClickVisitAdd()
    }
    @IBAction func visitShowBtnClick(_ sender: UIButton) {
        delegate?.customerCellDidClickVisitShow()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var containterView: UIView!
    
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var customerCityLabel: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var belongLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var faxLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
}
