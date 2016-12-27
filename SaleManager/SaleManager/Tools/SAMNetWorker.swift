//
//  SAMNetWorker.swift
//  SaleManager
//
//  Created by apple on 16/11/13.
//  Copyright © 2016年 YZH. All rights reserved.
//

import UIKit
import AFNetworking

class SAMNetWorker: AFHTTPSessionManager {
    
    ///全局使用的netWorker单例
    fileprivate static var netWorker: SAMNetWorker?
    
    //MARK: - 对外提供全局使用的单例的类方法
    class func sharedNetWorker() -> SAMNetWorker {
        return netWorker!
    }
    
    //MARK: - 创建全局使用单例的类方法
    class func globalNetWorker(_ baseURLStr: String) -> SAMNetWorker{
        if netWorker != nil {
            return netWorker!
        }else {
            let URLStr = String(format: "http://%@", baseURLStr)
            let URL = Foundation.URL(string: URLStr)
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 5.0
            configuration.timeoutIntervalForRequest = 5.0
            netWorker = SAMNetWorker(baseURL: URL!, sessionConfiguration: configuration)
            return netWorker!
        }
    }
    
    ///登录界面用的netWorker
    fileprivate static var loginNetWorker: SAMNetWorker = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 5.0
        configuration.timeoutIntervalForRequest = 5.0
        return SAMNetWorker(sessionConfiguration: configuration)
    }()
    //MARK: - 对外提供登录netWorker单例的类方法
    class func sharedLoginNetWorker() -> SAMNetWorker {
        return loginNetWorker
        
    }
    
    ///全局使用的上传图片netWorker单例
    fileprivate static var unloadImageNetWorker: SAMNetWorker?
    
    //MARK: - 对外提供全局使用的上传图片netWorker单例的类方法
    class func sharedUnloadImageNetWorker() -> SAMNetWorker {
        return unloadImageNetWorker!
    }
    
    //MARK: - 创建全局使用上传图片netWorker单例的类方法
    class func globalUnloadImageNetWorker(_ baseURLStr: String) -> SAMNetWorker{
        if unloadImageNetWorker != nil {
            return unloadImageNetWorker!
        }else {
            let URLStr = String(format: "http://%@", baseURLStr)
            let URL = Foundation.URL(string: URLStr)
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 10.0
            configuration.timeoutIntervalForRequest = 10.0
            unloadImageNetWorker = SAMNetWorker(baseURL: URL!, sessionConfiguration: configuration)
            return unloadImageNetWorker!
        }
    }
}
