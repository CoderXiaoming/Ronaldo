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
private let SAMCustomerCellNormalColor = UIColor.white
///cell正常size
private let SAMCustomerCellNormalSize = CGSize(width: ScreenW, height: 91)
///cell选中背景色
private let SAMCustomerCellSelectedColor = mainColor_green
///cell选中size
private let SAMCustomerCellSelectedSize = CGSize(width: ScreenW, height: 160)

class SAMCustomerViewController: UIViewController {
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化UI
        setupUI()
    }

    //MARK: - 初始化UI
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.white
        
        //设置导航标题
        navigationItem.title = "客户管理"
        
        //检查查询权限
        if !hasCXAuth {
            view.addSubview(CXAuthView)
            return
        }
        
        //检查新增权限
        if hasXZAuth {
            let addBtn = UIButton(type: .custom)
            addBtn.setBackgroundImage(UIImage(named: "addButtton"), for: UIControlState())
            addBtn.addTarget(self, action: #selector(SAMCustomerViewController.addCustomer), for: .touchUpInside)
            addBtn.sizeToFit()
            
            let addItem = UIBarButtonItem(customView: addBtn)
            navigationItem.rightBarButtonItem = addItem
        }
        
        //设置搜索按钮外观
        searchBtn.layer.borderWidth = 1
        searchBtn.layer.cornerRadius = 5
        searchBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        //设置searchTF的放大镜
        let imageView = UIImageView(image: UIImage(named: "search_mirro"))
        searchTF.leftView = imageView
        searchTF.leftViewMode = UITextFieldViewMode.always
        
        //设置searchTF的代理
        searchTF.delegate = self
        
        //设置HUDView
        HUDView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SAMCustomerViewController.endSearchTFEditing)))
        
        //初始化collectionView
        setupCollectionView()
    }
    
    //MARK: - 初始化collectionView
    fileprivate func setupCollectionView() {
        
        //设置代理数据源
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //注册cell
        collectionView.register(UINib(nibName: "SAMCustomerCollectionCell", bundle: nil), forCellWithReuseIdentifier: SAMCustomerCellReuseIdentifier)
        
        //设置上拉下拉
        collectionView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadNewInfo))
        collectionView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(SAMCustomerViewController.loadMoreInfo))
        //没有数据自动隐藏footer
        collectionView.mj_footer.isAutomaticallyHidden = true
    }
    
    //MARK: - 搜索按钮点击
    @IBAction func searchBtnClick(_ sender: AnyObject) {
        
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
        
        //启动下拉刷新
        collectionView.mj_header.beginRefreshing()
    }
    
    //MARK: - 添加客户按钮点击
    func addCustomer() {
        present(customerAddVC, animated: true, completion: nil)
    }
    
    //MARK: - 加载新数据
    func loadNewInfo(){
        
        //结束下拉刷新
        collectionView.mj_footer.endRefreshing()
        
        //判断搜索条件，如果没有搜索条件，提示用户并返回
        let searchStr = searchCon()
        if searchStr == nil {
            let _ = SAMHUD.showMessage("请输入客户", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            collectionView.mj_header.endRefreshing()
            return
        }
        
        //恢复形变CELL
        if self.selectedCell != nil {
            self.selectedCell?.rightSwipeCell()
        }
        
        //创建请求参数
        pageIndex = 1
        let id = SAMUserAuth.shareUser()?.employeeID
        let index = String(format: "%d", pageIndex)
        let size = String(format: "%d", pageSize)
        let patametersNew = ["employeeID": id!, "con": searchStr!, "pageSize": size, "pageIndex": index]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get(URLStr, parameters: patametersNew, progress: nil, success: { (Task, json) in
            
            //清空原先数据
            self.customerModels.removeAllObjects()
            self.selectedIndexPath = nil
            self.selectedCell = nil
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                
                let _ = SAMHUD.showMessage("没有该客户", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
            }else { //有数据模型
                
                let arr = SAMCustomerModel.mj_objectArray(withKeyValuesArray: dictArr)!
                if arr.count < self.pageSize { //设置footer状态，提示用户没有更多信息
                    
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else { //设置pageIndex，可能还有更多信息
                    
                    self.pageIndex += 1
                }
                self.parameters = patametersNew as [String : AnyObject]?
                self.customerModels.addObjects(from: arr as [AnyObject])
            }
            
            //结束上拉
            self.collectionView.mj_header.endRefreshing()
            
            //刷新数据
            DispatchQueue.main.async(execute: {
                self.collectionView.reloadData()
            })
            
            }) { (Task, Error) in
                //处理上拉
                self.collectionView.mj_header.endRefreshing()
                let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 获取搜索字符串
    func searchCon() -> String? {
        let searchStr = searchTF.text?.lxm_stringByTrimmingWhitespace()
        if searchStr == "" { //没有内容
            return nil
        }
        return searchStr?.components(separatedBy: " ")[0]
    }
    
    //MARK: - 加载更多数据
    func loadMoreInfo() {
        //结束下拉刷新
        collectionView.mj_header.endRefreshing()
        
        //恢复形变CELL
        if self.selectedCell != nil {
            self.selectedCell?.rightSwipeCell()
        }
        
        //创建请求参数
        let index = String(format: "%d", pageIndex)
        parameters!["pageIndex"] = index as AnyObject?
        //发送请求
        SAMNetWorker.sharedNetWorker().get(URLStr, parameters: parameters!, progress: nil, success: { (Task, json) in
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            if dictArr?.count == 0 { //没有模型数据
                
                //提示用户
                let _ = SAMHUD.showMessage("没有更多客户", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
                //设置footer
                self.collectionView.mj_footer.endRefreshingWithNoMoreData()
            }else {//有数据模型
                
                let arr = SAMCustomerModel.mj_objectArray(withKeyValuesArray: dictArr)!
                
                if arr.count < self.pageSize {
                    
                    //设置footer状态
                    self.collectionView.mj_footer.endRefreshingWithNoMoreData()
                }else {
                    
                    //设置pageIndex
                    self.pageIndex += 1
                    
                    //处理下拉
                    self.collectionView.mj_footer.endRefreshing()
                }
                self.customerModels.addObjects(from: arr as [AnyObject])
                
                //刷新数据
                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                })
            }
        }) { (Task, Error) in
            //处理下拉
            self.collectionView.mj_footer.endRefreshing()
            let _ = SAMHUD.showMessage("请检查网络", superView: self.view, hideDelay: SAMHUDNormalDuration, animated: true)
        }
    }
    
    //MARK: - 结束textField编辑状态
    fileprivate func endTextFieldEditing(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    func endSearchTFEditing() {
        endTextFieldEditing(searchTF)
    }
    //MARK: - 懒加载集合
    ///请求URLStr
    fileprivate let URLStr = "getCustomerList.ashx"
    ///一次数据请求获取的数据最大条数
    fileprivate let pageSize = 15
    ///当前数据的页码
    fileprivate var pageIndex = 1
    ///最近一次查询的参数
    fileprivate var parameters: [String: AnyObject]?
    
    ///当前选中IndexPath
    fileprivate var selectedIndexPath : IndexPath?
    fileprivate var selectedCell: SAMCustomerCollectionCell?
    
    ///查询权限
    fileprivate lazy var hasCXAuth: Bool = SAMUserAuth.checkAuth(["KH_CX_APP"])
    ///新增权限
    fileprivate lazy var hasXZAuth: Bool = SAMUserAuth.checkAuth(["KH_XZ_APP"])
    ///修改权限
    fileprivate lazy var hasXGAuth: Bool = SAMUserAuth.checkAuth(["KH_XG_APP"])
    ///禁用权限
    fileprivate lazy var hasJYAuth: Bool = SAMUserAuth.checkAuth(["KH_JY_APP"])
    
    ///查询权限遮挡View
    fileprivate lazy var CXAuthView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        let imageView = UIImageView(image: UIImage(named: "cxAuthImage"))
        view.addSubview(imageView)
        imageView.center = CGPoint(x: ScreenW * 0.5, y: ScreenH * 0.5)
        return view
    }()
    
    ///添加用户的控制器
    fileprivate lazy var customerAddVC: SAMCustomerAddController = {
        let vc = SAMCustomerAddController()
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.custom
        return vc
    }()
    
    ///模型数组
    var customerModels = NSMutableArray()
    
    //MARK: - xib链接控件
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: SAMLoginTextField!
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var HUDView: UIView!
    
    //MARK: - 其他方法
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMCustomerViewController", owner: self, options: nil)![0] as! UIView
    }
}

//MARK: - CollectionViewDelegate
extension SAMCustomerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customerModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SAMCustomerCellReuseIdentifier, for: indexPath) as! SAMCustomerCollectionCell
        //设置样式
        if indexPath == selectedIndexPath {
            cell.containterView.backgroundColor = SAMCustomerCellSelectedColor
        } else {
            cell.containterView.backgroundColor = SAMCustomerCellNormalColor
        }
        
        //传递数据模型
        let model = customerModels[indexPath.row] as! SAMCustomerModel
        cell.customerModel = model
        cell.delegate = self
        
        return cell
    }
}

