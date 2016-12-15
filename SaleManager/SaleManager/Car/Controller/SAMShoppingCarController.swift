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
    private static let carViewVC: SAMShoppingCarController = SAMShoppingCarController()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
        
        //设置tableView
        setupTableView()
    }
    
    //MARK: - 初始化UI
    private func setupUI() {
        
        //设置标题
        navigationItem.title = "购物车"
        
        //设置搜索框
        searchBar.showsCancelButton = false
        searchBar.placeholder = "产品名称\\备注内容"
        
        //监听键盘弹出通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SAMShoppingCarController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: - 初始化tableView
    private func setupTableView() {
        
        //注册CELL
        tableView.registerNib(UINib.init(nibName: "SAMShoppingCarListCell", bundle: nil), forCellReuseIdentifier: SAMShoppingCarListCellReuseIdentifier)
        
        //设置下拉
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMShoppingCarController.loadNewInfo))
        
        //设置行高
        tableView.rowHeight = 74
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
        SAMNetWorker.sharedNetWorker().GET("getCartList.ashx", parameters: parameters, progress: nil, success: { (Task, Json) in
            
            //设置全选按钮不选中
            self.allSelectedButton.selected = false
            
            //清空原先数据
            self.clearExpiredInfo()
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                
                //提示用户
                SAMHUD.showMessage("暂无订单", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMShoppingCarListModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                self.listModels.addObjectsFromArray(arr as [AnyObject])
            }
            
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), {
                
                //结束上拉
                self.tableView.mj_header.endRefreshing()
                //刷新数据
                self.tableView.reloadData()
            })
        }) { (Task, Error) in
            
            //处理上拉
            self.tableView.mj_header.endRefreshing()
            //提示用户
            SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 清除过期数据
    private func clearExpiredInfo() {
        listModels.removeAllObjects()
        selectedModels.removeAllObjects()
    }
    
    //MARK: - 对外提供的设置购物车数量的方法
    func addOrMinusProductCountOne(add: Bool) {
        //改变计数
        var count = badgeCount
        count = add ? count + 1 : count - 1
        
        //判断计数
        count = count > 0 ? count : 0
        
        //记录数量
        badgeCount = count
    }
    
    //MARK: - 修改结算，删除按钮的文字
    private func checkAllButtonsState() {
        
        //获取数组数量
        let selectedCount = selectedModels.count
        
        //设置按钮文字
        let deleateStr = String(format: "删除(%d)", selectedCount)
        let orderStr = String(format: "下单(%d)", selectedCount)
        deleateButton.setTitle(deleateStr, forState: .Normal)
        orderButton.setTitle(orderStr, forState: .Normal)
        
        //根据 选中数量 和 是否在搜索状态 设置按钮状态
        if selectedCount != 0 && !isSearch {
            deleateButton.enabled = true
            orderButton.enabled = true
        }else {
            deleateButton.enabled = false
            orderButton.enabled = false
        }
        
        //根据源数组总数设置全选按钮状态
        let allCount = listModels.count
        if allCount != 0 && !isSearch {
            
            allSelectedButton.enabled = true
        }else {
            
            allSelectedButton.enabled = false
        }
    }
    
    //MARK: - 键盘弹出调用的方法
    func keyboardWillChangeFrame(notification: NSNotification) {
        
            //获取动画时长
            let animDuration = notification.userInfo!["UIKeyboardAnimationDurationUserInfoKey"] as! Double
            //键盘终点frame
            let endKeyboardFrameStr = notification.userInfo!["UIKeyboardFrameEndUserInfoKey"]
            let endKeyboardEndFrame = endKeyboardFrameStr!.CGRectValue()
            
            let endKeyboardEndY = endKeyboardEndFrame.origin.y
            
            if endKeyboardEndY == ScreenH { //键盘即将隐藏
                
                UIView.animateWithDuration(animDuration, animations: {
                    
                    self.bottomToolBar.transform = CGAffineTransformIdentity
                    }, completion: { (_) in
                })
            }else { //键盘即将展示
                
                //计算形变
                let transformY = tabBarController!.tabBar.bounds.height - endKeyboardEndFrame.height
                UIView.animateWithDuration(animDuration, animations: {
                    self.bottomToolBar.transform = CGAffineTransformMakeTranslation(0, transformY)
                    }, completion: { (_) in
                })
            }
    }
    
    //MARK: - 属性懒加载
    /// tabbar右上角数字
    private var badgeCount: Int = 0 {
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
    private var listModels = NSMutableArray()
    
    ///选中的模型数组
    private var selectedModels = NSMutableArray()
    
    ///记录当前是否在搜索
    private var isSearch: Bool = false {
        didSet{
            self.allSelectedButton.enabled = !isSearch
        }
    }
    ///符合搜索结果模型数组
    private var searchResultModels = NSMutableArray()
    
    ///添加产品的动画layer数组
    private lazy var addProductAnimLayers = [CALayer]()
    
    ///购物车选择控件
    private var shoppingCarView: SAMStockAddShoppingCarView?
    ///展示购物车时，主界面添加的蒙版
    private lazy var shoppingCarMaskView: UIView = {
        
        let maskView = UIView(frame: UIScreen.mainScreen().bounds)
        maskView.backgroundColor = UIColor.blackColor()
        maskView.alpha = 0.0
        
        //添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(SAMShoppingCarController.hideShoppingCarViewWhenMaskViewDidClick))
        maskView.addGestureRecognizer(tap)
        
        return maskView
    }()

    //MARK: - XIB链接点击事件处理
    @IBAction func allSelectedBtnClick(sender: UIButton) {
        
        //获取更改后的选中状态
        let selected = !sender.selected
        
        //改变按钮状态
        sender.selected = selected
        
        //移除所有记录数据
        selectedModels.removeAllObjects()
        
        //更改所有模型状态
        if isSearch { //正在搜索状态
            
            searchResultModels.enumerateObjectsUsingBlock { (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，当前模型对应源数组的序号添加到记录数组中
                if selected {
                    selectedModels.addObject(model)
                }
            }
        }else { //不是在搜索状态
            
            listModels.enumerateObjectsUsingBlock { (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，创建indexPath添加到数组中
                if selected {
                    selectedModels.addObject(model)
                }
            }
        }
        
        //更新tableView
        tableView.reloadData()
    }
    
    @IBAction func deleteBtnClick(sender: UIButton) {
        
        //设置全选按钮状态
        allSelectedButton.selected = false
        
        let deleateArr = selectedModels.mutableCopy()
        
        //从 源模型数组 和 选中数组 中删除选中模型
        selectedModels.removeAllObjects()
        
        //遍历删除数组
        deleateArr.enumerateObjectsUsingBlock { (obj, index, _) in
            
            //获取模型 和 源数组中对应的编号
            let model = obj as! SAMShoppingCarListModel
            let orignalIndex = listModels.indexOfObject(model)
            
            //从源数组中删除对应模型
            listModels.removeObjectAtIndex(orignalIndex)
            //动画删除对应组
            tableView.deleteSections(NSIndexSet.init(index: orignalIndex), withRowAnimation: .Left)
            
            //异步发送删除请求
            let parameters = ["id": model.id!]
            SAMNetWorker.sharedNetWorker().POST("CartDelete.ashx", parameters: parameters, progress: nil, success: { (task, Json) in
                }, failure: { (task, error) in
            })
        }
    }
    
    @IBAction func orderBtnClick(sender: UIButton) {
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var allSelectedButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var deleateButton: UIButton!
    
    //MARK: - 其他方法
    //MARK: - 对外提供的提供单例
    class func sharedInstance() -> SAMShoppingCarController {
        return carViewVC
    }
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("SAMShoppingCarController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//MARK: - tableView数据源方法 UITableViewDataSource
extension SAMShoppingCarController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        //检查所有按钮的状态
        checkAllButtonsState()
        
        //获取总数组数值，赋值badgeValue
        let count = listModels.count ?? 0
        badgeCount = count
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        return sourceArr.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //获取重用Cell
        let cell = tableView.dequeueReusableCellWithIdentifier(SAMShoppingCarListCellReuseIdentifier) as! SAMShoppingCarListCell
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        cell.listModel = sourceArr[indexPath.section] as? SAMShoppingCarListModel
        
        return cell
    }
}

//MARK: - tableView代理 UITableViewDelegate
extension SAMShoppingCarController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //调用下面方法
        tableViewSelectOrDeselectCellAt(indexPath)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        //调用下面方法
        tableViewSelectOrDeselectCellAt(indexPath)
    }
    
    //MARK: - 选中cell或取消选中cell集中调用
    private func tableViewSelectOrDeselectCellAt(indexPath: NSIndexPath) {
        
        //结束搜索框编辑状态
        searchBar.endEditing(true)
        
        //取出cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SAMShoppingCarListCell
        
        //取出模型
        let model = cell.listModel!
        
        //更改模型记录数据
        model.selected = !model.selected
        
        if model.selected { //添加数据模型的情况下
            
            //添加到选中数组中
            selectedModels.addObject(model)
            
            //执行添加动画
            let productImageViewConvertFrame = cell.convertRect(cell.productImageView.frame, toView: view)
            addProductAnim(cell.productImageView.image!, ImageFrame: productImageViewConvertFrame)
        }else { //删除数据模型的情况下
            
            //从选中数组中删除
            selectedModels.removeObject(model)
        }
        
        //刷新数据
        tableView.reloadData()
    }
    
    //MARK: - 添加产品时的动画
    private func addProductAnim(productImage: UIImage, ImageFrame: CGRect) {
        
        /******************  layer路线动画  ******************/
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        let path = UIBezierPath()
        //计算各点
        let imageViewCenterX = ImageFrame.origin.x + ImageFrame.width * 0.5
        let imageViewCenterY = ImageFrame.origin.y + ImageFrame.height * 0.5
        let orderButtonConvertFrame = bottomToolBar.convertRect(orderButton.frame, toView: view)
        let startPoint = CGPointMake(imageViewCenterX, imageViewCenterY)
        var endPoint = orderButtonConvertFrame.origin
        endPoint.x = endPoint.x + 20
        let controlPoint = CGPoint(x: (endPoint.x - startPoint.x) * 0.5 + 100, y: startPoint.y - 50)
        //连线
        path.moveToPoint(startPoint)
        path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
        pathAnimation.path = path.CGPath
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
        group.removedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate = self

        //设置动画layer
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspectFill
        layer.cornerRadius = 15
        layer.masksToBounds = true
        layer.frame = ImageFrame
        layer.contents = productImage.CGImage
        view.layer.addSublayer(layer)
        layer.addAnimation(group, forKey: "group")
        
        addProductAnimLayers.append(layer)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //结束搜索框编辑状态
        searchBar.endEditing(true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else {
            return 5
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (listModels.count - 1) {
            return 10
        }else {
            return 5
        }
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //取出cell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SAMShoppingCarListCell
        
        //取出对应模型
        let model = cell.listModel!
        
        /*******************  查询按钮  ********************/
        let equiryAction = UITableViewRowAction(style: .Normal, title: "查询") { (action, indexPath) in
            SAMStockViewController.stockRequest(model.productIDName!)
            self.tabBarController!.selectedIndex = 1
        }
        equiryAction.backgroundColor = mainColor_green
        
        /*******************  编辑按钮  ********************/
        let editAction = UITableViewRowAction(style: .Destructive, title: "编辑") { (action, indexPath) in
            self.showShoppingCar(cell.productImageView.image!, editModel: model)
        }
        editAction.backgroundColor = customBlueColor
        
        /*******************  删除按钮  ********************/
//        let deleteAction = UITableViewRowAction(style: .Destructive, title: "删除") { (action, indexPath) in
//            
//            //从源数组中删除
//            self.listModels.removeObject(model)
//            
//            //如果当前是编辑状态
//            if self.isSearch {
//            
//                //从选择数组中删除
//                self.searchResultModels.removeObject(model)
//            }
//            
//            //动画删除该行CELL
//            tableView.deleteSections(NSIndexSet.init(index: indexPath.section), withRowAnimation: .Left)
//            
//            //检查按钮状态
//            self.checkAllButtonsState()
//            
//            //异步发送删除请求
//            let parameters = ["id": model.id!]
//            SAMNetWorker.sharedNetWorker().POST("CartDelete.ashx", parameters: parameters, progress: nil, success: { (task, Json) in
//                }, failure: { (task, error) in
//            })
//        }
        
        //操作数组
        return[editAction, equiryAction]
    }
}

//MARK: - 搜索框代理UISearchBarDelegate
extension SAMShoppingCarController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        //取消全选按钮选中状态
        allSelectedButton.selected = false
        
        //清空搜索结果数组,并赋值
        searchResultModels.removeAllObjects()
        searchResultModels.addObjectsFromArray(listModels as [AnyObject])
        
        //获取搜索字符串
        let searchStr = NSString(string: searchText.lxm_stringByTrimmingWhitespace()!)
        
        if searchStr.length > 0 {
            
            //记录正在搜索
            isSearch = true
            
            //获取搜索字符串数组
            let searchItems = searchStr.componentsSeparatedByString(" ")
            
            var andMatchPredicates = [NSPredicate]()
            
            for item in searchItems {
                
                let searchString = item as NSString
                
                //productIDName搜索谓语
                var lhs = NSExpression(forKeyPath: "productIDName")
                let rhs = NSExpression(forConstantValue: searchString)
                let firstPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type:
                    .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                
                //memoInfo搜索谓语
                lhs = NSExpression(forKeyPath: "memoInfo")
                let secondPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .DirectPredicateModifier, type:
                    .ContainsPredicateOperatorType, options: .CaseInsensitivePredicateOption)
                
               let orMatchPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstPredicate, secondPredicate])
               andMatchPredicates.append(orMatchPredicate)
            }
            
            let finalCompoundPredicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: andMatchPredicates)
            
            //存储搜索结果
            let arr = searchResultModels.filteredArrayUsingPredicate(finalCompoundPredicate)
            searchResultModels.removeAllObjects()
            searchResultModels.addObjectsFromArray(arr)
        }else {
            //记录没有搜索
            isSearch = false
        }
        
        //刷新tableView
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        //取消全选按钮选中状态
        allSelectedButton.selected = false
        
        //设置删除，下单按钮不可用
        deleateButton.enabled = false
        orderButton.enabled = false
        
        //执行准备动画
        UIView.animateWithDuration(0.3, animations: {
            
                self.navigationController!.setNavigationBarHidden(true, animated: true)
            }) { (_) in
                
                UIView.animateWithDuration(0.2) {
                    searchBar.transform = CGAffineTransformMakeTranslation(0, 20)
                    self.tableView.transform = CGAffineTransformMakeTranslation(0, 20)
                    searchBar.showsCancelButton = true
                }
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        //结束搜索框编辑状态
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        //执行结束动画
        UIView.animateWithDuration(0.3, animations: {
            self.navigationController!.setNavigationBarHidden(false, animated: false)
            searchBar.transform = CGAffineTransformIdentity
            self.tableView.transform = CGAffineTransformIdentity
            searchBar.showsCancelButton = false
            }) { (_) in
                
                //结束搜索状态
                self.isSearch = false
                
                //设置删除，下单按钮可用
                self.deleateButton.enabled = true
                self.orderButton.enabled = true
                
                //刷新数据
                self.tableView.reloadData()
        }
    }
    
    //MARK: - 点击键盘搜索按钮调用
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }
}

