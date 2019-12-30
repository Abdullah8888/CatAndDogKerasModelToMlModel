//
//  ViewController.swift
//  CatAndDogKerasModelToMlModel
//
//  Created by Jimoh Babatunde  on 23/12/2019.
//  Copyright © 2019 Jimoh Babatunde. All rights reserved.
//

import UIKit

enum Animal {
    case cat
    case dog
    case notAnimail
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    let model = MyModel()
    private let trainedImageSize = CGSize(width: 224, height: 224)
    let animalArray = [UIImage(named: "cat1"), UIImage(named: "dog1")]
    
    @IBOutlet weak var resultLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //let imageArra
        print("*** CAT AND DOG CLASIFICATION ***")
    }

    override func viewDidAppear(_ animated: Bool) {
        //self.sample()
    }
//    func sample() {
//        for animal in animalArray {
//            self.predict(image: animal!)
//        }
//    }
    
    @IBAction func takePic(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let animal = self.predict(image: image)
                
                self.imageView.image = image
                
                
                if let animal = animal{
                    if animal == .dog{
                        self.resultLbl.text = "Dog"
                    }
                    else if animal == .cat{
                        self.resultLbl.text = "Cat"
                    }
                    else if animal == .notAnimail{
                        self.resultLbl.text = "not sure"
                    }
                }
            }
        }
    }
    
    func predict(image: UIImage) -> Animal? {
        do {
            if let resizedImage = resize(image: image, newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() {
                let prediction = try model.prediction(image: pixelBuffer)
                print("the real result is 1 \(prediction.output)")
                print("the real result is 2 \(prediction.output[0])")
                print("the real result is 3 \(prediction.output[0].decimalValue)")
                let value = prediction.output[0].intValue
                print(value)
                
                if value == 1{
                    print("this is a dog")
                    return .dog
                }
                else if value == 0{
                    print("this is a cat")
                    return .cat
                }
                else {
                    return .notAnimail
                }
            }
        } catch {
            print("Error while doing predictions: \(error)")
        }
    return nil
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

