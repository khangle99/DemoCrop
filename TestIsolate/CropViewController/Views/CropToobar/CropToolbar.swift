//
//  File.swift
//  
//
//  Created by 신동규 on 2022/01/26.
//

import UIKit

public class CropToolbar: UIView, CropToolbarProtocol {
    public var heightForVerticalOrientationConstraint: NSLayoutConstraint?
    public var widthForHorizonOrientationConstraint: NSLayoutConstraint?

    public weak var cropToolbarDelegate: CropToolbarDelegate?

    var cancelButton: UIButton?
    var resetButton: UIButton?
    var horizontalFLipButton: UIButton?
    var verticalFlipButton: UIButton?
    var counterClockwiseRotationButton: UIButton?
    var clockwiseRotationButton: UIButton?
    var alterCropper90DegreeButton: UIButton?
    var cropButton: UIButton?

    var config: CropToolbarConfig!

    private var optionButtonStackView: UIStackView?

    private func createOptionButton(withTitle title: String?, andAction action: Selector) -> UIButton {
        let buttonColor = UIColor.white
        let buttonFontSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ?
            config.optionButtonFontSizeForPad :
            config.optionButtonFontSize

        let buttonFont = UIFont.systemFont(ofSize: buttonFontSize)

        let button = UIButton(type: .system)
        button.tintColor = .white
        button.titleLabel?.font = buttonFont

        if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(buttonColor, for: .normal)
        }

        button.addTarget(self, action: action, for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)

