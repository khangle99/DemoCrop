//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import UIKit

public protocol CropViewControllerDelegate: AnyObject {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController,
                                   cropped: UIImage,
                                   transformation: Transformation,
                                   cropInfo: CropInfo)
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage)
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage)
}

public extension CropViewControllerDelegate where Self: UIViewController {
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
}

public class CropViewController: UIViewController {
    /// When a CropViewController is used in a storyboard,
    /// passing an image to it is needed after the CropViewController is created.
    public var image: UIImage! {
        didSet {
            cropView.image = image
        }
    }
    
    public weak var delegate: CropViewControllerDelegate?
    public var config = Config()
    
    private var orientation: UIDeviceOrientation?
    private lazy var cropView = CropView(image: image, viewModel: CropViewModel())
    private var cropToolbar: CropToolbarProtocol
    private var ratioSelector: RatioSelector!
    private var stackView: UIStackView?
    private var cropStackView: UIStackView!
    private var initialLayout = false
    private var disableRotation = false
    
    deinit {
        print("CropViewController deinit.")
    }
    
    init(image: UIImage,
         config: Config = Config(),
         cropToolbar: CropToolbarProtocol = CropToolbar(frame: CGRect.zero)) {
        self.image = image
        
        self.config = config
        self.cropToolbar = cropToolbar
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cropToolbar = CropToolbar(frame: CGRect.zero)
        super.init(coder: aDecoder)
    }
    
    fileprivate func createRatioSelector() {
        let fixedRatioManager = getFixedRatioManager()
        self.ratioSelector = RatioSelector(type: fixedRatioManager.type, originalRatioH: fixedRatioManager.originalRatioH, ratios: fixedRatioManager.ratios)
        self.ratioSelector.didGetRatio = { [weak self] ratio in
            self?.setFixedRatio(ratio)
        }
    }
    
    fileprivate func createCropToolbar() {
        cropToolbar.cropToolbarDelegate = self
        
        config.cropToolbarConfig.includeFixedRatioSettingButton = true
        
        
        cropToolbar.createToolbarUI(config: config.cropToolbarConfig)
        
        let heightForVerticalOrientation = config.cropToolbarConfig.cropToolbarHeightForVertialOrientation
        let widthForHorizonOrientation = config.cropToolbarConfig.cropToolbarWidthForHorizontalOrientation
        cropToolbar.initConstraints(heightForVerticalOrientation: heightForVerticalOrientation,
                                    widthForHorizonOrientation: widthForHorizonOrientation)
    }
    
    private func getRatioType() -> RatioType {
        switch config.cropToolbarConfig.fixRatiosShowType {
        case .adaptive:
            return cropView.getRatioType(byImageIsOriginalisHorizontal: cropView.image.isHorizontal())
        case .horizontal:
            return .horizontal
        case .vetical:
            return .vertical
        }
    }
    
    fileprivate func getFixedRatioManager() -> FixedRatioManager {
        let type: RatioType = getRatioType()
        
        let ratio = cropView.getImageRatioH()
        
        return FixedRatioManager(type: type,
                                 originalRatioH: ratio,
                                 ratioOptions: config.ratioOptions,
                                 customRatios: config.getCustomRatioItems())
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        createCropView()
        createCropToolbar()
        createRatioSelector()
        initLayout()
        updateLayout()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if initialLayout == false {
            initialLayout = true
            view.layoutIfNeeded()
            cropView.resetUIFrame()
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.top, .bottom]
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cropView.prepareForDeviceRotation()
        rotated()
    }
    
