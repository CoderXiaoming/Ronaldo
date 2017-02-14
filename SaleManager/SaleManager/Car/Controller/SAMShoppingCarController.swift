//
//  SAMShoppingCarController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJRefresh

///购物车CELL重用标识符
private let SAMShoppingCarListCellReuseIdentifier = "SAMShoppingCarListCellReuseIdentifier"

///购物车CELL标志正常图片
let SAMShoppingCarCellIndicaterNormalImage = UIImage(named: "shoppingCarSelectedButton_normal")
///购物车CELL标志选中图片
let SAMShoppingCarCellIndicaterSelectedImage = UIImage(named: "shoppingCarSelectedButton_selected")

class SAMShoppingCarController: UIViewController {

    ///单例
    fileprivate static let carViewVC: SAMShoppingCarController = SAMShoppingCarController()
    
    //MARK: - 对外提供的主单例单例方法
    class func sharedInstanceMain() -> SAMShoppingCarController {
        return carViewVC
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //设置tableView
        setupTableView()
    }
    
    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        //设置标题
        navigationItem.title = "购物车"
        
        //设置搜索框
        searchBar.showsCancelButton = false
        searchBar.placeholder = "产品名称\\备注内容"
        
        //监听键盘弹出通知
        NotificationCenter.default.addObserver(self, selector: #selector(SAMShoppingCarController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    //MARK: - 初始化tableView
    fileprivate func setupTableView() {
        
        //注册CELL
        tableView.register(UINib.init(nibName: "SAMShoppingCarListCell", bundle: nil), forCellReuseIdentifier: SAMShoppingCarListCellReuseIdentifier)
        
        //设置下拉
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMShoppingCarController.loadNewInfo))
        
