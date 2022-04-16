//
//  CameraVC+LivePreview.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import UIKit

extension CameraViewController {
    func createLivePreview() -> LivePreviewViewController {
        let storyboard = UIStoryboard(name: "CameraContent", bundle: nil)
        let livePreviewViewController = storyboard.instantiateViewController(identifier: "LivePreviewViewController") { coder in
            LivePreviewViewController(coder: coder, tabViewModel: self.tabViewModel)
        }
        
        /// called when an image is first returned
        livePreviewViewController.needSafeViewUpdate = { [weak self] in
            guard let self = self else { return }
            
            Task {
                await livePreviewViewController.updateViewportSize(safeViewFrame: self.safeView.frame)
                livePreviewViewController.changeZoom(to: self.zoomViewModel.zoom, animated: false)
                livePreviewViewController.changeAspectProgress(to: self.zoomViewModel.aspectProgress, animated: false)
            }
        }
        
        livePreviewViewController.changeContentContainerViewFrame = { [weak self] frame in
            guard let self = self else { return }
            self.contentContainerView.frame = frame
            self.contentContainerView.alpha = 1
        }
        
        livePreviewViewController.changeSimulatedSafeViewFrame = { [weak self] frame in
            guard let self = self else { return }
            self.simulatedSafeView.frame = frame
            self.simulatedSafeView.alpha = 1
        }
        
        livePreviewViewController.frameCaptured = { [weak self] pixelBuffer in
            guard let self = self else { return }
            
            if !self.model.loaded {
                self.loadUI()
            }
            
            if
                !self.model.shutterOn,
                self.model.livePreviewScanning,
                self.tabViewModel.tabState == .camera,
                self.searchViewModel.stringToGradients.count > 0,
                self.shouldScan()
            {
                Find.prioritizedAction = .camera
                Task {
                    await self.findAndAddHighlights(pixelBuffer: pixelBuffer)
                }
            }
        }
        
        livePreviewViewController.loaded = { [weak self] in
            guard let self = self else { return }
            self.loadUI()
        }
        
        addChildViewController(livePreviewViewController, in: livePreviewContainerView)
        
        livePreviewViewController.view.alpha = 0
        livePreviewContainerView.backgroundColor = .clear
        livePreviewViewController.view.backgroundColor = .clear
        return livePreviewViewController
    }
    
    func loadUI() {
        DispatchQueue.main.async {
            self.model.loaded = true
        
            /// slight lag to avoid focusing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate(withDuration: 0.15) {
                    self.livePreviewViewController?.view.alpha = 1
                }
            }
        }
    }

    func showLivePreview() {
        self.livePreviewContainerView.alpha = 1
    }

    func hideLivePreview() {
        UIView.animate(withDuration: 0.8) {
            self.livePreviewContainerView.alpha = 0
        }
    }
    
    /// stop running the preview when go to a different tab
    func stopRunning() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let livePreviewViewController = self.livePreviewViewController, livePreviewViewController.session.isRunning {
                self.livePreviewViewController?.session.stopRunning()
            }
        }
    }
}
