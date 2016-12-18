//
//  SAMOrderBuildController.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit

///小cell重用标识符
fileprivate let SAMOrderBuildSmallCellReuseIdentifier = "SAMOrderBuildSmallCellReuseIdentifier"
///大cell重用标识符
fileprivate let SAMOrderBuildBigCellReuseIdentifier = "SAMOrderBuildBigCellReuseIdentifier"
///产品组headerView重用标识符
fileprivate let SAMOrderBuildProductSectionHeaderViewReuseIdentifier = "SAMOrderBuildProductSectionHeaderViewReuseIdentifier"

class SAMOrderBuildController: UIViewController {

    //MARK: - 对外提供的类方法，接收产品数据模型，添加到订单中
    class func buildOrder(productModels: [SAMShoppingCarListModel]?) -> SAMOrderBuildController {
        
        let vc = SAMOrderBuildController()
        vc.productToOrderModels = productModels!
        
        return vc
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

       //创建titleModels
        setupTitleModels()
        
        //初始化设置tableView
        setupTableView()
        
        //初始化设置通知
        setupNotification()
    }

    //MARK: - 创建titleModels
    fileprivate func setupTitleModels() {
        for section in 0...(titles.count - 1) {
            
            //获取当前标题小数组
            let strArr = titles[section] as [String]
            
            //如果数组为空返回
            if strArr.count == 0 {
                titleModels.append([])
                
            }else {
                //遍历数组，创建数据源数组
                var modelArr = [SAMOrderBuildTitleModel]()
                for item in 0...(strArr.count - 1) {
                    let str = strArr[item]
                    let model = SAMOrderBuildTitleModel.titleModel(title: str, content: nil)
                    modelArr.append(model)
                }
                titleModels.append(modelArr)
            }
        }
    }
    
    //MARK: - 初始化设置tableView
    fileprivate func setupTableView() {
        
        //注册CELL
        tableView.register(UINib.init(nibName: "SAMOrderBuildSmallCell", bundle: nil), forCellReuseIdentifier: SAMOrderBuildSmallCellReuseIdentifier)
        tableView.register(UINib.init(nibName: "SAMOrderBuildBigCell", bundle: nil), forCellReuseIdentifier: SAMOrderBuildBigCellReuseIdentifier)
        
        //注册产品组headerView
        tableView.register(UINib.init(nibName: "SAMOrderProductSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: SAMOrderBuildProductSectionHeaderViewReuseIdentifier)
    }
    
    //MARK: - 初始化设置监听
    fileprivate func setupNotification() {
        
        //监听是成功选择用户的通知
        NotificationCenter.default.addObserver(self, selector: #selector(SAMOrderBuildController.customerVCDidSelectCustomer(notification:)), name: NSNotification.Name.init(SAMCustomerViewControllerDidSelectCustomerNotification), object: nil)
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //设置标题
        navigationItem.title = "新建订单"
        
        //刷新数据
        tableView.reloadData()
    }
    
    //MARK: - 成功选择客户通知的监听
    func customerVCDidSelectCustomer(notification: NSNotification) {
        
        //赋值用户模型
        orderCustomerModel = notification.userInfo!["customerModel"] as? SAMCustomerModel
    }
    
    //MARK: - 属性懒加载
    ///左边标题数组
    fileprivate let titles = [["客户", "备注"], [], ["优惠", "其他金额", "总金额", "已收定金"]]
    
    ///标题cell的数据模型
    fileprivate var titleModels = [[SAMOrderBuildTitleModel?]]()
    
    ///接收的购物车中物品模型
    fileprivate var productToOrderModels = [SAMShoppingCarListModel]()
    
    ///接收的客户模型
    fileprivate var orderCustomerModel: SAMCustomerModel? {
        didSet{
            if orderCustomerModel == nil {
                return
            }
            
            //赋值用户名
            let orderTitleModel = self.titleModels[0][0]!
            orderTitleModel.cellContent = orderCustomerModel!.CGUnitName!
            
            //刷新数据
            tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
        }
    }
    
    ///购物车编辑控件
    fileprivate var productOperationView: SAMProductOperationView?
    ///展示购物车时，主界面添加的蒙版
    fileprivate lazy var productOperationMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMOrderBuildController.hideProductOperationViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()

    //MARK: - XIB链接属性
    @IBOutlet weak var tableView: UITableView!
    
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
        view = Bundle.main.loadNibNamed("SAMOrderBuildController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SAMOrderBuildController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return titleModels.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 { //产品列表组
            return productToOrderModels.count
        }else { //订单内容组
            return titleModels[section].count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 { //产品列表组
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderBuildBigCellReuseIdentifier, for: indexPath) as! SAMOrderBuildBigCell
            
            //取出模型
            cell.productAddToOrderModel = productToOrderModels[indexPath.row] as SAMShoppingCarListModel
            return cell
        }else { //订单内容组
            let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderBuildSmallCellReuseIdentifier, for: indexPath) as! SAMOrderBuildSmallCell
            
            //取出模型
            cell.titleModel = titleModels[indexPath.section][indexPath.row]! as SAMOrderBuildTitleModel
            return cell
        }
    }
}

//MARK: - tableView代理 UITableViewDelegate
extension SAMOrderBuildController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 { //产品列表组
            return 50
        }else { //订单内容组
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 60
        }else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == IndexPath(row: 0, section: 0) { //点击了客户栏
            
        navigationController!.pushViewController(SAMCustomerViewController.instance(controllerType: .OrderBuild), animated: true)
        }else if (indexPath.section == 1) { //点击了产品组
        
        }else {
            
            //取出模型
            let model = titleModels[indexPath.section][indexPath.row]!
            let editVC = SAMOrderInfoEditController.editInfo(orderTitleModel: model)
            navigationController!.pushViewController(editVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SAMOrderBuildProductSectionHeaderViewReuseIdentifier)!
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section == 1 {
            
            //取出cell
            let cell = tableView.cellForRow(at: indexPath) as! SAMOrderBuildBigCell
            
            //取出对应模型
            let model = cell.productAddToOrderModel!
            
            /*******************  查询按钮  ********************/
            let equiryAction = UITableViewRowAction(style: .normal, title: "查询") { (action, indexPath) in
                
                let stockVC = SAMStockViewController.stockRequest(shoppingCarListModel: model)
                self.navigationController?.pushViewController(stockVC, animated: true)
            }
            equiryAction.backgroundColor = UIColor.randomColor()
            
            /*******************  编辑按钮  ********************/
            let editAction = UITableViewRowAction(style: .default, title: "编辑") { (action, indexPath) in
                self.showShoppingCar(editModel: model)
            }
            editAction.backgroundColor = UIColor.randomColor()
            
            /*******************  删除按钮  ********************/
            let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { (action, indexPath) in
                
                //获取数据模型对应的数组编号
                let index = self.productToOrderModels.index(of: model)!
                
                //从源数组中删除
                self.productToOrderModels.remove(at: index)
                
                //动画删除该行CELL
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .left)
            }
            deleteAction.backgroundColor = UIColor.randomColor()
            
            //如果只有这组只有一个产品了，不显示删除按钮
            if self.productToOrderModels.count == 1 {
                return [editAction, equiryAction]
            }else {
                return [editAction, equiryAction, deleteAction]
            }
        }else {
            return nil
        }
    }
}

