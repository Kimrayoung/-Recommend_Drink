//
//  PaddingCustomLabel.swift
//  PickDrink
//
//  Created by 김라영 on 2023/04/04.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {
    @IBInspectable var topPadding: CGFloat = 10.0
    @IBInspectable var bottomPadding: CGFloat = 10.0
    @IBInspectable var leftPadding: CGFloat = 10.0
    @IBInspectable var rightPadding: CGFloat = 10.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftPadding + rightPadding, height: size.height + topPadding + bottomPadding)
    }
    
    override var bounds: CGRect {
        didSet{
            preferredMaxLayoutWidth = bounds.width - (leftPadding + rightPadding)
        }
    }
}
