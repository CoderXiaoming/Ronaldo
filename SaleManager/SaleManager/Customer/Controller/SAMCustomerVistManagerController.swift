//
//  SAMCustomerVistManagerController.swift
//  SaleManager
//
//  Created by apple on 17/2/9.
//  Copyright © 2017年 YZH. All rights reserved.
//

import UIKit
import MJRefresh

///回访Cell重用标识符
private let SAMCustomerVistSearchCellReuseIdentifier = "SAMCustomerVistSearchCellReuseIdentifier"

class SAMCustomerVistManagerController: UIViewController {
    
    //MARK: - 对外提供的类方法
    class func instance(customerModel: SAMCustomerModel) -> SAMCustomerVistManagerController {
        let vc = SAMCustomerVistManagerController()
        vc.customerModel = customerModel
        return vc
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
        navigationItem.title = customerModel!.CGUnitName
        
        //设置搜索框
        searchBar.showsCancelButton = false
        searchBar.placeholder = "回访内容/回访时间"
        searchBar.delegate = self
    }
    
    //MARK: - 初始化tableView
    fileprivate func setupTableView() {
        
        //设置代理数据源
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //注册cell
        tableView.register(UINib(nibName: "SAMCustomerVistSearchCell", bundle: nil), forCellReuseIdentifier: SAMCustomerVistSearchCellReuseIdentifier)
        
        //设置下拉
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(SAMCustomerVistManagerController.loadNewInfo))
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
        let parameters = ["CGUnitID": customerModel!.id]
        
        //发送请求
        SAMNetWorker.sharedNetWorker().get("getOneCGUnitFollow.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
            //清空原先数据
            self!.listModels.removeAllObjects()
            
            //获取模型数组
            let Json = json as! [String: AnyObject]
            let dictArr = Json["body"] as? [[String: AnyObject]]
            let count = dictArr?.count ?? 0
            if count == 0 { //没有模型数据
                //提示用户
                let _ = SAMHUD.showMessage("暂无数据", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                
            }else { //有数据模型
                let arr = SAMCustomerVistModel.mj_objectArray(withKeyValuesArray: dictArr)!
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
    
    //MARK: - 属性
    ///接收的客户模型数据
    fileprivate var customerModel: SAMCustomerModel?
    ///源模型数组
    fileprivate let listModels = NSMutableArray()
    ///符合搜索结果模型数组
    fileprivate let searchResultModels = NSMutableArray()
    
    ///记录当前是否在搜索
    fileprivate var isSearch: Bool = false
    
    //MARK: - XIB链接属性
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - 其他方法
    fileprivate init() {
        super.init(nibName: nil, bundle: nil)
    }
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override func loadView() {
        view = Bundle.main.loadNibNamed("SAMCustomerVistManagerController", owner: self, options: nil)![0] as! UIView
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 搜索框代理UISearchBarDelegate
extension SAMCustomerVistManagerController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
                
                //strContent搜索谓语
                var lhs = NSExpression(forKeyPath: "strContent")
                let rhs = NSExpression(forConstantValue: searchString)
                let firstPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type:
                    .contains, options: .caseInsensitive)
                
                //startDate搜索谓语
                lhs = NSExpression(forKeyPath: "startDate")
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
            
            //刷新数据
            self.tableView.reloadData()
        })
    }
    
    //MARK: - 点击键盘搜索按钮调用
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }
}

//MARK: - tableView数据源方法 UITableViewDataSource
extension SAMCustomerVistManagerController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        return sourceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //获取重用Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: SAMCustomerVistSearchCellReuseIdentifier) as! SAMCustomerVistSearchCell
        
        //根据是否是搜索状态返回不同的数据
        let sourceArr = isSearch ? searchResultModels : listModels
        cell.vistModel = sourceArr[indexPath.row] as? SAMCustomerVistModel
        
        return cell
    }
}

//MARK: - tableView代理 UITableViewDelegate
extension SAMCustomerVistManagerController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //取出cell
        let cell = tableView.cellForRow(at: indexPath) as! SAMCustomerVistSearchCell
        
        //取出对应模型
        let model = cell.vistModel!
        
        /*******************  删除按钮  ********************/
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            
            /// alertVC
            let alertVC = UIAlertController(title: "确定删除？", message: model.strContent!, preferredStyle: .alert)
            
            /// cancelAction
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            })
            
            /// deleteAction
            let deleteAction = UIAlertAction(title: "确定", style: .destructive, handler: { (action) in
                
                
                //设置加载hud
                let hud = SAMHUD.showAdded(to: KeyWindow!, animated: true)
                hud!.labelText = NSLocalizedString("", comment: "HUD loading title")
                
                //创建请求参数
                let parameters = ["id": model.id!]
                
                //发送请求
                SAMNetWorker.sharedNetWorker().get("CGUnitFollowDelete.ashx", parameters: parameters, progress: nil, success: {[weak self] (Task, json) in
                    
                    
                    //获取删除结果
                    let Json = json as! [String: AnyObject]
                    let dict = Json["head"] as! [String: String]
                    let status = dict["status"]
                    
                    //回到主线程
                    DispatchQueue.main.async(execute: {
                        
                        //隐藏hud
                        hud?.hide(true)
                        
                        if status == "success" { //删除成功
                            //提示用户
                            let _ = SAMHUD.showMessage("删除成功", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                            
                            //刷新数据
                            self?.tableView.mj_header.beginRefreshing()
                            
                        }else { //删除失败
                            //提示用户
                            let _ = SAMHUD.showMessage("删除失败", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                        }
                    })
                }) { (Task, Error) in
                    //隐藏hud
                    hud?.hide(true)
                    
                    //提示用户
                    let _ = SAMHUD.showMessage("请检查网络", superView: KeyWindow!, hideDelay: SAMHUDNormalDuration, animated: true)
                }
            })
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(deleteAction)
            
            self.present(alertVC, animated: true, completion: {
            })
        }
        
        //操作数组
        return[deleteAction]
    }
}

