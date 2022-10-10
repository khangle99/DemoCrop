//
//  ViewController.swift
//  TestIsolate
//
//  Created by Khang L on 05/10/2022.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var previewImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "DSC_1540")!
        previewImage.image = image
    }

    @IBAction func resetImageTap(_ sender: Any) {
        let image = UIImage(named: "DSC_1540")!
       
        previewImage.image = image
    }
    
    @IBAction func editTap(_ sender: Any) {
        let image = previewImage.image!
        let vc = CropViewController(image: image)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension ViewController: CropViewControllerDelegate {
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        
    }
    
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        print("didCrop")
        previewImage.image = cropped
    }
}

