//
//  CustomTextView.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/31.
//

import Foundation
import UIKit

extension UITextView {
    func textViewSetting(_ textViewPlaceHolder: String) {
        self.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "reviewTextViewColor")?.cgColor
        self.layer.cornerRadius = 8
        self.text = textViewPlaceHolder
        self.textColor = UIColor(named: "reviewTextViewColor")
    }
}

//extension UIButton {
//    func 
//}
