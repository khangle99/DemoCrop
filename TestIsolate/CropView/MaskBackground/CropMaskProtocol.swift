//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import UIKit

fileprivate let minOverLayerUnit: CGFloat = 30
fileprivate let initialFrameLength: CGFloat = 1000

protocol CropMaskProtocol where Self: UIView {
    var innerLayer: CALayer? { get set }
    
    func initialize(cropRatio: CGFloat)
    func setMask(cropRatio: CGFloat)
    func adaptMaskTo(match cropRect: CGRect, cropRatio: CGFloat)
}

extension CropMaskProtocol {
    func initialize(cropRatio: CGFloat = 1.0) {
        setInitialFrame()
        setMask(cropRatio: cropRatio)
    }
    
    private func setInitialFrame() {
        let width = initialFrameLength
        let height = initialFrameLength
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let originX = (screenWidth - width) / 2
        let originY = (screenHeight - height) / 2
        
        self.frame = CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    func adaptMaskTo(match cropRect: CGRect, cropRatio: CGFloat) {
        let scaleX: CGFloat
        
        scaleX = cropRect.width / minOverLayerUnit
                
        let scaleY = cropRect.height / minOverLayerUnit

        transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

        self.frame.origin.x = cropRect.midX - self.frame.width / 2
        self.frame.origin.y = cropRect.midY - self.frame.height / 2
    }
    
    func createOverLayer(opacity: Float, cropRatio: CGFloat = 1.0) -> CAShapeLayer {
        let coff: CGFloat = 1
        
        let originX = bounds.midX - minOverLayerUnit * coff / 2
        let originY = bounds.midY - minOverLayerUnit / 2
        let initialRect = CGRect(x: originX, y: originY, width: minOverLayerUnit * coff, height: minOverLayerUnit)
        
        let path = UIBezierPath(rect: self.bounds)
        
        let innerPath: UIBezierPath
        
        func getInnerPath(by points: [CGPoint]) -> UIBezierPath {
            let innerPath = UIBezierPath()
            guard points.count >= 3 else {
                return innerPath
            }
            let points0 = CGPoint(x: initialRect.width * points[0].x + initialRect.origin.x, y: initialRect.height * points[0].y + initialRect.origin.y)
            innerPath.move(to: points0)
        
            for index in 1..<points.count {
                let point = CGPoint(x: initialRect.width * points[index].x + initialRect.origin.x, y: initialRect.height * points[index].y + initialRect.origin.y)
                innerPath.addLine(to: point)
            }
            
            innerPath.close()
            return innerPath
        }
                
        innerPath = UIBezierPath(rect: initialRect)
                
        path.append(innerPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = opacity
        return fillLayer
    }
}


extension CGFloat {
    func radians() -> CGFloat {
        return .pi * (self/180)
    }
}

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

func polygonPointArray(sides: Int,
                       originX: CGFloat,
                       originY: CGFloat,
                       radius: CGFloat,
                       offset: CGFloat) -> [CGPoint] {
    let angle = (360/CGFloat(sides)).radians()
    
    var index = 0
    var points = [CGPoint]()
    
    while index <= sides {
        let xpo = originX + radius * cos(angle * CGFloat(index) - offset.radians())
        let ypo = originY + radius * sin(angle * CGFloat(index) - offset.radians())
        points.append(CGPoint(x: xpo, y: ypo))
        index += 1
    }
    return points
}