extension SAMCustomerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
        
        selectedCell = collectionView.cellForItem(at: indexPath) as? SAMCustomerCollectionCell
        
        if selectedIndexPath == indexPath { //选中了当前选中的CELL
            
            //清空记录
            selectedIndexPath = nil
            
            //执行动画
            selectCellAnimation(nil, willNorCell: selectedCell)
            
            //清空记录
            selectedCell = nil
        } else { //选中了其他的CELL
            
            var willNorCell: SAMCustomerCollectionCell?
            
            if selectedIndexPath != nil { //没有选中其他CELL
                willNorCell = collectionView.cellForItem(at: selectedIndexPath!) as? SAMCustomerCollectionCell
            }
            
            //记录数据
            selectedIndexPath = indexPath
            
            //执行动画
            selectCellAnimation(selectedCell, willNorCell: willNorCell)
        }
        
        let cell = collectionView.cellForItem(at: indexPath)!
        let bottom = cell.frame.maxY
        print(bottom)
        
    }
    
    //MARK: - 点击了某个cell时执行的动画
    fileprivate func selectCellAnimation(_ willSelCell: SAMCustomerCollectionCell?, willNorCell: SAMCustomerCollectionCell?) {
        
        UIView.animate(withDuration: 0.2, animations: { 
                //让系统调用DelegateFlowLayout 的 sizeForItemAtIndexPath的方法
                self.collectionView.performBatchUpdates({
                }) { (finished) in
                }
                
                //设置背景颜色
                willSelCell?.containterView.backgroundColor = SAMCustomerCellSelectedColor
                willNorCell?.containterView.backgroundColor = SAMCustomerCellNormalColor
                
                //恢复左滑形变
                willNorCell?.containterView.transform = CGAffineTransform.identity
                
                //一个神奇的方法
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                
                //如果点击了最下面一个cell，则滚至最底部
                if self.selectedIndexPath?.row == (self.customerModels.count - 1) {
                    self.collectionView.scrollToItem(at: self.selectedIndexPath!, at: .bottom, animated: true)
                }
        }) 
    }
}

