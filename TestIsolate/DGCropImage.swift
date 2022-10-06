import UIKit

// MARK: - APIs
//public func crop(image: UIImage,
//                               config: Config = Config(),
//                               cropToolbar: CropToolbarProtocol = CropToolbar(frame: CGRect.zero)) -> CropViewController {
//    return CropViewController(image: image,
//                              config: config,
//                              mode: .normal,
//                              cropToolbar: cropToolbar)
//}

//public func crop(image: UIImage, by cropInfo: CropInfo) -> UIImage? {
//    return image.crop(by: cropInfo)
//}

// MARK: - Type Aliases
public typealias Transformation = (
    offset: CGPoint,
    rotation: CGFloat,
    scale: CGFloat,
    manualZoomed: Bool,
    intialMaskFrame: CGRect,
    maskFrame: CGRect,
    scrollBounds: CGRect
)

public typealias CropInfo = (translation: CGPoint, rotation: CGFloat, scale: CGFloat, cropSize: CGSize, imageViewSize: CGSize)

// MARK: - Enums

public enum CropVisualEffectType {
    case blurDark
    case dark
    case light
    case none
}

public enum FixRatiosShowType {
    case adaptive
    case horizontal
    case vetical
}


// MARK: - CropToolbarConfig
public struct CropToolbarConfig {
    public var optionButtonFontSize: CGFloat = 14
    public var optionButtonFontSizeForPad: CGFloat = 20
    public var cropToolbarHeightForVertialOrientation: CGFloat = 44
    public var cropToolbarWidthForHorizontalOrientation: CGFloat = 80
    public var fixRatiosShowType: FixRatiosShowType = .adaptive
    public var toolbarButtonOptions: ToolbarButtonOptions = .all
    public var presetRatiosButtonSelected = false

    var mode: CropToolbarMode = .normal
    var includeFixedRatioSettingButton = true
}

// MARK: - Config
public struct Config {
    public var cropVisualEffectType: CropVisualEffectType = .blurDark
    public var ratioOptions: RatioOptions = .all
   
    public var cropToolbarConfig = CropToolbarConfig()

    var customRatios: [(width: Int, height: Int)] = []

    public init() {
    }

    func getCustomRatioItems() -> [RatioItemType] {
        return customRatios.map {
            (String("\($0.width):\($0.height)"), Double($0.width)/Double($0.height), String("\($0.height):\($0.width)"), Double($0.height)/Double($0.width))
        }
    }
}