        //设置行高
        tableView.rowHeight = 74
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //刷新界面数据
        tableView.mj_header.beginRefreshing()
    }
    
    //MARK: - 加载新数据
    func loadNewInfo() {
        
        //处理搜索框的状态
        if searchBar.showsCancelButton {
            searchBarCancelButtonClicked(searchBar)
        }
        
        //创建请求参数
        let userIDStr = SAMUserAuth.shareUser()!.id!
        let parameters = ["userID": userIDStr, "productIDName": ""]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getCartList.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            //设置全选按钮不选中
            self!.allSelectedButton.isSelected = false
            
            //清空原先数据
            self!.clearExpiredInfo()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                //提示用户
                let _ = SAMHUD.showMessage("暂无数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else { //有数据模型
                let arr = SAMShoppingCarListModel.mj_objectArray(withKeyValuesArray: dictArr)!
                self!.listModels.addObjects(from: arr as [AnyObject])
            }
            
            //回到主线程
            DispatchQueue.main.async(execute: {
                
                //结束上拉
                self!.tableView.mj_header.endRefreshing()
                //刷新数据
                self!.tableView.reloadData()
            })
        }) {[weak self] (Task, Error) in
            
            //处理上拉
            self!.tableView.mj_header.endRefreshing()
            //提示用户
            let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 清除过期数据
    fileprivate func clearExpiredInfo() {
        listModels.removeAllObjects()
        selectedModels.removeAllObjects()
    }
    
    //MARK: - 对外提供的设置购物车数量的方法
    func addOrMinusProductCountOne(_ add: Bool) {
        //改变计数
        var count = badgeCount
        count = add ? count + 1 : count - 1
        
        //判断计数
        count = count > 0 ? count : 0
        
        //记录数量
        badgeCount = count
    }
    
    //MARK: - 修改结算，删除按钮的文字
    fileprivate func checkAllButtonsState() {
        
        //获取数组数量
        let selectedCount = selectedModels.count
        
        //设置按钮文字
        let deleateStr = String(format: "删除(%d)", selectedCount)
        let orderStr = String(format: "下单(%d)", selectedCount)
        deleateButton.setTitle(deleateStr, for: UIControlState())
        orderButton.setTitle(orderStr, for: UIControlState())
        
        //根据 选中数量 和 是否在搜索状态 设置按钮状态
        if selectedCount != 0 && !isSearch {
            deleateButton.isEnabled = true
            orderButton.isEnabled = true
        }else {
            deleateButton.isEnabled = false
            orderButton.isEnabled = false
        }
        
        //根据源数组总数设置全选按钮状态
        let allCount = listModels.count
        if allCount != 0 && !isSearch {
            
            allSelectedButton.isEnabled = true
        }else {
            
            allSelectedButton.isEnabled = false
        }
    }
    
    //MARK: - 键盘弹出调用的方法
    func keyboardWillChangeFrame(_ notification: Notification) {
        
            //获取动画时长
            let animDuration = notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! Double
            //键盘终点frame
            let endKeyboardFrameStr = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"]
            let endKeyboardEndFrame = (endKeyboardFrameStr! as AnyObject).cgRectValue
            
            let endKeyboardEndY = endKeyboardEndFrame?.origin.y
            
            if endKeyboardEndY == ScreenH { //键盘即将隐藏
                
                UIView.animate(withDuration: animDuration, animations: {
                    
                    self.bottomToolBar.transform = CGAffineTransform.identity
                    }, completion: { (_) in
                })
            }else { //键盘即将展示
                
                //计算形变
                let transformY = tabBarController!.tabBar.bounds.height - (endKeyboardEndFrame?.height)!
                UIView.animate(withDuration: animDuration, animations: {
                    self.bottomToolBar.transform = CGAffineTransform(translationX: 0, y: transformY)
                    }, completion: { (_) in
                })
            }
    }
    
    //MARK: - 属性懒加载
    /// tabbar右上角数字
    fileprivate var badgeCount: Int = 0 {
        didSet{
            //设置badgeValue
            let tabbarItem = tabBarController!.tabBar.items![3] as UITabBarItem
            if badgeCount == 0 {
                tabbarItem.badgeValue = nil
            }else {
                tabbarItem.badgeValue = String(format: "%d", badgeCount)
            }
        }
    }
    
    ///源模型数组
    fileprivate let listModels = NSMutableArray()
    
    ///选中的模型数组
    fileprivate let selectedModels = NSMutableArray()
    
    ///记录当前是否在搜索
    fileprivate var isSearch: Bool = false {
        didSet{
            self.allSelectedButton.isEnabled = !isSearch
        }
    }
    ///符合搜索结果模型数组
    fileprivate let searchResultModels = NSMutableArray()
    
    ///添加产品的动画layer数组
    fileprivate lazy var addProductAnimLayers = [CALayer]()
    
    ///购物车选择控件
    fileprivate var productOperationView: SAMProductOperationView?
    ///展示购物车时，主界面添加的蒙版
    fileprivate lazy var productOperationMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.black
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMShoppingCarController.hideProductOperationViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()

    //MARK: - XIB链接点击事件处理
    @IBAction func allSelectedBtnClick(_ sender: UIButton) {
        
        //获取更改后的选中状态
        let selected = !sender.isSelected
        
        //改变按钮状态
        sender.isSelected = selected
        
        //移除所有记录数据
        selectedModels.removeAllObjects()
        
        //更改所有模型状态
        if isSearch { //正在搜索状态
            
            searchResultModels.enumerateObjects({ (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，当前模型对应源数组的序号添加到记录数组中
                if selected {
                    selectedModels.add(model)
                }
            })
        }else { //不是在搜索状态
            
            listModels.enumerateObjects({ (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，创建indexPath添加到数组中
                if selected {
                    selectedModels.add(model)
                }
            })
        }
        
        //更新tableView
        tableView.reloadData()
    }
    
    @IBAction func deleteBtnClick(_ sender: UIButton) {
        
        //创建 UIAlertController
        let totalCount = listModels.count
        let deleateCount = selectedModels.count
        var alertMessage: String
        if deleateCount == totalCount {
            alertMessage = "是否清空购物车？"
        }else {
            alertMessage = String(format: "是否删除这%d条？", deleateCount)
        }
        let alertVC = UIAlertController(title: alertMessage, message: nil, preferredStyle: .alert)
        
        //添加两个按钮
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
        }))
        alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (_) in
            
            //设置全选按钮状态
            self.allSelectedButton.isSelected = false
            
            let deleateArr = self.selectedModels.mutableCopy()
            
            //从 源模型数组 和 选中数组 中删除选中模型
            self.selectedModels.removeAllObjects()
            
            //遍历删除数组
            (deleateArr as AnyObject).enumerateObjects { (obj, index, _) in
                
                //获取模型 和 源数组中对应的编号
                let model = obj as! SAMShoppingCarListModel
                let orignalIndex = self.listModels.index(of: model)
                
                //从源数组中删除对应模型
                self.listModels.removeObject(at: orignalIndex)
                //动画删除对应组
                self.tableView.deleteSections(IndexSet.init(integer: orignalIndex), with: .left)
                
                //异步发送删除请求
                let parameters = ["id": model.id]
                SAMNetWorker.sharedNetWorker().post("CartDelete.ashx", parameters: parameters, progress: nil, success: { (task, Json) in
                }, failure: { (task, error) in
                })
            }
        }))
        
        //展示控制器
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func orderBtnClick(_ sender: UIButton) {
        
        ///创建需要的模型数组
        var models = [SAMShoppingCarListModel]()
        selectedModels.enumerateObjects({ (obj, index, _) in
            let model = obj as! SAMShoppingCarListModel
            models.append(model)
        })
        
        let buildOrderVC = SAMOrderOwedOperationController.buildOrder(productModels: models, type: .buildOrder)
        
        //判断当前导航栏是否隐藏
        if navigationController!.isNavigationBarHidden { //如果当前导航栏隐藏，直接复制取消按钮点击代码
            //结束搜索框编辑状态
            searchBar.text = ""
            searchBar.resignFirstResponder()
            //执行结束动画
            UIView.animate(withDuration: 0.3, animations: {
                self.navigationController!.setNavigationBarHidden(false, animated: false)
                self.searchBar.transform = CGAffineTransform.identity
                self.tableView.transform = CGAffineTransform.identity
                self.searchBar.showsCancelButton = false
            }, completion: { (_) in
                self.isSearch = false
                self.deleateButton.isEnabled = true
                self.orderButton.isEnabled = true
                self.tableView.reloadData()
                self.navigationController!.pushViewController(buildOrderVC, animated: true)
            }) 
        }else {
            navigationController!.pushViewController(buildOrderVC, animated: true)
        }
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var allSelectedButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var deleateButton: UIButton!
    
    //MARK: - 其他方法
    fileprivate init() {
        super.init(nibName: nil, bundle: nil)
    }
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMShoppingCarController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - tableView数据源方法 UITableViewDataSource
extension SAMShoppingCarController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        //检查所有按钮的状态
        checkAllButtonsState()
        
        //获取总数组数值，赋值badgeValue
        let count = listModels.count
        badgeCount = count
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        return sourceArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //获取重用Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMShoppingCarListCellReuseIdentifier) as! SAMShoppingCarListCell
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        cell.listModel = sourceArr[indexPath.section] as? SAMShoppingCarListModel
        
        return cell
    }
}

