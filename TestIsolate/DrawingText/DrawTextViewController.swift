//
//  DrawTextViewController.swift
//  TestIsolate
//
//  Created by Khang L on 06/10/2022.
//

import UIKit

protocol DrawTextViewControllerDelegate: AnyObject {
    func didRenderText(_ image: UIImage)
}

class DrawTextViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stickerImageView: JLStickerImageView!
    
    private var previousInset: UIEdgeInsets?
    private var previousIndicatorInset: UIEdgeInsets?
    
    weak var delegate: DrawTextViewControllerDelegate?
    private var currentFocusLabel: JLStickerLabelView?
    var image: UIImage?
    private var textColor: UIColor = .red
    
    @IBOutlet weak var toolView: UIStackView!
    @IBOutlet weak var formatView: UIView!
    
    private var isFormatting = false {
        didSet {
            formatView.isHidden = !isFormatting
            toolView.isHidden = isFormatting
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var selectColorButton: UIButton!
    @IBOutlet weak var selectFontBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerImageView.delegate = self
        stickerImageView.image = image

        let addTextItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTap))
        navigationItem.rightBarButtonItem = addTextItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowHideHandle), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowHideHandle), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardShowHideHandle(noti: Notification) {
        guard let userInfo = noti.userInfo,
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        guard let textLabel = stickerImageView.currentlyEditingLabel else { return }
        
        let textLabelWindowRect = stickerImageView.convert(textLabel.frame, to: nil)
        
        if noti.name == UIResponder.keyboardWillShowNotification {
            print("show")
            let keyboardRect = keyboardInfo.cgRectValue
            if keyboardRect.intersects(textLabelWindowRect) {
                let offset = keyboardRect.size.height
                previousInset = scrollView.contentInset
                previousIndicatorInset = scrollView.scrollIndicatorInsets
                scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
            }
            
        } else {
            if let inset = previousInset, let indicatorInset = previousIndicatorInset {
                scrollView.contentInset = inset
                scrollView.scrollIndicatorInsets = indicatorInset
            }
            print("hide")
        }
        
    }
    
    @IBAction func addTextTap(_ sender: Any) {
        self.stickerImageView.addLabel()
        guard let editLabel = stickerImageView.currentlyEditingLabel else { return }
        editLabel.closeView?.image = UIImage(named: "cancel")
        editLabel.rotateView?.image = UIImage.circle(diameter: 18, color: .white)
        editLabel.border?.strokeColor = UIColor.white.cgColor
        editLabel.labelTextView?.font = UIFont.systemFont(ofSize: 14.0)
        editLabel.labelTextView?.becomeFirstResponder()
        editLabel.labelTextView?.text = "Text"
        stickerImageView.textColor = .red
        stickerImageView.fontName = "HelveticaNeue"
    }
    @objc func doneTap(_ sender: Any) {
        guard let image =  stickerImageView.renderContentOnView() else { return }
        delegate?.didRenderText(image)
        //navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectFontTap(_ sender: Any) {
        let vc = SelectFontViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func selectColorTap(_ sender: Any) {
        let config = ColorPickerConfiguration(color: .red)
        config.visibleTabs = [.map, .swatch, .sliders]
        config.overrideSmartInvert = true
       
        let vc = ColorPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func aligmentDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            stickerImageView.textAlignment = .left
        case 1:
            stickerImageView.textAlignment = .center
        case 2:
            stickerImageView.textAlignment = .right
        case 3:
            stickerImageView.textAlignment = .justified
        default:
            stickerImageView.textAlignment = .none
        }
    }
    
}

extension DrawTextViewController: SelectFontViewControllerDelegate {
    func didSelect(_ font: UIFont) {
        stickerImageView.fontName = font.fontName
    }
}

extension DrawTextViewController: ColorPickerDelegate {
    func colorPicker(_ colorPicker: ColorPickerViewController, didAccept color: UIColor) {
        stickerImageView.textColor = color
    }
}

extension DrawTextViewController: JLStickerImageViewDelegate {
    func didTapOutside() {
        isFormatting = false
    }
    
    func didTapEditingLabel(_ label: JLStickerLabelView) {
        isFormatting = true
    }
}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return img
    }
}
