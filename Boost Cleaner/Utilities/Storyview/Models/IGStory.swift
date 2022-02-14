//
//  IGStory.swift
//
//  Created by Ranjith Kumar on 9/8/17
//  Copyright (c) DrawRect. All rights reserved.
//

import Foundation

public class IGStory: Codable {
    // Note: To retain lastPlayedSnapIndex value for each story making this type as class
    public var snapsCount: Int
    public var snaps: [IGSnap]
    public var internalIdentifier: String
    public var lastUpdated: Int
    var lastPlayedSnapIndex = 0
    var isCompletelyVisible = false
    var isCancelledAbruptly = false
    
    enum CodingKeys: String, CodingKey {
        case snapsCount = "snaps_count"
        case snaps = "snaps"
        case internalIdentifier = "id"
        case lastUpdated = "last_updated"
    }
    
    init(count: Int, snaps: [IGSnap], identifier: String, lastupdated: Int) {
        self.snapsCount = count
        self.snaps = snaps
        self.internalIdentifier = identifier
        self.lastUpdated = lastupdated
    }
    
}

extension IGStory: Equatable {
    public static func == (lhs: IGStory, rhs: IGStory) -> Bool {
        return lhs.internalIdentifier == rhs.internalIdentifier
    }
}
