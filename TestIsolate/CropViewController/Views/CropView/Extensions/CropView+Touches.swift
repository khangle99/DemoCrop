//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import Foundation
import UIKit

extension CropView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let newPoint = self.convert(point, to: self)
        
        if (gridOverlayView.frame.insetBy(dx: -hotAreaUnit/2, dy: -hotAreaUnit/2).contains(newPoint) &&
            !gridOverlayView.frame.insetBy(dx: hotAreaUnit/2, dy: hotAreaUnit/2).contains(newPoint))
        {
            return self
        }
        
        if self.bounds.contains(newPoint) {
            return self.scrollView
        }
        
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1, let touch = touches.first else {
            return
        }
        
        // A resize event has begun by grabbing the crop UI, so notify delegate
        
        let point = touch.location(in: self)
        viewModel.prepareForCrop(byTouchPoint: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard touches.count == 1, let touch = touches.first else {
            return
        }
        
        let point = touch.location(in: self)
        updateCropBoxFrame(with: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if viewModel.needCrop() {
            gridOverlayView.handleEdgeUntouched()
            let contentRect = getContentBounds()
            adjustUIForNewCrop(contentRect: contentRect) {[weak self] in
                self?.viewModel.setBetweenOperationStatus()
                self?.scrollView.updateMinZoomScale()
            }
        } else {
            viewModel.setBetweenOperationStatus()
        }
    }
}


