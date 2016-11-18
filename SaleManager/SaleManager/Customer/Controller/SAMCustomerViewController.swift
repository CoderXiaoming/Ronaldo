//
//  SAMCustomerViewController.swift
//  SaleManager
//
//  Created by apple on 16/11/9.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import MJExtension
import MJRefresh

///CustomerCell重用标识符
private let SAMCustomerCellReuseIdentifier = "SAMCustomerCellReuseIdentifier"
///cell正常背景色
private let CellNormalColor = UIColor.clearColor()
///cell正常size
private let CellNormalSize = CGSize(width: ScreenW, height: 86)
///cell选中背景色
private let CellSelectedColor = mainColor_green
///cell选中size
private let CellSelectedSize = CGSize(width: ScreenW, height: 172)

class SAMCustomerViewController: UIViewController {
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //初始化UI
        setupUI()
        
        //初始化collectionView
        setupCollectionView()
    }

    //MARK: - 初始化UI
    private func setupUI() {
        //设置导航标题
        navigationItem.title = "客服管理"
        
        //检查查询权限
        if !hasCXAuth {
            view.addSubview(CXAuthView)
            return
        }
        
        //检查新增权限
        if hasXZAuth {
            let addBtn = UIButton(type: .Custom)
            addBtn.setBackgroundImage(UIImage(named: "addButtton"), forState: .Normal)
            addBtn.addTarget(self, action: #selector(SAMCustomerViewController.addCustomer), forControlEvents: .TouchUpInside)
            addBtn.sizeToFit()
            
            let addItem = UIBarButtonItem(customView: addBtn)
            navigationItem.rightBarButtonItem = addItem
        }
        
        //设置按钮外观
        searchBtn.layer.borderWidth = 1
        searchBtn.layer.cornerRadius = 5
        searchBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        //设置searchTF的放大镜
        let imageView = UIImageView(image: UIImage(named: "search_mirro"))
        searchTF.leftView = imageView
        searchTF.leftViewMode = UITextFieldViewMode.Always
        searchTF.delegate = self
        
        //设置searchView顶部距离
        searchViewTopDis.constant = navigationController!.navigationBar.frame.maxY
        //设置底部间距
        collectionViewBottomDis.constant = tabBarController!.tabBar.bounds.height
        
        //设置HUDView
        HUDView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SAMCustomerViewController.endSearchTFEditing)))
    }
    
    //MARK: - 初始化collectionView
    private func setupCollectionView() {
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.registerNib(UINib(nibName: "SAMCustomerCollectionCell", bundle: nil), forCellWithReuseIdentifier: SAMCustomerCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadNewInfo))
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadMoreInfo))
        //没有数据自动隐藏footer
        collectionView.mj_footer.automaticallyHidden = true
    }
    
    //MARK: - 搜索按钮点击
    @IBAction func searchBtnClick(sender: AnyObject) {
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
        
        //启动下拉刷新
        collectionView.mj_header.beginRefreshing()
    }
    
    //MARK: - 添加客户按钮点击
    func addCustomer() {
        navigationController!.presentViewController(customerAddVC, animated: true, completion: nil)
    }
    
    //MARK: - 加载新数据
    func loadNewInfo(){
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //判断搜索条件
        let searchStr = searchCon()
        if searchStr == nil {
            SAMHUD.showMessage("请输入客户", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //创建请求参数
        pageIndex = 1
        let id = SAMUserAuth.shareUser()?.employeeID
        let index = String(format: "%d", pageIndex)
        let size = String(format: "%d", pageSize)
        let patametersNew = ["employeeID": id!, "con": searchStr!, "pageSize": size, "pageIndex": index]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(URLStr, parameters: patametersNew, progress: nil, success: { (Task, Json) in
            
            //清空原先数据
            self.customerModels.removeAllObjects()
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                SAMHUD.showMessage("没有该客户", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMCustomerModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                if arr.count < self.pageSize { //设置footer状态
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex
                    self.pageIndex += 1
                }
                self.parameters = patametersNew
                self.customerModels.addObjectsFromArray(arr as [AnyObject])
            }
            
            //结束上拉
            self.collectionView.mj_header.endRefreshing()
            
            //刷新数据
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
            
            }) { (Task, Error) in
                //处理上拉
                self.collectionView.mj_header.endRefreshing()
                SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 获取搜索字符串
    func searchCon() -> String? {
        let searchStr = searchTF.text?.stringByTrimmingWhitespace()
        print(searchStr)
        if searchStr == "" { //没有内容
            return nil
        }
        return searchStr?.componentsSeparatedByString(" ")[0]
    }
    
    //MARK: - 加载更多数据
    func loadMoreInfo() {
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //创建请求参数
        let index = String(format: "%d", pageIndex)
        parameters!["pageIndex"] = index
        //发送请求
        SAMNetWorker.sharedNetWorker().GET(URLStr, parameters: parameters!, progress: nil, success: { (Task, Json) in
            
            //获取模型数组
            let dictArr = Json!["body"] as? [[String: AnyObject]]
            if dictArr?.count == 0 { //没有模型数据
                
                //提示用户
                SAMHUD.showMessage("没有更多客户", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                //设置footer
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMCustomerModel.mj_objectArrayWithKeyValuesArray(dictArr)!
                if arr.count < self.pageSize { //设置footer状态
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex
                    self.pageIndex += 1
                }
                self.customerModels.addObjectsFromArray(arr as [AnyObject])
            }
            
            //处理下拉
            self.collectionView.mj_footer.endRefreshing()
            
            //刷新数据
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
            })
            
        }) { (Task, Error) in
            //处理下拉
            self.collectionView.mj_footer.endRefreshing()
            SAMHUD.showMessage("请检查网络 😉", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 结束textField编辑状态
    private func endTextFieldEditing(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    func endSearchTFEditing() {
        endTextFieldEditing(searchTF)
    }
    //MARK: - 懒加载集合
    ///请求URLStr
    private let URLStr = "getCustomerList.ashx"
    ///一次数据请求获取的数据最大条数
    private let pageSize = 15
    ///当前数据的页码
    private var pageIndex = 1
    ///最近一次查询的参数
    private var parameters: [String: AnyObject]?
    
    ///当前选中IndexPath
    var selectedIndexPath : NSIndexPath?
    
    ///查询权限
    private lazy var hasCXAuth: Bool = SAMUserAuth.checkAuth(["KH_CX_APP"])
    ///新增权限
    private lazy var hasXZAuth: Bool = SAMUserAuth.checkAuth(["KH_XZ_APP"])
    ///修改权限
    private lazy var hasXGAuth: Bool = SAMUserAuth.checkAuth(["KH_XG_APP"])
    ///禁用权限
    private lazy var hasJYAuth: Bool = SAMUserAuth.checkAuth(["KH_JY_APP"])
    
    ///查询权限遮挡View
    private lazy var CXAuthView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        let imageView = UIImageView(image: UIImage(named: "cxAuthImage"))
        view.addSubview(imageView)
        imageView.center = CGPoint(x: ScreenW * 0.5, y: ScreenH * 0.5)
        return view
    }()
    
    ///添加用户的控制器
    private lazy var customerAddVC: SAMCustomerAddController = {
        let vc = SAMCustomerAddController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.Custom
        return vc
    }()
    
    ///模型数组
    var customerModels = NSMutableArray()
    
    //MARK: - xib链接控件
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: SAMLoginTextField!
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var searchViewTopDis: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomDis: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var HUDView: UIView!
    
    //MARK: - 其他方法
    override func loadView() {
        view = NSBundle.mainBundle().loadNibNamed("SAMCustomerViewController", owner: self, options: nil)![0] as! UIView
    }
}

extension SAMCustomerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - DataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customerModels.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SAMCustomerCellReuseIdentifier, forIndexPath: indexPath) as! SAMCustomerCollectionCell
        //设置样式
        if indexPath == selectedIndexPath {
            cell.contentView.backgroundColor = CellSelectedColor
        } else {
            cell.contentView.backgroundColor = CellNormalColor
        }
        //传递数据模型
        let model = customerModels[indexPath.row] as! SAMCustomerModel
        cell.customerModel = model
        
        return cell;
    }
    
    //MARK: - Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        var selectedCell: UICollectionViewCell?
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            selectedIndexPath = nil
            selectCellAnimation(nil, willNorCell: cell!)
        } else { //选中了其他的CELL
            
            if selectedIndexPath != nil { //没有选中其他CELL
                selectedCell = collectionView.cellForItemAtIndexPath(selectedIndexPath!)
            }
            selectedIndexPath = indexPath
            cell?.contentView.backgroundColor = CellSelectedColor
            //执行动画
            selectCellAnimation(cell!, willNorCell: selectedCell)
        }
    }
    
    //MARK: - 点击了某个cell时执行的动画
    func selectCellAnimation(willSelCell: UICollectionViewCell?, willNorCell: UICollectionViewCell?) {
        UIView.animateWithDuration(0.3) {
            self.collectionView.performBatchUpdates({
            }) { (finished) in
            }
            willSelCell?.contentView.backgroundColor = CellSelectedColor
            willNorCell?.contentView.backgroundColor = CellNormalColor
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - FlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath == selectedIndexPath {
            return CellSelectedSize
        }
        return CellNormalSize
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
    }
}

extension SAMCustomerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        HUDView.hidden = false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        HUDView.hidden = true
        return true
    }
}

extension SAMCustomerViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}

