//
//  SetUpRamReel.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import SnapKit
import VideoToolbox

/// Ramreel setup
extension ViewController: UICollectionViewDelegate, UITextFieldDelegate {
    func setUpRamReel() {
        dataSource = SimplePrefixQueryDataSource(data)
        var frameRect = view.bounds
        frameRect.size.height = 100
        ramReel = RAMReel(frame: frameRect, dataSource: dataSource, placeholder: "Start by typing…", attemptToDodgeKeyboard: false) {
            print("Plain:", $0)
            self.finalTextToFind = $0
        }
        ramReel.textField.inputAccessoryView = toolBar
        cancelButtonNew.layer.cornerRadius = 4
        autoCompleteButton.layer.cornerRadius = 4
        newMatchButton.layer.cornerRadius = 4
        
        
        view.addSubview(ramReel.view)
        ramReel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        ramReel.textFieldDelegate = self as UITextFieldDelegate
        ramReel.textField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        
        
    }
   
    @objc func textFieldDidChange(_ textField: UITextField) {
        if ramReel.wrapper.selectedItem == nil {
        
        autoCompleteButton.isEnabled = false
        autoCompleteButton.alpha = 0.5
        } else {
        autoCompleteButton.isEnabled = true
        autoCompleteButton.alpha = 1
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        autoCompleteButton.isEnabled = false

        ramReel.view.bounds = view.bounds
        print("textfield")
        print(ramReel.collectionView.frame)
        ramReel.collectionView.isHidden = false
        ramReel.collectionView.alpha = 0
        darkBlurEffectHeightConstraint.constant = self.view.bounds.size.height
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.autoCompleteButton.alpha = 0.5
            self.ramReel.collectionView.alpha = 1
            self.darkBlurEffect.alpha = 0.2
             self.view.layoutIfNeeded()
        }, completion: nil)
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //guard let imageView = view.viewWithTag(13579) else { print("sdflkj"); return }
        
         self.darkBlurEffectHeightConstraint.constant = 100
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            //imageView.alpha = 0
            self.ramReel.collectionView.alpha = 0
            var frameRect = self.view.bounds
            frameRect.size.height = 100
            self.ramReel.view.bounds = frameRect
            self.darkBlurEffect.alpha = 0.7
                
//            switch self.scanModeToggle {
//            case .classic:
//        //        self.sceneView.session.run(self.sceneConfiguration) ///which is ARWorldTracking
//            case .fast:
//         //       self.sceneView.session.run(AROrientationTrackingConfiguration())
//                self.stopCoaching()
//            case .focused:
//                let config = ARImageTrackingConfiguration()
//                if let tag1 = self.view.viewWithTag(1) { tag1.alpha = 1 }
//                if let tag2 = self.view.viewWithTag(2) { tag2.alpha = 1 }
//                self.stopCoaching()
//                self.sceneView.session.run(config)
//            }
            //self.stopProcessingImage = false
            self.view.layoutIfNeeded()
        }, completion: {_ in
           // imageView.removeFromSuperview()
            //self.view.bringSubviewToFront(self.matchesBig)
            self.ramReel.collectionView.isHidden = true
        }
        )
             print(ramReel.selectedItem)
//        if ramReel.selectedItem == "" {
//            ramReel.placeholder = "Type here to find!"
//        }
        finalTextToFind = ramReel.selectedItem ?? ""
        
    }
    
    func convertToUIImage(buffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
        {
            //let capturedImage = UIImage(cgImage: temporaryImage)
            let bufferSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            print(bufferSize)
            //let deviceRatio = deviceSize.height / deviceSize.width
//            let newWidth = bufferSize.height * deviceRatio
//            let offset = (bufferSize.width - newWidth)
//            let rect = CGRect(x: offset, y: 0, width: newWidth, height: bufferSize.height)
//            let croppedCgImage = temporaryImage.cropping(to: rect)!
            let capturedImage = UIImage(cgImage: temporaryImage, scale: 1.0, orientation: .right)
            return capturedImage
        }
        return nil
    }

    
    
}


//extension UIImage {
//    public convenience init?(pixelBuffer: CVPixelBuffer, sceneView: ARSCNView) {
//        var cgImage: CGImage?
//        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
//
//        guard var newCgImage = cgImage else {
//            return nil
//        }
//        let orient = UIApplication.shared.statusBarOrientation
//        let viewportSize = sceneView.bounds.size
//        if let transform = sceneView.session.currentFrame?.displayTransform(for: orient, viewportSize: viewportSize).inverted() {
//            var finalImage = CIImage(cvPixelBuffer: pixelBuffer).transformed(by: transform)
//            guard let buffer = sceneView.session.currentFrame?.capturedImage else { return }
//            let temporaryContext = CIContext(options: nil)
//            if let temporaryImage = temporaryContext.createCGImage(finalImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
//            {
//                newCgImage = temporaryImage
//            }
//        }
//        self.init(cgImage: newCgImage)
//    }
//}

