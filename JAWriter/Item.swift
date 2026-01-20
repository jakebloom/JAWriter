//
//  Item.swift
//  JAWriter
//
//  Created by Jake on 19/1/26.
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