//MARK: - 购物车代理SAMProductOperationViewDelegate
extension SAMOrderBuildController: SAMProductOperationViewDelegate {
    func operationViewDidClickDismissButton() {
        //隐藏购物车
        hideProductOperationView(false)
    }
    
    func operationViewAddOrEditProductSuccess(_ productImage: UIImage) {
        //隐藏购物车
        hideProductOperationView(true)
    }
}

//MARK: - 购物车相关方法
extension SAMOrderBuildController {
    
    //view的第一步动画
    fileprivate func firstTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m24 = -1/2000
        transform = CATransform3DScale(transform, 0.9, 0.9, 1)
        return transform
    }
    
    //view的第二步动画
    fileprivate func secondTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, self.view.frame.size.height * (-0.08), 0)
        transform = CATransform3DScale(transform, 0.8, 0.8, 1)
        return transform
    }
    
    //点击maskView隐藏购物车控件
    func hideProductOperationViewWhenMaskViewDidClick() {
        
        hideProductOperationView(false)
    }
    
    //展示购物车
    func showShoppingCar(editModel: SAMShoppingCarListModel) {
        
        //设置购物车控件的目标frame
        self.productOperationView = SAMProductOperationView.operationViewWillShow(nil, editProductModel: editModel)
        self.productOperationView!.delegate = self
        self.productOperationView!.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: 350)
        
        var rect = self.productOperationView!.frame
        rect.origin.y = ScreenH - rect.size.height
        
        //添加背景View
        self.tabBarController!.view.addSubview(self.productOperationMaskView)
        KeyWindow?.addSubview(self.productOperationView!)
        
        //动画展示购物车控件
        UIView.animate(withDuration: 0.5, animations: {
            self.productOperationView!.frame = rect
        })
        
        //动画移动背景View
        UIView.animate(withDuration: 0.25, animations: {
            
            //执行第一步动画
            self.productOperationMaskView.alpha = 0.5
            self.tabBarController!.view.layer.transform = self.firstTran()
        }, completion: { (_) in
            
            //执行第二步动画
            UIView.animate(withDuration: 0.25, animations: {
                self.tabBarController!.view.layer.transform = self.secondTran()
            }, completion: { (_) in
            })
        })
    }
    
    //隐藏购物车控件
    func hideProductOperationView(_ editSuccess: Bool) {
        
        //结束 tableView 编辑状态
        self.tableView.isEditing = false
        
        //设置购物车目标frame
        var rect = self.productOperationView!.frame
        rect.origin.y = ScreenH
        
        //动画隐藏购物车控件
        UIView.animate(withDuration: 0.5, animations: {
            
            self.productOperationView!.frame = rect
        })
        
        //动画展示主View
        UIView.animate(withDuration: 0.25, animations: {
            
            self.tabBarController!.view.layer.transform = self.firstTran()
            
            self.productOperationMaskView.alpha = 0.0
        }, completion: { (_) in
            
            //移除蒙板
            self.productOperationMaskView.removeFromSuperview()
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.tabBarController!.view.layer.transform = CATransform3DIdentity
                
            }, completion: { (_) in
                
                //移除购物车
                self.productOperationView!.removeFromSuperview()
                
                //调用成功添加购物车的动画
                if editSuccess {
                    self.tableView.reloadData()
                }
            })
        })
    }
}
