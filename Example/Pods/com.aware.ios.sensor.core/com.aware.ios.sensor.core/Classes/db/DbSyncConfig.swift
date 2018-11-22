//
//  DbSyncConfig.swift
//  com.aware.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/10/18.
//

import UIKit
import RealmSwift

public class DbSyncConfig{
    
    public var removeAfterSync:Bool = true
    public var batchSize:Int        = 100
    public var markAsSynced:Bool    = false
    public var skipSyncedData:Bool  = false
    public var keepLastData:Bool    = false
    public var deviceId:String?     = nil
    public var debug:Bool           = false
    
    public init() {
        
    }
    
    public func apply(closure: (_ config: DbSyncConfig ) -> Void) -> Self {
        closure(self)
        return self
    }
}


