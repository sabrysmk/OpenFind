//
//  Field.swift
//  SearchBar
//
//  Created by Zheng on 10/14/21.
//

import UIKit

struct Field {
    
    init(text: Text, index: Int = 0) {
        self.text = text
        fieldHuggingWidth = self.getFieldHuggingWidth()
    }
    
    var text = Text(value: .string(""), colorIndex: 0) {
        didSet {
            fieldHuggingWidth = self.getFieldHuggingWidth()
        }
    }
    
    /// delete button deletes the entire field
    /// clear button is normal, shown when is editing no matter what
    var showingDeleteButton = false
    
    
    /// width of text label + side views, nothing more
    var fieldHuggingWidth = CGFloat(200)
    
    /// if expanded
    var focused = false
    
    enum Value {
        case string(String)
        case list(List)
        case addNew(String) /// `String` for input text during add new -> full cell animation
        
        func getText() -> String {
            switch self {
            case .string(let string):
                return string
            case .list(let list):
                return list.name
            case .addNew(let string):
                return string
            }
        }
    }
    
    struct Text {
        var value: Value {
            didSet {
                switch value {
                case .string(_):
                    self.defaultColor = Constants.defaultHighlightColor.getFieldColor(for: colorIndex)
                case .list(let list):
                    self.defaultColor = UIColor(hex: list.iconColorName)
                case .addNew(_):
                    self.defaultColor = Constants.defaultHighlightColor.getFieldColor(for: colorIndex)
                }
            }
        }
        
        var color: UIColor
        var defaultColor: UIColor
        var colorIndex: Int
        var colorAlpha: CGFloat = 1
        
        init(value: Value, colorIndex: Int) {
            self.value = value
            self.colorIndex = colorIndex
            
            switch value {
            case .string(_):
                let defaultColor = Constants.defaultHighlightColor.getFieldColor(for: colorIndex)
                self.color = defaultColor
                self.defaultColor = defaultColor
                
            case .list(let list):
                let defaultColor = UIColor(hex: list.iconColorName)
                self.color = defaultColor
                self.defaultColor = defaultColor
            case .addNew(_):
                let defaultColor = Constants.defaultHighlightColor.getFieldColor(for: colorIndex)
                self.color = defaultColor
                self.defaultColor = defaultColor
            }
        }
    }
    
    private func getFieldHuggingWidth() -> CGFloat {
        
        if case let .addNew(string) = self.text.value, string.isEmpty {
            return SearchConstants.addWordFieldHuggingWidth
        } else {
            let fieldText = self.text.value.getText()
            let finalText = fieldText.isEmpty ? SearchConstants.addTextPlaceholder : fieldText

            let textWidth = finalText.width(withConstrainedHeight: 10, font: SearchConstants.fieldFont)
            let leftPaddingWidth = SearchConstants.fieldBaseViewLeftPadding
            let rightPaddingWidth = SearchConstants.fieldBaseViewRightPadding
            let textPadding = 2 * SearchConstants.fieldTextSidePadding
            return textWidth + leftPaddingWidth + rightPaddingWidth + textPadding
        }
    }
}


struct FieldOffset {
    var fullWidth = CGFloat(0)
    var percentage = CGFloat(0)
    var shift = CGFloat(0) /// already multiplied by percentage
    var alpha = CGFloat(1) /// percent visible of add new
}

open class FieldLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var fullOrigin = CGFloat(0) /// origin when expanded
    var fullWidth = CGFloat(0) /// width when expanded
    var percentage = CGFloat(0) /// percentage shrunk
    
    override open func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! FieldLayoutAttributes
        copy.fullOrigin = fullOrigin
        copy.fullWidth = fullWidth
        copy.percentage = percentage
        
        return copy
    }
    
    override open func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? FieldLayoutAttributes else { return false }
        guard
            attributes.fullOrigin == fullOrigin,
            attributes.fullWidth == fullWidth,
            attributes.percentage == percentage
        else { return false }
    
        return super.isEqual(object)
    }
    
}
