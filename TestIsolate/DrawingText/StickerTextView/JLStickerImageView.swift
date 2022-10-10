//
//  stickerView.swift
//  stickerTextView
//
//  Created by 刘业臻 on 16/4/20.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

protocol JLStickerImageViewDelegate: AnyObject {
    func didTapOutside()
    func didTapEditingLabel(_ label: JLStickerLabelView)
}

public class JLStickerImageView: UIImageView, UIGestureRecognizerDelegate {
    public var currentlyEditingLabel: JLStickerLabelView!
    fileprivate var labels: [JLStickerLabelView]!
    private var renderedView: UIView!
    weak var delegate: JLStickerImageViewDelegate?
    
    fileprivate lazy var tapOutsideGestureRecognizer: UITapGestureRecognizer! = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(JLStickerImageView.tapOutside))
        tapGesture.delegate = self
        return tapGesture
        
    }()
    
    //MARK: -
    //MARK: init
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        labels = []
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        labels = []
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        labels = []
    }
    
}

//MARK: -
//MARK: Functions
extension JLStickerImageView {
    
    public func addLabel() {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        
        let labelFrame = CGRect(x: self.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                    y: self.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                    width: 60, height: 50)
        let labelView = JLStickerLabelView(frame: labelFrame)
        labelView.allowRect = self.contentClippingRect
        labelView.setupTextLabel()
        labelView.delegate = self
        labelView.showsContentShadow = false
        labelView.borderColor = UIColor.white
//        labelView.labelTextView?.fontName = "Roboto-Medium"
        self.addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel)
        labels.append(labelView)
        
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
    public func addImage() {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        
        let labelFrame = CGRect(x: self.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                y: self.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                width: 60, height: 50)
        let labelView = JLStickerLabelView(frame: labelFrame)
        labelView.setupImageLabel()
        labelView.showsContentShadow = false
        labelView.borderColor = UIColor.white
        self.addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel)
        labels.append(labelView)
        
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
    }
    
//    public func renderContentOnView() -> UIImage? {
//
//        self.cleanup()
//        let rect = contentClippingRect
//
//        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
//        let context = UIGraphicsGetCurrentContext()!
//        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
//        self.layer.render(in: context)
//
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//
//        UIGraphicsEndImageContext()
//        return img
//    }
    
    public func renderContentOnView() -> UIImage? {
        self.cleanup()
        let rect = contentClippingRect
        guard let image = image else { return nil }
        // scaleup view len image scale
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = image.size.width / bounds.width
        } else {
            scale = image.size.height / bounds.height
        }
        // scale up rect
        let realRect = rect.applying(.init(scaleX: scale, y: scale))
        
        UIGraphicsBeginImageContextWithOptions(realRect.size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: -realRect.origin.x, y: -realRect.origin.y)
        context.scaleBy(x: scale, y: scale)
        self.layer.render(in: context)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return img
    }
    
    public func limitImageViewToSuperView() {
        if self.superview == nil {
            return
        }
        guard let imageSize = self.image?.size else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = true
        let aspectRatio = imageSize.width / imageSize.height
        
        if imageSize.width > imageSize.height {
            self.bounds.size.width = self.superview!.bounds.size.width
            self.bounds.size.height = self.superview!.bounds.size.width / aspectRatio
        }else {
            self.bounds.size.height = self.superview!.bounds.size.height
            self.bounds.size.width = self.superview!.bounds.size.height * aspectRatio
        }
    }
    
    // MARK: -
    
    func cleanup() {
        for label in labels {
            if let isEmpty = label.labelTextView?.text.isEmpty, isEmpty {
                label.closeTap(nil)
            } else {
                label.hideEditingHandlers()
            }
        }
    }
}

//MARK-
//MARK: Gesture
extension JLStickerImageView {
    @objc func tapOutside() {
        if let labelView: JLStickerLabelView = currentlyEditingLabel {
            currentlyEditingLabel.hideEditingHandlers()
            if let textView = labelView.labelTextView, textView.text.isEmpty {
                labelView.removeFromSuperview()
            }
           
        }
        labels.forEach { label in
            label.hideEditingHandlers()
        }
        delegate?.didTapOutside()
        
    }
}

//MARK-
//MARK: stickerViewDelegate
extension JLStickerImageView: JLStickerLabelViewDelegate {
    public func labelViewDidBeginEditing(_ label: JLStickerLabelView) {
        //labels.removeObject(label)
    }
    
    public func labelViewDidClose(_ label: JLStickerLabelView) {
    }
    
    public func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
    }
    
    public func labelViewDidHideEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = nil
    }
    
    public func labelViewDidStartEditing(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
    }
    
    public func labelViewDidChangeEditing(_ label: JLStickerLabelView) {
    }
    
    public func labelViewDidEndEditing(_ label: JLStickerLabelView) {
        
    }
    
    public func labelViewDidSelected(_ label: JLStickerLabelView) {
        for labelItem in labels {
            if labelItem !== label {
                labelItem.hideEditingHandlers()
            }
            
        }
        //label.showEditingHandles()
        delegate?.didTapEditingLabel(label)
    }
    
}

//MARK: -
//MARK: Set propeties

extension JLStickerImageView: AdjustFontSizeToFillRectProtocol {
    
    public enum textShadowPropterties {
        case offSet(CGSize)
        case color(UIColor)
        case blurRadius(CGFloat)
    }
    
    public var fontName: String! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.fontName = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.fontName
        }
    }
    
    public var textColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.foregroundColor = newValue
            }
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.foregroundColor
        }
    }
    
    public var textAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.textAlpha
        }
    }
    
    //MARK: -
    //MARK: text Format
    
    public var textAlignment: NSTextAlignment! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.alignment = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.alignment
        }
    }
    
    public var lineSpacing: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.lineSpacing = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.lineSpacing
            
        }
    }
    
    //MARK: -
    //MARK: text Background
    
    public var textBackgroundColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textBackgroundColor = newValue
            }
            
        }
        
        get {
            return self.currentlyEditingLabel.labelTextView?.textBackgroundColor
        }
    }
    
    public var textBackgroundAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textBackgroundAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.textBackgroundAlpha
            
        }
    }
    
    //MARK: -
    //MARK: text shadow
    
    public var textShadowOffset: CGSize! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textShadowOffset = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.shadow?.shadowOffset
        }
    }
    
    public var textShadowColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textShadowColor = newValue
            }
            
        }
        get {
            return (self.currentlyEditingLabel.labelTextView?.shadow?.shadowColor) as? UIColor
        }
    }
    
    public var textShadowBlur: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView?.textShadowBlur = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView?.shadow?.shadowBlurRadius
        }
    }
}
