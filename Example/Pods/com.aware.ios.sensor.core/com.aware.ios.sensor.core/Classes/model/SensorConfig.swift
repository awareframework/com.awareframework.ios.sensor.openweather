//
//  AwareSensorConfig.swift
//  CoreAware
//
//  Created by Yuuki Nishiyama on 2018/03/02.
//

import Foundation
import RealmSwift

open class SensorConfig{
    public init(){}
    public var enabled:Bool    = false
    public var debug:Bool      = false
    public var label:String    = ""
    public var deviceId:String = ""
    public var dbEncryptionKey:String? = nil
    public var dbType = DatabaseType.NONE
    public var dbPath:String   = "aware"
    public var dbHost:String?  = nil
    public var realmObjectType:Object.Type? = nil
}