//MARK: - 动画代理CAAnimationDelegate
extension SAMShoppingCarController: CAAnimationDelegate {
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        let layer = addProductAnimLayers[0]
        
        if anim == layer.animationForKey("group") {
            
            //移除动画
            layer.removeAllAnimations()
            
            //移除动画图层
            layer.removeFromSuperlayer()
            
            //从图层数组中移除
            addProductAnimLayers.removeAtIndex(0)
        }
    }
}

//MARK: - 购物车代理SAMStockAddShoppingCarViewDelegate
extension SAMShoppingCarController: SAMStockAddShoppingCarViewDelegate {
    
    func shoppingCarViewDidClickDismissButton() {
        
        //隐藏购物车
        hideShoppingCarView(false)
    }
    
    func shoppingCarViewAddOrEditProductSuccess(productImage: UIImage) {
        //隐藏购物车
        hideShoppingCarView(true)
    }
}

//MARK: - 购物车相关方法
extension SAMShoppingCarController {
    
    //view的第一步动画
    private func firstTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m24 = -1/2000
        transform = CATransform3DScale(transform, 0.9, 0.9, 1)
        return transform
    }
    
    //view的第二步动画
    private func secondTran() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, 0, self.view.frame.size.height * (-0.08), 0)
        transform = CATransform3DScale(transform, 0.8, 0.8, 1)
        return transform
    }
    
    //点击maskView隐藏购物车控件
    func hideShoppingCarViewWhenMaskViewDidClick() {
        
        hideShoppingCarView(false)
    }
    
    //展示购物车
    func showShoppingCar(productImage: UIImage, editModel: SAMShoppingCarListModel) {
    
        //设置购物车控件的目标frame
        self.shoppingCarView = SAMStockAddShoppingCarView.shoppingCarViewWillShow(productImage, addProductModel: nil, editProductModel: editModel)
        self.shoppingCarView!.delegate = self
        self.shoppingCarView!.frame = CGRect(x: 0, y: ScreenH, width: ScreenW, height: 350)
        
        var rect = self.shoppingCarView!.frame
        rect.origin.y = ScreenH - rect.size.height
        
        //添加背景View
        self.tabBarController!.view.addSubview(self.shoppingCarMaskView)
        KeyWindow?.addSubview(self.shoppingCarView!)
        
        //动画展示购物车控件
        UIView.animateWithDuration(0.5) {
            self.shoppingCarView!.frame = rect
        }
        
        //动画移动背景View
        UIView.animateWithDuration(0.25, animations: {
            
            //执行第一步动画
            self.shoppingCarMaskView.alpha = 0.5
            self.tabBarController!.view.layer.transform = self.firstTran()
        }) { (_) in
            
            //执行第二步动画
            UIView.animateWithDuration(0.25, animations: {
                self.tabBarController!.view.layer.transform = self.secondTran()
                }, completion: { (_) in
            })
        }
    }
    
    //隐藏购物车控件
    func hideShoppingCarView(editSuccess: Bool) {
        
        //结束 tableView 编辑状态
        self.tableView.editing = false
        
        //设置购物车目标frame
        var rect = self.shoppingCarView!.frame
        rect.origin.y = ScreenH
        
        //动画隐藏购物车控件
        UIView.animateWithDuration(0.5) {
            
            self.shoppingCarView!.frame = rect
        }
        
        //动画展示主View
        UIView.animateWithDuration(0.25, animations: {
            
            self.tabBarController!.view.layer.transform = self.firstTran()
            
            self.shoppingCarMaskView.alpha = 0.0
        }) { (_) in
            
            //移除蒙板
            self.shoppingCarMaskView.removeFromSuperview()
            
            UIView.animateWithDuration(0.25, animations: {
                
                self.tabBarController!.view.layer.transform = CATransform3DIdentity
                
                }, completion: { (_) in
                    
                    //移除购物车
                    self.shoppingCarView!.removeFromSuperview()
                    
                    //调用成功添加购物车的动画
                    if editSuccess {
                        self.tableView.mj_header.beginRefreshing()
                    }
            })
        }
    }
}
/*
 #pragma mark - TableView代理方法
 /**
 * 只要实现这个方法，左划cell出现删除按钮的功能就有了
 * 用户提交了添加（点击了添加按钮）\删除（点击了删除按钮）操作时会调用
 */
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {  // 点击了“删除”
 // 删除模型
 [self.deals removeObjectAtIndex:indexPath.row];
 
 // 刷新表格
 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) { // 点击了+
 NSLog(@"+++++ %zd", indexPath.row);
 }
 }
 
 /**
 * 这个方法决定了编辑模式时，每一行的编辑类型：insert（+按钮）、delete（-按钮）
 */
 //- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
 //{
 //    return indexPath.row % 2 == 0? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
 //}
 */
