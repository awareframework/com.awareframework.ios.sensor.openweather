//
//  AwareUtils.swift
//  CoreAware
//
//  Created by Yuuki Nishiyama on 2018/03/04.
//

import Foundation


public class AwareUtils{

    private static let kDeviceIdKey:String = "com.aware.ios.sensor.core.key.deviceid"
    
    public static func getTimeZone() -> Int {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        return secondsFromGMT/60/60 // convert a secounds -> hours
    }
    
    public static func getCommonDeviceId() -> String {
        if let deviceId = UserDefaults.standard.string(forKey: kDeviceIdKey) {
            return deviceId
        }else{
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            if let did = deviceId {
                UserDefaults.standard.set(did, forKey: kDeviceIdKey)
                return did
            }else{
                let uuid = UUID.init().uuidString
                UserDefaults.standard.set(uuid, forKey: kDeviceIdKey)
                return uuid
            }
        }
    }
    
//    public static func isWifi(){
//        if let reachability = Reachability() {
//            print(reachability.connection == .wifi)
//            print(reachability.connection == .cellular)
//            print(reachability.connection == .none)
//        }
//    }
}


