//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import UIKit

public protocol CropToolbarDelegate: AnyObject {
    func didSelectCancel()
    func didSelectCrop()
    func didSelectCounterClockwiseRotate()
    func didSelectClockwiseRotate()
    func didSelectReset()
    func didSelectAlterCropper90Degree()
    func didSelectHorizontalFlip()
    func didSelectVerticalFlip()
}

public protocol CropToolbarProtocol: UIView {
    var heightForVerticalOrientationConstraint: NSLayoutConstraint? {get set}
    var widthForHorizonOrientationConstraint: NSLayoutConstraint? {get set}
    var cropToolbarDelegate: CropToolbarDelegate? {get set}

    func createToolbarUI(config: CropToolbarConfig)
    func handleFixedRatioSetted(ratio: Double)
    func handleFixedRatioUnSetted()
    
    // MARK: - The following functions have default implementations
    func initConstraints(heightForVerticalOrientation: CGFloat,
                        widthForHorizonOrientation: CGFloat)
    
    func respondToOrientationChange()
    func adjustLayoutConstraintsWhenOrientationChange()
}

public extension CropToolbarProtocol {
    
    func initConstraints(heightForVerticalOrientation: CGFloat, widthForHorizonOrientation: CGFloat) {
        heightForVerticalOrientationConstraint = heightAnchor.constraint(equalToConstant: heightForVerticalOrientation)
        widthForHorizonOrientationConstraint = widthAnchor.constraint(equalToConstant: widthForHorizonOrientation)
    }
    
    func respondToOrientationChange() {
        adjustLayoutConstraintsWhenOrientationChange()
    }
    
    func adjustLayoutConstraintsWhenOrientationChange() {
        
        if !UIApplication.shared.isLandscape {
            heightForVerticalOrientationConstraint?.isActive = true
            widthForHorizonOrientationConstraint?.isActive = false
        } else {
            heightForVerticalOrientationConstraint?.isActive = false
            widthForHorizonOrientationConstraint?.isActive = true
        }
    }
}

