//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import Foundation

enum CropViewStatus {
    case initial
    case horizontalFlip
    case verticalFlip
    case degree90Rotating
    case touchImage
    case touchCropboxHandle(tappedEdge: CropViewOverlayEdge = .none)
    case betweenOperation
}