extension SAMCustomerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == selectedIndexPath {
            return SAMCustomerCellSelectedSize
        }
        return SAMCustomerCellNormalSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //结束搜索框编辑状态
        endTextFieldEditing(searchTF)
    }
}

//MARK: - UITextFieldDelegate
extension SAMCustomerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //HUDView上添加了点击事件，点击时退出搜索框编辑状态
    func textFieldDidBeginEditing(_ textField: UITextField) {
        HUDView.isHidden = false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        HUDView.isHidden = true
        return true
    }
}

//MARK: - UIViewControllerTransitioningDelegate
extension SAMCustomerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMPresentingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SAMDismissingAnimator()
    }
}

//MARK: - SAMCustomerCollectionCellDelegate
extension SAMCustomerViewController: SAMCustomerCollectionCellDelegate {
    func customerCellDidClickEdit() {
        selectedCell!.rightSwipeCell()
        
        //获取选中的模型，并传递
        let customerModel = self.customerModels[selectedIndexPath!.row] as! SAMCustomerModel
        customerAddVC.editingModel = customerModel
        
        //展示控制器
        present(customerAddVC, animated: true, completion: nil)
    }
    func customerCellDidClickVisit() {
        selectedCell!.rightSwipeCell()
    }
    func customerCellDidClickPhone() {
        
        selectedCell!.rightSwipeCell()
        
        //获取选中的模型，对手机号码进行筛选
        let customerModel = self.customerModels[selectedIndexPath!.row] as! SAMCustomerModel
        let phoneStr = customerModel.mobilePhone!
        if phoneStr == "" {
            let _ = SAMHUD.showMessage("没有手机号码", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }else if !(phoneStr.lxm_stringisWholeNumber()) {
            let _ = SAMHUD.showMessage("非法电话", superView: view, hideDelay: SAMHUDNormalDuration, animated: true)
            return
        }
        
        //拨打电话
        let phoneURLStr = String(format: "tel://%@", phoneStr)
        let titleStr = String(format: "呼叫 %@", selectedCell!.customerLabel.text!)
        let messageStr = selectedCell!.phoneLabel.text!
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .destructive) { (_) in
            UIApplication.shared.openURL(URL(string: phoneURLStr)!)
            })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { (_) in
            })
        
        present(alert, animated: true, completion: nil)
    }
}

