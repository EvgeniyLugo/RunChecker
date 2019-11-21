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
