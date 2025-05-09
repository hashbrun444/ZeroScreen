//
//  Item.swift
//  ZeroScreen
//
//  Created by Cristian Matache on 12/16/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
