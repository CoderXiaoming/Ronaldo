//
//  SAMOrderOwedOperationController.swift
//  SaleManager
//
//  Created by apple on 16/12/16.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MBProgressHUD

///控制器类型枚举定义
enum OrderOwedOperationControllerType {
    case buildOrder //创建订单
    case checkOrder //查看订单
    case buildOwe   //创建缺货登记
    case checkOwe   //查看缺货登记
}

///小cell重用标识符
fileprivate let SAMOrderBuildSmallCellReuseIdentifier = "SAMOrderBuildSmallCellReuseIdentifier"
///大cell重用标识符
fileprivate let SAMOrderBuildBigCellReuseIdentifier = "SAMOrderBuildBigCellReuseIdentifier"

class SAMOrderOwedOperationController: UIViewController {
    
    //MARK: - 对外提供的类方法，接收产品数据模型，添加到订单中
    class func buildOrder(productModels: [SAMShoppingCarListModel]?, type: OrderOwedOperationControllerType) -> SAMOrderOwedOperationController {
        let vc = SAMOrderOwedOperationController()
        vc.controllerType = type
        vc.productToOrderModels = productModels
        
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    //MARK: - 对外提供的类方法，接收产品数据模型，查询订单
    class func checkOrder(orderInfoModel: SAMOrderModel, type: OrderOwedOperationControllerType) -> SAMOrderOwedOperationController {
        let vc = SAMOrderOwedOperationController()
        vc.controllerType = type
        vc.orderInfoModel = orderInfoModel
        
        vc.productToOrderModels = orderInfoModel.productListModels
        
        //记录控制器状态
        vc.couldEdit = (orderInfoModel.isAgreeSend! != "是")
        
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    //MARK: - 对外提供的类方法，接收库存产品数据模型，新建缺货登记
    class func buildOwe(productModel: SAMStockProductModel, type: OrderOwedOperationControllerType) -> SAMOrderOwedOperationController {
        let vc = SAMOrderOwedOperationController()
        vc.controllerType = type
        vc.stockModel = productModel
        
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    //MARK: - 对外提供的类方法，接收缺货登记数据模型，查看缺货登记
    class func checkOwe(oweInfoModel: SAMOwedInfoModel, type: OrderOwedOperationControllerType) -> SAMOrderOwedOperationController {
        let vc = SAMOrderOwedOperationController()
        vc.oweModel = oweInfoModel
        
        //记录控制器状态
        vc.controllerType = type
        vc.couldEdit = (oweInfoModel.iState == "欠货中") ? true : false
        
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
    
    //MARK: - 根据不同控制器类型执行不同的事情(四种)
    fileprivate func performByControllerType(buildOrder: (()->())?, checkOrder: (()->())?, buildOwe: (()->())?, checkOwe: (()->())?) {
    
        switch controllerType! {
        case OrderOwedOperationControllerType.buildOrder:
            if buildOrder != nil {
                buildOrder!()
            }else {
                break
            }
            
        case OrderOwedOperationControllerType.checkOrder:
            if checkOrder != nil {
                checkOrder!()
            }else {
                break
            }
            
        case OrderOwedOperationControllerType.buildOwe:
            if buildOwe != nil {
                buildOwe!()
            }else {
                break
            }
            
        case OrderOwedOperationControllerType.checkOwe:
            if checkOwe != nil {
                checkOwe!()
            }else {
                break
            }
        }
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //设置主要数据
        setupMainInfo()
        
        //初始化UI
        setupUI()
        
        //初始化设置tableView
        setupTableView()
        
        //初始化设置通知
        setupNotification()
    }
    
