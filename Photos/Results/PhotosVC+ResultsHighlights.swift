//
//  PhotosVC+ResultsHighlights.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension PhotosViewController {
    /// call this inside the cell provider. Frames of returned highlights are already scaled.
    func getHighlights(for cell: PhotosResultsCell, with findPhoto: FindPhoto) -> Set<Highlight> {
        /// the highlights to be shown. Create these from `lineHighlights`
        var cellHighlights = Set<Highlight>()
        for index in findPhoto.descriptionLines.indices {
            let line = findPhoto.descriptionLines[index]
            
            /// `lineHighlights` - highlights in the cell without a frame - only represented by their ranges
            guard
                let lineHighlights = line.lineHighlights,
                let textView = cell.descriptionTextView
            else { continue }
            
            let previousLines = Array(findPhoto.descriptionLines.prefix(index))
            let previousDescription = getCellDescription(from: previousLines)
            var previousDescriptionCount = previousDescription.count
            
            /// Needed to account for newLines - otherwise every line after the first will have highlights shifted 1 to the left
            if previousDescriptionCount > 0 {
                previousDescriptionCount += 1
            }
            
            for lineHighlight in lineHighlights {
                let startOffset = lineHighlight.rangeInSentence.startIndex + previousDescriptionCount
                let endOffset = lineHighlight.rangeInSentence.endIndex + previousDescriptionCount
                
                guard
                    let start = textView.position(from: textView.beginningOfDocument, offset: startOffset),
                    let end = textView.position(from: textView.beginningOfDocument, offset: endOffset),
                    let textRange = textView.textRange(from: start, to: end)
                else { continue }
                
                let frame = textView.firstRect(for: textRange)
                
                /// make sure the rectangle actually is valid
                guard frame.size.width > 0, frame.size.height > 0 else { continue }
                
                let cellHighlight = Highlight(
                    string: lineHighlight.string,
                    colors: lineHighlight.colors,
                    alpha: lineHighlight.alpha,
                    position: .init(
                        originalPoint: .zero,
                        pivotPoint: .zero,
                        center: frame.center,
                        size: frame.size,
                        angle: .zero
                    )
                )
                cellHighlights.insert(cellHighlight)
            }
        }
        
        return cellHighlights
    }
    
    /// replace the `resultsState`'s current highlight colors. Don't call `update()`, since applying snapshots is laggy.
    /// This only updates the results collection view.
    func updateResultsHighlightColors() {
        guard let resultsState = model.resultsState else { return }
        for findPhotoIndex in resultsState.findPhotos.indices {
            guard let highlights = resultsState.findPhotos[findPhotoIndex].highlights else { return }
            
            let newHighlights: Set<Highlight> = highlights.mapSet { highlight in
                if let gradient = self.searchViewModel.stringToGradients[highlight.string] {
                    var newHighlight = highlight
                    newHighlight.colors = gradient.colors
                    newHighlight.alpha = gradient.alpha
                    return newHighlight
                }
                return highlight
            }
            model.resultsState?.findPhotos[findPhotoIndex].highlights = newHighlights
            
            /// update the line highlight colors
            for (lineIndex, descriptionLine) in resultsState.findPhotos[findPhotoIndex].descriptionLines.enumerated() {
                guard let lineHighlights = descriptionLine.lineHighlights else { continue }
                    
                let newLineHighlights: Set<FindPhoto.Line.LineHighlight> = lineHighlights.mapSet { highlight in
                    if let gradient = self.searchViewModel.stringToGradients[highlight.string] {
                        var newHighlight = highlight
                        newHighlight.colors = gradient.colors
                        newHighlight.alpha = gradient.alpha
                        return newHighlight
                    }
                    return highlight
                }
                
                model.resultsState?.findPhotos[findPhotoIndex].descriptionLines[lineIndex].lineHighlights = newLineHighlights
            }
                
            /// update visible highlights
            if
                let cell = resultsCollectionView.cellForItem(at: findPhotoIndex.indexPath) as? PhotosResultsCell,
                let findPhoto = model.resultsState?.findPhotos[findPhotoIndex]
            {
                cell.highlightsViewController?.highlightsViewModel.highlights = getHighlights(for: cell, with: findPhoto)
            }
        }
    }
}
