//
//  GetTorrentsOperation.swift
//  Magnet Feed
//
//  Created by Justin Oakes on 6/15/20.
//  Copyright © 2020 Oklasoft. All rights reserved.
//

import Foundation

class GetTorrentsOperation: Operation {
    
    private let source: Source
    
    init(source: Source) {
        self.source = source
        super.init()
        qualityOfService = .utility
        queuePriority = .normal
    }
    
    override func main() {
        JTOXMLParser.sharedInstance().parse(with: source)
    }
}