    private func rotated() {
        let currentOrientation = UIDevice.current.orientation
        
        orientation = currentOrientation
        
        if UIDevice.current.userInterfaceIdiom == .phone
            && currentOrientation == .portraitUpsideDown {
            return
        }
        
        updateLayout()
        view.layoutIfNeeded()
        
        // When it is embedded in a container, the timing of viewDidLayoutSubviews
        // is different with the normal mode.
        // So delay the execution to make sure handleRotate runs after the final
        // viewDidLayoutSubviews
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.cropView.handleRotate()
        }
    }
    
    private func setFixedRatio(_ ratio: Double, zoom: Bool = true) {
        cropToolbar.handleFixedRatioSetted(ratio: ratio)
        cropView.aspectRatioLockEnabled = true
        
        if cropView.viewModel.aspectRatio != CGFloat(ratio) {
            cropView.viewModel.aspectRatio = CGFloat(ratio)
            
            UIView.animate(withDuration: 0.5) {
                self.cropView.setFixedRatioCropBox(zoom: zoom)
            }
            
        }
    }
    
    private func createCropView() {
        cropView.delegate = self
        cropView.clipsToBounds = true
        cropView.cropVisualEffectType = config.cropVisualEffectType
    }
    
    private func handleCancel() {
        self.delegate?.cropViewControllerDidCancel(self, original: self.image)
    }
    
    private func resetRatioButton() {
        cropView.aspectRatioLockEnabled = false
        cropToolbar.handleFixedRatioUnSetted()
    }
    
    
    private func handleReset() {
        resetRatioButton()
        cropView.reset()
        ratioSelector?.reset()
        ratioSelector?.update(fixedRatioManager: getFixedRatioManager())
    }
    
    private func handleRotate(rotateAngle: CGFloat) {
        if !disableRotation {
            disableRotation = true
            cropView.rotateBy90(rotateAngle: rotateAngle) { [weak self] in
                self?.disableRotation = false
                self?.ratioSelector?.update(fixedRatioManager: self?.getFixedRatioManager())
            }
        }
        
    }
    
    private func handleAlterCropper90Degree() {
        let ratio = Double(cropView.gridOverlayView.frame.height / cropView.gridOverlayView.frame.width)
        
        cropView.viewModel.aspectRatio = CGFloat(ratio)
        
        UIView.animate(withDuration: 0.5) {
            self.cropView.setFixedRatioCropBox()
        }
    }
    
    private func handleCrop() {
        let cropResult = cropView.crop()
        guard let image = cropResult.croppedImage else {
            delegate?.cropViewControllerDidFailToCrop(self, original: cropView.image)
            return
        }
        self.delegate?.cropViewControllerDidCrop(self,
                                                 cropped: image,
                                                 transformation: cropResult.transformation,
                                                 cropInfo: cropResult.cropInfo)
    }
}

// Auto layout
extension CropViewController {
    fileprivate func initLayout() {
        cropStackView = UIStackView()
        cropStackView.axis = .vertical
        cropStackView.addArrangedSubview(cropView)
        cropStackView.addArrangedSubview(ratioSelector)
        
        stackView = UIStackView()
        view.addSubview(stackView!)
        
        cropStackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        cropToolbar.translatesAutoresizingMaskIntoConstraints = false
        cropView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    fileprivate func setStackViewAxis() {
        if UIDevice.current.orientation == .portrait {
            stackView?.axis = .vertical
        } else {
            stackView?.axis = .horizontal
        }
    }
    
    fileprivate func changeStackViewOrder() {
        stackView?.removeArrangedSubview(cropStackView)
        stackView?.removeArrangedSubview(cropToolbar)
        
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .landscapeRight {
            stackView?.addArrangedSubview(cropStackView)
            stackView?.addArrangedSubview(cropToolbar)
        } else if UIDevice.current.orientation == .landscapeLeft {
            stackView?.addArrangedSubview(cropToolbar)
            stackView?.addArrangedSubview(cropStackView)
        }
    }
    
    fileprivate func updateLayout() {
        setStackViewAxis()
        cropToolbar.respondToOrientationChange()
        changeStackViewOrder()
    }
}

extension CropViewController: CropViewDelegate {
    
    func cropViewDidBecomeResettable(_ cropView: CropView) {
        cropToolbar.handleCropViewDidBecomeResettable()
    }
    
    func cropViewDidBecomeUnResettable(_ cropView: CropView) {
        cropToolbar.handleCropViewDidBecomeUnResettable()
    }
}

extension CropViewController: CropToolbarDelegate {
    public func didSelectCancel() {
        handleCancel()
        self.dismiss(animated: true)
    }
    
    public func didSelectCrop() {
        handleCrop()
        self.dismiss(animated: true)
    }
    
    public func didSelectCounterClockwiseRotate() {
        handleRotate(rotateAngle: -CGFloat.pi / 2)
    }
    
    public func didSelectClockwiseRotate() {
        handleRotate(rotateAngle: CGFloat.pi / 2)
    }
    
    public func didSelectReset() {
        handleReset()
    }
    
    public func didSelectAlterCropper90Degree() {
        handleAlterCropper90Degree()
    }
}

extension CropViewController {
    public func crop() {
        let cropResult = cropView.crop()
        guard let image = cropResult.croppedImage else {
            delegate?.cropViewControllerDidFailToCrop(self, original: cropView.image)
            return
        }
        
        delegate?.cropViewControllerDidCrop(self,
                                            cropped: image,
                                            transformation: cropResult.transformation,
                                            cropInfo: cropResult.cropInfo)
    }
}

