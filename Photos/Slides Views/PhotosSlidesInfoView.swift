//
//  PhotosSlidesInfoView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

struct PhotosSlidesInfoView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var realmModel: RealmModel
    @ObservedObject var infoModel: PhotoSlidesInfoViewModel

    var body: some View {
        let photo = model.slidesState?.currentPhoto ?? Photo(asset: PHAsset())

        VStack(spacing: 0) {
            if infoModel.showHandle {
                Rectangle()
                    .fill(UIColor.secondaryLabel.color)
                    .frame(height: 0.4)
                    .opacity(0.75)
                
                Capsule()
                    .fill(UIColor.secondaryLabel.color)
                    .frame(width: 36, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }

            VStack(alignment: .leading) {
                Text(verbatim: "\(photo.asset.originalFilename ?? "Photo")")

                Text(verbatim: "\(getDateString(from: photo))")
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .blueBackground()

                HStack {
                    let ignored = photo.isIgnored

                    if !ignored {
                        let (isScanned, scanTitle) = getScanState(from: photo)
                        PhotosScanningInfoButton(
                            title: scanTitle,
                            description: isScanned ? "Tap to Rescan" : nil,
                            isOn: isScanned
                        ) {
                            scanNow()
                        }
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }

                    PhotosScanningInfoButton(
                        title: ignored ? "Ignored" : "Ignore",
                        description: ignored ? "Tap to Unignore" : nil,
                        isOn: ignored
                    ) {
                        ignore(photo: photo)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                Group {
                    if let text = realmModel.container.getText(from: photo.asset.localIdentifier) {
                        if
                            photo.metadata?.dateScanned != nil,
                            !photo.isIgnored,
                            !Constants.versionsWithSlantedTextSupport.contains(text.scannedInVersion ?? "")
                        {
                            Button {
                                scanNow()
                            } label: {
                                Text("Rescan to support slanted text")
                            }
                        }
                    }
                }
                .foregroundColor(UIColor.secondaryLabel.color)
            }
            .foregroundColor(.accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(16)
        }
        .edgesIgnoringSafeArea(.all)
        .sizeReader { size in
            infoModel.sizeChanged?(size)
        }
    }

    func scanNow() {
        guard let slidesPhoto = model.slidesState?.getCurrentSlidesPhoto() else { return }
        model.scanSlidesPhoto?(slidesPhoto)
    }

    func ignore(photo: Photo) {
        model.ignore(photos: [photo])
    }

    func getDateString(from photo: Photo) -> String {
        if let date = photo.asset.creationDate {
            return date.dateTimeFormat
        }
        return ""
    }

    /// 1. is scanned or not
    /// 2. title
    func getScanState(from photo: Photo) -> (Bool, String) {
        if let metadata = photo.metadata, metadata.dateScanned != nil {
            return (true, "Scanned")
        }
        return (false, "Scan Now")
    }
}

struct PhotosScanningInfoButton: View {
    let title: String
    var description: String?
    let isOn: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)

                if let description = description {
                    Text(description)
                        .font(.subheadline)
                }
            }
            .foregroundColor(isOn ? .white : .accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .blueBackground(highlighted: isOn)
        }
    }
}

extension Date {
    var dateTimeFormat: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "MMM d, yyyy' at 'h:mm a"
        let string = formatter.string(from: self)
        return string
    }
}