    //MARK: - viewWillAppear，修改后返回界面刷新数据
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - 设置主要数据
    fileprivate func setupMainInfo() {
        
        //设置title，请求路径
        performByControllerType(buildOrder: {
            self.titles = [[["客户", ""], ["备注", ""], ["业务员", "不选择默认自己"]], [["666", "666"]], [["优惠", "0"], ["其他金额", "0"], ["总金额", "0"], ["已收定金", "0"]]]
            self.saveUrlStr = "OrderBillAdd.ashx"
            
            let model = SAMOrderBuildEmployeeModel()
            model.employeeID = ""
            model.name = ""
            self.orderBuildEmployeeModel = model
            
        }, checkOrder: { 
            self.titles = self.orderInfoModel!.orderDetailContentArr
            self.saveUrlStr = "OrderBillEdit.ashx"
            //设置用户
            self.orderCustomerModel = self.orderInfoModel?.orderCustomerModel!
            
        }, buildOwe: { 
            self.titles = [[["客户", ""], ["交货日期", ""]], [["产品型号", self.stockModel!.productIDName], ["匹数", "0"], ["米数", "0"], ["备注", ""]]]
            self.saveUrlStr = "OOSRecordAdd.ashx"
            
        }) {
            self.titles = [[["客户", self.oweModel!.CGUnitName], ["交货日期", self.oweModel!.endDate]], [["产品型号", self.oweModel!.productIDName], ["匹数", String(format: "%d", self.oweModel!.countP)], ["米数", String(format: "%.1f", self.oweModel!.countM)]], [["备注", self.oweModel!.memoInfo], ["状态", self.oweModel!.iState]]]
            self.saveUrlStr = "OOSRecordEdit.ashx"
            //设置用户
            self.orderCustomerModel = self.oweModel?.orderCustomerModel!
            //设置产品数据模型
            self.stockModel = self.oweModel?.stockModel!
        }
        
        //创建数据模型数组
        titleModels = [[SAMOrderBuildTitleModel?]]()
        
        for section in 0...(titles!.count - 1) {
            
            //获取当前标题小数组
            let strArrArr = titles![section] as [[String?]]

            //如果数组为空返回
            if strArrArr.count == 1 {
                titleModels!.append([SAMOrderBuildTitleModel.titleModel(title: "666", content: "666")])
            }else {
                //遍历数组，创建数据源数组
                var modelArr =  [SAMOrderBuildTitleModel?]()
                for item in 0...(strArrArr.count - 1) {
                    let strArr = strArrArr[item]
                    let model = SAMOrderBuildTitleModel.titleModel(title: strArr[0]!, content: strArr[1])
                    modelArr.append(model)
                }
                titleModels!.append(modelArr)
            }
        }
    }
    