//MARK: - tableView代理 UITableViewDelegate
extension SAMShoppingCarController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //调用下面方法
        tableViewSelectOrDeselectCellAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        //调用下面方法
        tableViewSelectOrDeselectCellAt(indexPath)
    }
    
    //选中cell或取消选中cell集中调用
    fileprivate func tableViewSelectOrDeselectCellAt(_ indexPath: IndexPath) {
        
        //结束搜索框编辑状态
        searchBar.endEditing(true)
        
        //取出cell
        let cell = tableView.cellForRow(at: indexPath) as! SAMShoppingCarListCell
        
        //取出模型
        let model = cell.listModel!
        
        //更改模型记录数据
        model.selected = !model.selected
        
        if model.selected { //添加数据模型的情况下
            
            //添加到选中数组中
            selectedModels.add(model)
            
            //执行添加动画
            let productImageViewConvertFrame = cell.convert(cell.productImageView.frame, to: view)
            addProductAnim(cell.productImageView.image!, ImageFrame: productImageViewConvertFrame)
        }else { //删除数据模型的情况下
            
            //从选中数组中删除
            selectedModels.remove(model)
        }
        
        //刷新数据
        tableView.reloadData()
    }
    
    //添加产品时的动画
    fileprivate func addProductAnim(_ productImage: UIImage, ImageFrame: CGRect) {
        
        /******************  layer路线动画  ******************/
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = UIBezierPath()
        //计算各点
        let imageViewCenterX = ImageFrame.origin.x + ImageFrame.width * 0.5
        let imageViewCenterY = ImageFrame.origin.y + ImageFrame.height * 0.5
        let orderButtonConvertFrame = bottomToolBar.convert(orderButton.frame, to: view)
        let startPoint = CGPoint(x: imageViewCenterX, y: imageViewCenterY)
        var endPoint = orderButtonConvertFrame.origin
        endPoint.x = endPoint.x + 20
        let controlPoint = CGPoint(x: (endPoint.x - startPoint.x) * 0.5 + 100, y: startPoint.y - 50)
        //连线
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        pathAnimation.path = path.cgPath
        pathAnimation.rotationMode = kCAAnimationRotateAuto
        
        /******************  layer缩小动画  ******************/
        let narrowAnimation = CABasicAnimation(keyPath: "transform.scale")
        narrowAnimation.fromValue = 1
        narrowAnimation.toValue = 0.4
        narrowAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        //组合成组动画
        let group = CAAnimationGroup()
        group.animations = [pathAnimation, narrowAnimation]
        group.duration = 0.5
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate = self

        //设置动画layer
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspectFill
        layer.cornerRadius = 15
        layer.masksToBounds = true
        layer.frame = ImageFrame
        layer.contents = productImage.cgImage
        view.layer.addSublayer(layer)
        layer.add(group, forKey: "group")
        
        addProductAnimLayers.append(layer)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //结束搜索框编辑状态
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else {
            return 5
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (listModels.count - 1) {
            return 10
        }else {
            return 5
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //取出cell
        let cell = tableView.cellForRow(at: indexPath) as! SAMShoppingCarListCell
        
        //取出对应模型
        let model = cell.listModel!
        
        
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
        
        //操作数组
        return[editAction, equiryAction]
    }
}

//MARK: - 搜索框代理UISearchBarDelegate
extension SAMShoppingCarController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //取消全选按钮选中状态
        allSelectedButton.isSelected = false
        
        //清空搜索结果数组,并赋值
        searchResultModels.removeAllObjects()
        searchResultModels.addObjects(from: listModels as [AnyObject])
        
        //获取搜索字符串
        let searchStr = NSString(string: searchText.lxm_stringByTrimmingWhitespace()!)
        
        if searchStr.length > 0 {
            
            //记录正在搜索
            isSearch = true
            
            //获取搜索字符串数组
            let searchItems = searchStr.components(separatedBy: " ")
            
            var andMatchPredicates = [NSPredicate]()
            
            for item in searchItems {
                
                let searchString = item as NSString
                
                //productIDName搜索谓语
                var lhs = NSExpression(forKeyPath: "productIDName")
                let rhs = NSExpression(forConstantValue: searchString)
                let firstPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                
                //memoInfo搜索谓语
                lhs = NSExpression(forKeyPath: "memoInfo")
                let secondPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                
               let orMatchPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstPredicate, secondPredicate])
               andMatchPredicates.append(orMatchPredicate)
            }
            
            let finalCompoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: andMatchPredicates)
            
            //存储搜索结果
            let arr = searchResultModels.filtered(using: finalCompoundPredicate)
            searchResultModels.removeAllObjects()
            searchResultModels.addObjects(from: arr)
        }else {
            //记录没有搜索
            isSearch = false
        }
        
        //刷新tableView
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //取消全选按钮选中状态
        allSelectedButton.isSelected = false
        
        //设置删除，下单按钮不可用
        deleateButton.isEnabled = false
        orderButton.isEnabled = false
        
        //执行准备动画
        UIView.animate(withDuration: 0.3, animations: {
            
                self.navigationController!.setNavigationBarHidden(true, animated: true)
            }, completion: { (_) in
                
                UIView.animate(withDuration: 0.2, animations: {
                    searchBar.transform = CGAffineTransform(translationX: 0, y: 20)
                    self.tableView.transform = CGAffineTransform(translationX: 0, y: 20)
                    searchBar.showsCancelButton = true
                }) 
        }) 
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //结束搜索框编辑状态
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        //执行结束动画
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController!.setNavigationBarHidden(false, animated: false)
            searchBar.transform = CGAffineTransform.identity
            self.tableView.transform = CGAffineTransform.identity
            searchBar.showsCancelButton = false
            }, completion: { (_) in
                
                //结束搜索状态
                self.isSearch = false
                
                //设置删除，下单按钮可用
                self.deleateButton.isEnabled = true
                self.orderButton.isEnabled = true
                
                //刷新数据
                self.tableView.reloadData()
        }) 
    }
    
    //MARK: - 点击键盘搜索按钮调用
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }
}

//MARK: - 动画代理CAAnimationDelegate
extension SAMShoppingCarController: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        let layer = addProductAnimLayers[0]
        
        if anim == layer.animation(forKey: "group") {
            
            //移除动画
            layer.removeAllAnimations()
            
            //移除动画图层
            layer.removeFromSuperlayer()
            
            //从图层数组中移除
            addProductAnimLayers.remove(at: 0)
        }
    }
}

//MARK: - 购物车代理SAMProductOperationViewDelegate
extension SAMShoppingCarController: SAMProductOperationViewDelegate {
    
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
extension SAMShoppingCarController {
    
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
        self.productOperationView = SAMProductOperationView.operationViewWillShow(nil, editProductModel: editModel, isFromeCheckOrder: false, postModelAfterOperationSuccess: false)
        
        
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
                        self.tableView.mj_header.beginRefreshing()
                    }
            })
        }) 
    }
}
