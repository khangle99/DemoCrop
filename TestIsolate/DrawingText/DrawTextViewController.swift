//
//  DrawTextViewController.swift
//  TestIsolate
//
//  Created by Khang L on 06/10/2022.
//

import UIKit

class DrawTextViewController: UIViewController {
    
    @IBOutlet weak var stickerImageView: JLStickerImageView!
    private var currentFocusLabel: JLStickerLabelView?
    var image: UIImage?
    private var textColor: UIColor = .red
    
    @IBOutlet weak var formatView: UIView!
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerImageView.delegate = self
        stickerImageView.image = image
        
        let addTextItem = UIBarButtonItem(title: "Add Text", style: .plain, target: self, action: #selector(addTextTap))
        navigationItem.rightBarButtonItem = addTextItem
    }
    
    @objc func addTextTap(_ sender: Any) {
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
    }
    
    func didTapEditingLabel(_ label: JLStickerLabelView) {
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
