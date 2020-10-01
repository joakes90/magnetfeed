//
//  UserDefaultService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 10/1/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Foundation

@objc class UserDefaultService: NSObject {
    
    @objc class func setValue(_ value: Any?, for defaultKey: UserDefaultKey) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(value, forKey: defaultKey.stringValue)
        userDefaults.synchronize()
    }
    
    @objc class func getValue(for key: UserDefaultKey) -> Any? {
        let userDefaults = UserDefaults.standard
        return userDefaults.value(forKey: key.stringValue)
    }
}

@objc enum UserDefaultKey: Int {
    case refreshInterval
    
    var stringValue: String {
        get {
            switch self {
            case .refreshInterval:
                return "refreshInterval"
            }
        }
    }
}
