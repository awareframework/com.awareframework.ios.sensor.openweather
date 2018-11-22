//
//  SensorObserver.swift
//  com.aware.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2018/10/18.
//

import UIKit

public protocol SensorObserver {
    func onDataChanged(type: String, data: Any?, error: Any?)
}

