//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import Foundation
import UIKit

extension FloatingPoint{
    var isBad:Bool{ return isNaN || isInfinite }
    var checked:Self{
        guard !isBad && !isInfinite else {
            fatalError("bad number!")
        }
        return self
    }
}

typealias Angle = CGFloat

extension CGRect{
    var center:CGPoint { return CGPoint(x:midX, y: midY).checked}
}

extension CGPoint{
    var checked:CGPoint{
        guard !hasNaN else {
            fatalError("bad number!")
        }
        return self
    }
    var hasNaN:Bool{return x.isBad || y.isBad }
}
