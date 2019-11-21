//
//  ResultItem.swift
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 21.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

import UIKit

struct ResultItem: Codable {
    public let currentTime: Float
    public let dotNumber: Int
    public let xPosition: Int
    public let yPosition: Int
    
    public init(time: Float, pos: PoseDot) {
        self.currentTime = time
        self.dotNumber = Int(pos.dotNumber)
        self.xPosition = Int(pos.dotPos.x)
        self.yPosition = Int(pos.dotPos.y)
    }
}

struct Results {
    public let resultName: String
    public let items: [ResultItem]
    public let startColor: Int
    public let finishColor: Int
    
    public init(resultName: String, items: [ResultItem], startColor: Int, finishColor: Int) {
        self.resultName = resultName
        self.items = items
        self.startColor = startColor
        self.finishColor = finishColor
    }
}
