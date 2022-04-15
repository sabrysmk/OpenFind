//
//  Photo.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct Photo: Hashable {
    var asset: PHAsset
    var metadata: PhotoMetadata?

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.asset)
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }
    
    func isStarred() -> Bool  {
        metadata.map { $0.isStarred } ?? false
    }
    
    func isScreenshot() -> Bool {
        asset.mediaSubtypes.contains(.photoScreenshot)
    }
}

struct PhotoMetadata {
    var assetIdentifier = ""
    var dateScanned: Date?
    var sentences = [Sentence]()
    var scannedInLanguages = [String]()
    var isStarred = false
    var isIgnored = false
}