        return button
    }

    private func createCancelButton() {
        cancelButton = createOptionButton(withTitle: "Cancel", andAction: #selector(cancel))
    }
    
    private func createHorizontalFlipButton() {
        horizontalFLipButton = createOptionButton(withTitle: nil, andAction: #selector(horizontalFlip))
        horizontalFLipButton?.setImage(UIImage(named: "horizontal_flip"), for: .normal)
        horizontalFLipButton?.imageView?.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            horizontalFLipButton!.widthAnchor.constraint(equalToConstant: 50),
            horizontalFLipButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createVerticalFlipButton() {
        verticalFlipButton = createOptionButton(withTitle: nil, andAction: #selector(verticalFlip))
        verticalFlipButton?.setImage(UIImage(named: "vertical_flip"), for: .normal)
        verticalFlipButton?.imageView?.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            verticalFlipButton!.widthAnchor.constraint(equalToConstant: 50),
            verticalFlipButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createCounterClockwiseRotationButton() {
        counterClockwiseRotationButton = createOptionButton(withTitle: nil, andAction: #selector(counterClockwiseRotate))
        counterClockwiseRotationButton?.setImage(UIImage(named: "rotate_left"), for: .normal)
        counterClockwiseRotationButton?.imageView?.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            counterClockwiseRotationButton!.widthAnchor.constraint(equalToConstant: 50),
            counterClockwiseRotationButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createClockwiseRotationButton() {
        clockwiseRotationButton = createOptionButton(withTitle: nil, andAction: #selector(clockwiseRotate))
        clockwiseRotationButton?.setImage(UIImage(named: "rotate_right"), for: .normal)
        clockwiseRotationButton?.imageView?.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            clockwiseRotationButton!.widthAnchor.constraint(equalToConstant: 50),
            clockwiseRotationButton!.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createAlterCropper90DegreeButton() {
        alterCropper90DegreeButton = createOptionButton(withTitle: nil, andAction: #selector(alterCropper90Degree))
        alterCropper90DegreeButton?.setImage(UIImage(named: "rotate"), for: .normal)
    }

    private func createResetButton(with image: UIImage? = nil) {
        if let image = image {
            resetButton = createOptionButton(withTitle: nil, andAction: #selector(reset))
            resetButton?.setImage(image, for: .normal)
        } else {
            let resetText = "Reset"
            resetButton = createOptionButton(withTitle: resetText, andAction: #selector(reset))
        }
    }

    private func createCropButton() {
        cropButton = createOptionButton(withTitle: "Done", andAction: #selector(crop))
    }

    private func createButtonContainer() {
        optionButtonStackView = UIStackView()
        addSubview(optionButtonStackView!)

        optionButtonStackView?.distribution = .equalSpacing
        optionButtonStackView?.isLayoutMarginsRelativeArrangement = true
    }

    private func setButtonContainerLayout() {
        optionButtonStackView?.translatesAutoresizingMaskIntoConstraints = false
        optionButtonStackView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        optionButtonStackView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        optionButtonStackView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        optionButtonStackView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    private func addButtonsToContainer(button: UIButton?) {
        if let button = button {
            optionButtonStackView?.addArrangedSubview(button)
        }
    }

    private func addButtonsToContainer(buttons: [UIButton?]) {
        buttons.forEach {
            if let button = $0 {
                optionButtonStackView?.addArrangedSubview(button)
            }
        }
    }

    public func createToolbarUI(config: CropToolbarConfig) {
        self.config = config
        backgroundColor = .black

        if #available(macCatalyst 14.0, iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .mac {
                backgroundColor = .white
            }
        }

        createButtonContainer()
        setButtonContainerLayout()

        createCancelButton()
        addButtonsToContainer(button: cancelButton)

        if config.toolbarButtonOptions.contains(.horizontalFlip) {
            createHorizontalFlipButton()
            addButtonsToContainer(button: horizontalFLipButton)
        }
        
        if config.toolbarButtonOptions.contains(.verticalFlip) {
            createVerticalFlipButton()
            addButtonsToContainer(button: verticalFlipButton)
        }
        
        if config.toolbarButtonOptions.contains(.counterclockwiseRotate) {
            createCounterClockwiseRotationButton()
            addButtonsToContainer(button: counterClockwiseRotationButton)
        }

        if config.toolbarButtonOptions.contains(.clockwiseRotate) {
            createClockwiseRotationButton()
            addButtonsToContainer(button: clockwiseRotationButton)
        }

        if config.toolbarButtonOptions.contains(.alterCropper90Degree) {
            createAlterCropper90DegreeButton()
            addButtonsToContainer(button: alterCropper90DegreeButton)
        }

        if config.toolbarButtonOptions.contains(.reset) {
            createResetButton(with: nil)
            addButtonsToContainer(button: resetButton)
            resetButton?.isHidden = true
        }

        createCropButton()
        addButtonsToContainer(button: cropButton)
    }

    public func respondToOrientationChange() {
        if !UIApplication.shared.isLandscape {
            optionButtonStackView?.axis = .horizontal
            optionButtonStackView?.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        } else {
            optionButtonStackView?.axis = .vertical
            optionButtonStackView?.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
    }

    public func handleFixedRatioSetted(ratio: Double) {
    }

    public func handleFixedRatioUnSetted() {
    }


    public func initConstraints(heightForVerticalOrientation: CGFloat, widthForHorizonOrientation: CGFloat) {

    }

    @objc private func cancel() {
        cropToolbarDelegate?.didSelectCancel()
    }

    @objc private func reset(_ sender: Any) {
        cropToolbarDelegate?.didSelectReset()
    }

    @objc private func counterClockwiseRotate(_ sender: Any) {
        cropToolbarDelegate?.didSelectCounterClockwiseRotate()
    }

    @objc private func clockwiseRotate(_ sender: Any) {
        cropToolbarDelegate?.didSelectClockwiseRotate()
    }

    @objc private func alterCropper90Degree(_ sender: Any) {
        cropToolbarDelegate?.didSelectAlterCropper90Degree()
    }

    @objc private func crop(_ sender: Any) {
        cropToolbarDelegate?.didSelectCrop()
    }
    
    @objc private func horizontalFlip(_ sender: Any) {
        cropToolbarDelegate?.didSelectHorizontalFlip()
    }
    
    @objc private func verticalFlip(_ sender: Any) {
        cropToolbarDelegate?.didSelectVerticalFlip()
    }
}

