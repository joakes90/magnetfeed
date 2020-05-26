//
//  NetworkService.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 5/26/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Cocoa

class NetworkService {
    
    typealias XMLDataCompletion = (Data?, URLResponse?, Error?) -> Void
    
    static func getXMLData(source: URL, with completion: @escaping XMLDataCompletion) {
        let task = URLSession.shared.dataTask(with: source, completionHandler: completion)
        task.resume()
    }
}
