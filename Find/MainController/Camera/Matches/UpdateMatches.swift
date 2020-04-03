//
//  UpdateMatches.swift
//  Find
//
//  Created by Andrew on 11/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension ViewController {
    
    
    func updateMatchesNumber(to number: Int) {
        
        currentNumberOfMatches = number
        updateStatsNumber?.update(to: number)
        //print("Updating matches number to \(number)")
        
        if number > previousNumberOfMatches {
            if currentPassCount >= 100 {
                currentPassCount = 0
                if shouldHapticFeedback {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
        }
        
        DispatchQueue.main.async {
            self.numberLabel.fadeTransition(0.1)
            self.numberLabel.text = "\(number)"
        }
        previousNumberOfMatches = number
    }
//    func hideTopNumber(hide: Bool) {
//        
//        var xMove = 6
//        var yMove = 14
//        if hide == true {
//            xMove = 0
//            yMove = 0
//            slashImage.alpha = 1
//        } else {
//            slashImage.alpha = 0
//        }
//        
//        matchesBig.bringSubviewToFront(numberDenomLabel)
//        matchesBig.bringSubviewToFront(numberLabel)
//        for constraint in matchesBig.constraints {
//            if constraint.identifier == "numberY" {
//               constraint.constant = CGFloat(-yMove)
//            }
//            if constraint.identifier == "denomY" {
//                constraint.constant = CGFloat(yMove)
//            }
//            if constraint.identifier == "numberX" {
//                constraint.constant = CGFloat(-xMove)
//            }
//            if constraint.identifier == "denomX" {
//                constraint.constant = CGFloat(xMove)
//            }
//        }
//        
//        matchesBig.bringSubviewToFront(slashImage)
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
//            if hide == true {
//                self.numberLabel.alpha = 0
//                self.slashImage.alpha = 0
//            } else {
//                self.numberLabel.alpha = 1
//                self.slashImage.alpha = 1
//            }
//            self.matchesBig.layoutIfNeeded()
//        }, completion: nil)
//    }
    
}
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
