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
        
        //停止搜索框编辑状态
        searchBar.endEditing(true)
        
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
            SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 清楚过期数据
    private func clearExpiredInfo() {
        listModels.removeAllObjects()
        selectedIndexs.removeAllObjects()
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
    //TODO: 明天继续
    
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
    
    ///模型数组
    private var listModels = NSMutableArray()
    
    ///选中的cell IndexPath数组
    private var selectedIndexs = NSMutableArray()
    
    ///记录当前是否在搜索
    private var isSearch: Bool = false
    
    ///符合搜索结果模型数组
    private var searchResultModels = NSMutableArray()
    
    ///添加产品的动画layer数组
    private lazy var addProductAnimLayers = [CALayer]()
    
    //MARK: - 点击事件处理
    @IBAction func allSelectedBtnClick(sender: UIButton) {
        
        //获取更改后的选中状态
        let selected = !sender.selected
        
        //改变按钮状态
        sender.selected = selected
        
        //移除所有记录数据
        selectedIndexs.removeAllObjects()
        
        //更改所有模型状态
        if isSearch { //正在搜索状态
            
            searchResultModels.enumerateObjectsUsingBlock { (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，当前模型对应源数组的序号添加到记录数组中
                if selected {
                    let index = listModels.indexOfObject(model)
                    selectedIndexs.addObject(index)
                }
            }
        }else { //不是在搜索状态
            
            listModels.enumerateObjectsUsingBlock { (obj, index, _) in
                let model = obj as! SAMShoppingCarListModel
                model.selected = selected
                
                //如果为选中状态，创建indexPath添加到数组中
                if selected {
                    selectedIndexs.addObject(index)
                }
            }
        }
        
        //更新tableView
        tableView.reloadData()
    }
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomToolBar: UIView!
    @IBOutlet weak var allSelectedButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    
    //MARK: - 其他方法
    //MARK: - 对外提供的提供单例
    class func sharedInstance() -> SAMShoppingCarController {
        return carViewVC
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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

extension SAMShoppingCarController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //获取总数组数值
        let count = listModels.count ?? 0
        //赋值badgeValue
        badgeCount = count
        
        if isSearch {
            
            //获取搜索结果数组数值
            let searchCount = searchResultModels.count ?? 0
            return searchCount
        }else {
            
            return count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SAMShoppingCarListCellReuseIdentifier) as! SAMShoppingCarListCell
        
        //取出模型, 传递模型
        var listModel: SAMShoppingCarListModel
        if isSearch {
            
            listModel = searchResultModels[indexPath.section] as! SAMShoppingCarListModel
        }else {
            listModel = listModels[indexPath.section] as! SAMShoppingCarListModel
        }
        cell.listModel = listModel
        
        return cell
    }
}

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
        
        //取出模型在源数组中的记号,记录或者删除
        let index = listModels.indexOfObject(model)
        if model.selected {
            selectedIndexs.addObject(index)
            
            //执行添加动画
            let productImageViewConvertFrame = cell.convertRect(cell.productImageView.frame, toView: view)
            addProductAnim(cell.productImageView.image!, ImageFrame: productImageViewConvertFrame)
        }else {
            selectedIndexs.removeObject(index)
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
}

extension SAMShoppingCarController: UISearchBarDelegate {

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
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
                
                //刷新数据
                self.tableView.reloadData()
        }
    }
}

//MARK: - CAAnimationDelegate
extension SAMShoppingCarController: CAAnimationDelegate {
    
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        let layer = addProductAnimLayers[0]
        
        if anim == layer.animationForKey("group") {
            
            //移除动画
            layer.removeAllAnimations()
            
            //移除动画图层
            layer.removeFromSuperlayer()
            
            addProductAnimLayers.removeAtIndex(0)
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
