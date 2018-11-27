//
//  DbSyncConfig.swift
//  com.aware.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/10/18.
//

import UIKit
import RealmSwift

public class DbSyncConfig {
    
    public var removeAfterSync:Bool = true
    public var batchSize:Int        = 100
    public var markAsSynced:Bool    = false
    public var skipSyncedData:Bool  = false
    public var keepLastData:Bool    = false
    public var deviceId:String?     = nil
    public var debug:Bool           = false
    
    public init() {
        
    }
    
    public init(_ config:Dictionary<String, Any>){
        set(config: config)
    }
    
    public func set(config: Dictionary<String, Any>){
        if let removeAfterSync = config["removeAfterSync"] as? Bool{
            self.removeAfterSync = removeAfterSync
        }
        
        if let batchSize = config["batchSize"] as? Int {
            self.batchSize = batchSize
        }
        
        if let markAsSynced = config["markAsSynced"] as? Bool {
            self.markAsSynced = markAsSynced
        }
        
        if let skipSyncedData = config["skipSyncedData"] as? Bool {
            self.skipSyncedData = skipSyncedData
        }
        
        self.deviceId = config["deviceId"] as? String
        
        if let debug = config["debug"] as? Bool {
            self.debug = debug
        }
    }
    
    public func apply(closure: (_ config: DbSyncConfig ) -> Void) -> Self {
        closure(self)
        return self
    }
}


