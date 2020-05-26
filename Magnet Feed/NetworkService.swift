//
//  NetworkService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 5/26/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Cocoa

@objc class NetworkService: NSObject {
    
    typealias XMLDataCompletion = (Data?, URLResponse?, Error?) -> Void
    
    @objc static func getXMLData(source: URL, with completion: @escaping XMLDataCompletion) {
        let task = URLSession.shared.dataTask(with: source, completionHandler: completion)
        task.resume()
    }
}
