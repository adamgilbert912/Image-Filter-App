//
//  ViewController.swift
//  Project 13
//
//  Created by macbook on 1/14/20.
//  Copyright © 2020 example. All rights reserved.
//

import CoreImage
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensityLabel: UILabel!
    var currentImage: UIImage!
    @IBOutlet var slider: UISlider!
    
    var context: CIContext!
    var filter: CIFilter!
    var filterName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(imagePicker))
        
        context = CIContext()
        filter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func imagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: image)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let image = imageView.image else {return}
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func changeFilterButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Filter", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
       
        present(alert, animated: true)
        
        guard let popover = alert.popoverPresentationController else {return}
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
    }
    
    func setFilter(action: UIAlertAction) {
        guard let title = action.title else {return}
        guard currentImage != nil else {return}
        filter = CIFilter(name: title)
        
        let beginImage = CIImage(image: currentImage)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = filter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            filter.setValue(slider.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) {
            filter.setValue(slider.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey) {
            filter.setValue(slider.value * 10, forKey: kCIInputScaleKey)
        }
        
        if inputKeys.contains(kCIInputCenterKey) {
            filter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        guard let image = filter.outputImage else {return}
        
        if let cgImage = context.createCGImage(image, from: image.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            imageView.image = uiImage
        }
        
        imageView.alpha = 0
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
                self.imageView.alpha = 1
            })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Saved!", message: "Your image was saved.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Great!", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }

}