    //MARK: - 初始化UI
    fileprivate func setupUI() {
    
        performByControllerType(buildOrder: { 
            //隐藏编辑按钮父控件
            self.editBtnView.isHidden = true
            self.navigationItem.title = "新建订单"
        }, checkOrder: {
            //展示编辑按钮父控件
            self.editBtnView.isHidden = false
            if self.orderInfoModel!.isAgreeSend! != "是" { //还未发货
                self.navigationItem.title = "订单详情(未发货)"
                
            }else { //已发货
                self.saveEditButton.isEnabled = false
                self.deleteButton.isEnabled = false
                self.navigationItem.title = "订单详情(已发货)"
            }
            
        }, buildOwe: {
            //隐藏编辑按钮父控件
            self.editBtnView.isHidden = true
            self.saveAndAgreeSendButtonWidth.constant = -(ScreenW + 1)
            self.navigationItem.title = "缺货登记"
        }) {
            //展示编辑按钮父控件
            self.editBtnView.isHidden = false
            self.saveEditButton.isEnabled = self.couldEdit
            self.navigationItem.title = "缺货详情"
        }
        
        //设置返回按钮
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    //MARK: - 初始化设置tableView
    fileprivate func setupTableView() {
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //注册CELL
        tableView.register(UINib.init(nibName: "SAMOrderBuildSmallCell", bundle: nil), forCellReuseIdentifier: SAMOrderBuildSmallCellReuseIdentifier)
        tableView.register(UINib.init(nibName: "SAMOrderBuildBigCell", bundle: nil), forCellReuseIdentifier: SAMOrderBuildBigCellReuseIdentifier)
    }
        
    //MARK: - 监听的三个方法
    fileprivate func setupNotification() {
        
        //监听成功选择用户的通知
        NotificationCenter.default.addObserver(self, selector: #selector(SAMOrderOwedOperationController.customerVCDidSelectCustomer(notification:)), name: NSNotification.Name.init(SAMCustomerViewControllerDidSelectCustomerNotification), object: nil)
        
        //监听成功获取购物车模型的通知
        NotificationCenter.default.addObserver(self, selector: #selector(SAMOrderOwedOperationController.productOperationViewGetModelSuccess(notification:)), name: NSNotification.Name.init(SAMProductOperationViewGetShoppingCarListModelNotification), object: nil)
    }
    //成功选择客户通知的监听
    func customerVCDidSelectCustomer(notification: NSNotification) {
        
        //赋值用户模型
        orderCustomerModel = notification.userInfo!["customerModel"] as? SAMCustomerModel
        
        if orderCustomerModel == nil {
            //设置按钮状态
            saveButton.isEnabled = false
            saveAndAgreeSendButton.isEnabled = false
            return
        }
        
        //赋值用户名
        let orderTitleModel = self.titleModels![0][0]!
        orderTitleModel.cellContent = orderCustomerModel!.CGUnitName
        
        //设置按钮状态
        saveButton.isEnabled = true
        saveAndAgreeSendButton.isEnabled = true
        
        //刷新数据
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
    }
    //成功获取购物车数据模型通知的监听
    func productOperationViewGetModelSuccess(notification: NSNotification) {
        
        //添加购物车模型
        let model = notification.userInfo!["model"] as! SAMShoppingCarListModel
        
        if productToOrderModels == nil {
            productToOrderModels = [SAMShoppingCarListModel]()
        }
        productToOrderModels!.append(model)
        
        //刷新数据
        tableView.reloadData()
    }
    
    //MARK: - 更新统计数据
    fileprivate func updateCountData() {
        
        if productToOrderModels != nil {
            //清空数组
            productSectionCountArr.removeAll()
            
            var countMashu = 0.0
            var countMishu = 0.0
            var countPrice = 0.0
            
            for model in productToOrderModels! {
                countMashu += model.countMA
                countMishu += model.countM
                countPrice += model.countPrice
            }
            
            productSectionCountArr.append(countMashu)
            productSectionCountArr.append(countMishu)
            productSectionCountArr.append(countPrice)
            
            productSectionFooterView.countArr = productSectionCountArr
        }
    }
    
    //MARK: - 用户点击事件处理
    @IBAction func saveAndAgreeSendBtnClick(_ sender: Any) {
        
        saveAndAgreeSend(isAgreeSend: true)
    }
    @IBAction func saveBtnClick(_ sender: Any) {
        
        saveAndAgreeSend(isAgreeSend: false)
    }
    
    ///发货两个按钮共同点击
    fileprivate func saveAndAgreeSend(isAgreeSend: Bool) {
    
        //如果是新建订单类型，对productToOrderModels进行判断
        if (controllerType! == OrderOwedOperationControllerType.buildOrder) && productToOrderModels == nil{
            _ = SAMHUD.showMessage("请添加产品", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //创建主请求参数
        var MainData: [String: String]?
        let CGUnitID = orderCustomerModel!.id
        let dateStr = Date().yyyyMMddStr()
        let userID = SAMUserAuth.shareUser()!.id!
        
        switch controllerType! {
        case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
            var employeeID = SAMUserAuth.shareUser()!.employeeID!
            let memoInfo = self.titleModels![0][1]!.cellContent
            let cutMoney = self.titleModels![2][0]!.cellContent
            let otherMoney = self.titleModels![2][1]!.cellContent
            let totalMoney = self.titleModels![2][2]!.cellContent
            let receiveMoney = self.titleModels![2][3]!.cellContent
            
            
            if (self.orderBuildEmployeeModel?.name != "") && (self.orderBuildEmployeeModel != nil) {
                employeeID = orderBuildEmployeeModel!.employeeID
            }
            
            MainData = ["startDate": dateStr, "CGUnitID": CGUnitID, "employeeID": employeeID, "memoInfo": memoInfo, "cutMoney": cutMoney, "otherMoney": otherMoney, "totalMoney": totalMoney, "receiveMoney": receiveMoney, "userID": userID]
            
        case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
            let endDate = self.titleModels![0][1]!.cellContent
            if endDate == "" {
                let _ = SAMHUD.showMessage("交货日期不能为空", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                return
            }
            let productID = self.stockModel!.id
            let countP = self.titleModels![1][1]!.cellContent
            let countM = self.titleModels![1][2]!.cellContent
            let memoInfo = self.titleModels![2][0]!.cellContent
            
            MainData = ["CGUnitID": CGUnitID, "startDate": dateStr, "endDate": endDate, "productID": productID, "countP": countP, "countM": countM, "memoInfo": memoInfo, "userID": userID]
        }
        
        if controllerType! == OrderOwedOperationControllerType.checkOrder {
            MainData!["billNumber"] = orderInfoModel!.billNumber!
        }
        
        if controllerType! == OrderOwedOperationControllerType.checkOwe {
            MainData!["id"] = oweModel!.id
        }
        
        //转换为Json字符串
        let mainJsonData = try! JSONSerialization.data(withJSONObject: MainData!, options: JSONSerialization.WritingOptions.prettyPrinted)
        let mainJsonStr = String(data: mainJsonData, encoding: String.Encoding.utf8)!
        
        //创建产品请求参数,和最终请求参数
        var detailJsonStr: String?
        var parameters: [String: String]?
        if controllerType == OrderOwedOperationControllerType.buildOrder || controllerType == OrderOwedOperationControllerType.checkOrder {
            
            let DetailData = NSMutableArray()
            for model in productToOrderModels! {
                let patemeter = ["id": model.id, "productIDName": model.productIDName, "countP": model.countP, "countM": model.countM, "price": model.price, "smallMoney": model.countPrice, "productStatus": "", "productID": model.productID, "memoInfo": model.memoInfo] as [String : Any]
                DetailData.add(patemeter)
            }
            let detailJsonData = try! JSONSerialization.data(withJSONObject: DetailData, options: JSONSerialization.WritingOptions.prettyPrinted)
            detailJsonStr = String(data: detailJsonData, encoding: String.Encoding.utf8)!
            
            parameters = ["MainData": mainJsonStr, "DetailData": detailJsonStr!]
        }else {
            parameters = ["MainData": mainJsonStr]
        }
        
        //设置加载hud
        let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)
        hud!.labelText = NSLocalizedString("正在保存...", comment: "HUD loading title")
        
        //判断请求链接，直接同意发货
        if isAgreeSend == true {
            saveUrlStr = "OrderBillAddAgree.ashx"
        }
        
        //发送服务器请求
        SAMNetWorker.sharedNetWorker().post(saveUrlStr!, parameters: parameters, progress: nil, success: {[weak self] (task, json) in
            
            //隐藏HUD
            hud?.hide(true)
            
            //获取状态字符串
            let Json = json as! [String: AnyObject]
            let dict = Json["head"] as! [String: String]
            let state = dict["status"]
            
            if state == "success" { //保存成功
                var showMessage = ""
                if isAgreeSend == true {
                    showMessage = "发货成功"
                }else {
                    showMessage = "保存成功"
                }
                let hud = SAMHUD.showMessage(showMessage, superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                hud?.delegate = self
                
            }else { //保存失败
                let _ = SAMHUD.showMessage("保存失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }
        }) { (task, error) in
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    
    @IBAction func deleteBtnClick(_ sender: UIButton) {
        
        let alertVC = UIAlertController(title: "确定删除？", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            
            
            //设置加载hud
            let hud = SAMHUD.showAdded(to: KeyWindow, animated: true)!
            hud.labelText = NSLocalizedString("请等待...", comment: "HUD loading title")
            
            //设置请求参数，请求路径
            var requestURLStr: String?
            var parameters: [String: String]?
            switch self.controllerType! {
            case OrderOwedOperationControllerType.checkOrder:
                requestURLStr = "OrderBillDelete.ashx"
                parameters = ["billNumber": self.orderInfoModel!.billNumber!]
            case OrderOwedOperationControllerType.checkOwe:
                requestURLStr = "OOSRecordDelete.ashx"
                parameters = ["id": self.oweModel!.id]
            default:
                break
            }
            
            SAMNetWorker.sharedNetWorker().get(requestURLStr!, parameters: parameters!, progress: nil, success: {[weak self] (task, json) in
                
                //获取状态字符串
                let Json = json as! [String: AnyObject]
                let dict = Json["head"] as! [String: String]
                let state = dict["status"]
                
                if state == "success" { //删除成功
                    
                    hud.hide(true)
                    let hud = SAMHUD.showMessage("删除成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                    hud?.delegate = self
                }else { //删除失败
                    
                    hud.hide(true)
                    let _ = SAMHUD.showMessage("删除失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                }
            }) { (task, error) in
                
                hud.hide(true)
                let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
            }
        })
        )
        
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func saveEditBtnClick(_ sender: UIButton) {
        
        saveBtnClick(saveButton)
    }
    
    //MARK: - 属性懒加载
    ///控制器类型
    fileprivate var controllerType: OrderOwedOperationControllerType?
    ///tableView标题、内容数组
    fileprivate var titles: [[[String?]]]?
    ///标题cell的数据模型
    fileprivate var titleModels: [[SAMOrderBuildTitleModel?]]?
    
    ///接收的购物车中物品模型
    fileprivate var productToOrderModels: [SAMShoppingCarListModel]?
    ///当前查看的订单数据模型
    fileprivate var orderInfoModel: SAMOrderModel?
    
    ///缺货登记新建接收的产品库存数据模型
    fileprivate var stockModel: SAMStockProductModel?
    ///接收的缺货登记数据模型
    fileprivate var oweModel: SAMOwedInfoModel?
    
    ///保存URL (新建保存，和编辑保存，其他URL在各自方法中)
    fileprivate var saveUrlStr: String?
    
    ///当前是否可以编辑订单
    fileprivate var couldEdit: Bool = true
    
    ///产品组footerView统计信息
    fileprivate lazy var productSectionFooterView = SAMOrderProductSectionFooterView.instance()
    ///给产品组footerView提供的统计数字
    fileprivate var productSectionCountArr = [Double]()
    
    ///接收的客户模型
    fileprivate var orderCustomerModel: SAMCustomerModel?
    
    ///购物车编辑控件
    fileprivate var productOperationView: SAMProductOperationView?
    ///展示购物车时，主界面添加的蒙版
    fileprivate lazy var productOperationMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMOrderOwedOperationController.hideProductOperationViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()
    
    ///业务员数据模型
    fileprivate var orderBuildEmployeeModel: SAMOrderBuildEmployeeModel?

    //MARK: - XIB链接属性
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveBtnView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveAndAgreeSendButton: UIButton!
    
    @IBOutlet weak var editBtnView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveEditButton: UIButton!
    
    @IBOutlet weak var saveAndAgreeSendButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopDistance: NSLayoutConstraint!
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
        view = Bundle.main.loadNibNamed("SAMOrderOwedOperationController", owner: self, options: nil)![0] as! UIView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - tableView数据源方法 UITableViewDataSource
extension SAMOrderOwedOperationController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch controllerType! {
            case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
                self.updateCountData()
                return titleModels!.count
            
            case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
                return titleModels!.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controllerType! {
            case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
                if section == 1 { //产品列表组
                    return self.productToOrderModels?.count ?? 0
                }else { //订单内容组
                    return self.titleModels![section].count
                }
            
            case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
                return self.titleModels![section].count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch controllerType! {
            case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
                if indexPath.section == 1 { //产品列表组
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderBuildBigCellReuseIdentifier, for: indexPath) as! SAMOrderBuildBigCell
                    
                    //取出模型，传递模型
                    cell.productAddToOrderModel = productToOrderModels![indexPath.row] as SAMShoppingCarListModel
                    return cell
                }else { //订单内容组
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderBuildSmallCellReuseIdentifier, for: indexPath) as! SAMOrderBuildSmallCell
                    
                    //取出模型，传递模型
                    cell.titleModel = titleModels![indexPath.section][indexPath.row]! as SAMOrderBuildTitleModel
                    
                    //如果该订单已经发货，则不可编辑，或者最后一组不可编辑
                    if !couldEdit || (indexPath.section == titleModels!.count - 1) {
                        cell.setCellEditDisabledStyle()
                    }else {
                        cell.setCellEditEnabledStyle()
                    }
                    return cell
                }

            case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
            
                let cell = tableView.dequeueReusableCell(withIdentifier: SAMOrderBuildSmallCellReuseIdentifier, for: indexPath) as! SAMOrderBuildSmallCell
                
                //取出模型，传递模型
                cell.titleModel = titleModels![indexPath.section][indexPath.row]! as SAMOrderBuildTitleModel
                
                //如果该订单已经发货，则不可编辑，或者是转台栏
                if !couldEdit || cell.titleModel?.cellTitle == "状态" {
                    cell.setCellEditDisabledStyle()
                }else {
                    cell.setCellEditEnabledStyle()
                }
                return cell
        }
    }
}

//MARK: - tableView代理 UITableViewDelegate
extension SAMOrderOwedOperationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch controllerType! {
            case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
                if indexPath.section == 1 { //产品列表组
                    return 50
                }else { //订单内容组
                    return 44
            }
                
            case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
                return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch controllerType! {
            case OrderOwedOperationControllerType.buildOrder, OrderOwedOperationControllerType.checkOrder:
                if section == 0 {
                    return 20
                }else if section == 1 {
                    return 55
                }else if section == 2 {
                    return 30
                }else if section == 3 {
                    return 20
                }else {
                    return 0
                }
                
            case OrderOwedOperationControllerType.buildOwe, OrderOwedOperationControllerType.checkOwe:
                return 20
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == (titleModels!.count - 1) {
            return 20
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //透明View
        let clearView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 20))
        clearView.backgroundColor = UIColor.clear
        
        if controllerType! == OrderOwedOperationControllerType.buildOwe || controllerType! == OrderOwedOperationControllerType.checkOwe {
            return clearView
        }
        
        if section == 1 {
            let view = SAMOrderProductSectionHeaderView.instance(couldAddProduct: couldEdit)
            view.delegate = self
            return view
        }else if section == 2 {
            return productSectionFooterView
        }else {
            return clearView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //透明View
        let clearView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenW, height: 20))
        clearView.backgroundColor = UIColor.clear
        return clearView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //如果当前不能编辑，则取消选中，返回
        if !couldEdit {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        if ((indexPath.section == 1) && (controllerType == OrderOwedOperationControllerType.buildOrder || controllerType == OrderOwedOperationControllerType.checkOrder)) { //点击了产品组
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else if indexPath.section == 3 { //查看订单组中 日期、开单人。。。这组信息
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else {
            //点击cell的标题
            let cellTitle = titleModels![indexPath.section][indexPath.row]!.cellTitle
            if (cellTitle == "状态") || (cellTitle == "产品型号") {
                tableView.deselectRow(at: indexPath, animated: true)
                
            }else if cellTitle == "客户" { 
                navigationController!.pushViewController(SAMCustomerViewController.instance(controllerType: .OrderBuild), animated: true)
                
            }else {
                //取出模型，跳转编辑界面
                let model = titleModels![indexPath.section][indexPath.row]!
                let editVC = SAMOrderInfoEditController.editInfo(orderTitleModel: model, employeeModel: orderBuildEmployeeModel)
                navigationController!.pushViewController(editVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { //这个方法要进行设置，不然其他行也可以左滑
        
        if controllerType! == OrderOwedOperationControllerType.buildOwe || controllerType! == OrderOwedOperationControllerType.checkOwe {
            return .none
        }
        
        if !couldEdit {
            return .none
        }
        
        if indexPath.section != 1 {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if controllerType! == OrderOwedOperationControllerType.buildOwe || controllerType! == OrderOwedOperationControllerType.checkOwe {
            return nil
        }
        
        if indexPath.section == 1 {
            
            //取出cell
            let cell = tableView.cellForRow(at: indexPath) as! SAMOrderBuildBigCell
            
            //取出对应模型
            let model = cell.productAddToOrderModel!
            
            /*******************  查询按钮  ********************/
            let equiryAction = UITableViewRowAction(style: .normal, title: "查询") { (action, indexPath) in
                
                let stockVC = SAMStockViewController.instance(shoppingCarListModel: model, QRCodeScanStr: nil, type: .requestStock)
                self.navigationController?.pushViewController(stockVC, animated: true)
            }
            equiryAction.backgroundColor = UIColor(red: 0, green: 255 / 255.0, blue: 127 / 255.0, alpha: 1.0)
            
            /*******************  编辑按钮  ********************/
            let editAction = UITableViewRowAction(style: .default, title: "编辑") { (action, indexPath) in
                self.showShoppingCar(editModel: model)
            }
            editAction.backgroundColor = customBlueColor
            
            /*******************  删除按钮  ********************/
            let deleteAction = UITableViewRowAction(style: .normal, title: "删除") { (action, indexPath) in
                
                //获取数据模型对应的数组编号
                let index = self.productToOrderModels!.index(of: model)!
                
                //从源数组中删除
                self.productToOrderModels!.remove(at: index)
                
                //动画删除该行CELL
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .left)
            }
            deleteAction.backgroundColor = UIColor(red: 255 / 255.0, green: 69 / 255.0, blue: 0, alpha: 1.0)
            
            //如果只有这组只有一个产品了，不显示删除按钮
            if self.productToOrderModels!.count == 1 {
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
extension SAMOrderOwedOperationController: SAMProductOperationViewDelegate {
    func operationViewDidClickDismissButton() {
        //隐藏购物车
        hideProductOperationView(false)
    }
    
    func operationViewAddOrEditProductSuccess(_ productImage: UIImage, postShoppingCarListModelSuccess: Bool) {
        //隐藏购物车
        hideProductOperationView(true)
    }
}

//MARK: - 购物车相关方法
extension SAMOrderOwedOperationController {
    
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
        self.productOperationView = SAMProductOperationView.operationViewWillShow(nil, editProductModel: editModel, isFromeCheckOrder: true, postModelAfterOperationSuccess: false)
        
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

//MARK: - 监听HUD，看情况退出控制器
extension SAMOrderOwedOperationController: MBProgressHUDDelegate {
    func hudWasHidden(_ hud: MBProgressHUD!) {
        
        //退出控制器
        navigationController!.popViewController(animated: true)
    }
}

//MARK: - 产品组头部控件代理
extension SAMOrderOwedOperationController: SAMOrderProductSectionHeaderViewDelegate {

    func headerViewDidClickAddBtn() {
        
        let stockVC = SAMStockViewController.instance(shoppingCarListModel: nil, QRCodeScanStr: nil, type: .requestBuildOrder)
        navigationController!.pushViewController(stockVC, animated: true)
    }
    
    func headerViewDidClickQRBtn() {
        let QRCodeVC = LXMCodeViewController.instance(type: .buildOrder)
        navigationController!.pushViewController(QRCodeVC, animated: true)
    }
}
