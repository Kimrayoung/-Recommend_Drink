//
//  CustomTextView.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/31.
//

import Foundation
import UIKit

extension UITextView: UITextViewDelegate {
    func textViewSetting(_ textView: UITextView, _ textViewPlaceHolder: String) {
        textView.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(named: "reviewPlaceHolderColor")?.cgColor
        textView.layer.cornerRadius = 8
        textView.text = textViewPlaceHolder
        textView.textColor = UIColor(named: "reviewPlaceHolderColor")
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView,_ reviewTextViewPlaceHolder: String) {

        guard let nowText = textView.text else { return }
        print(#fileID, #function, #line, "- ⭐️textViewDidBeginEditing", nowText == reviewTextViewPlaceHolder, nowText)

        if nowText == reviewTextViewPlaceHolder {
            textView.text = ""
            print(#fileID, #function, #line, "- textView: \(textView.text)")
            textView.textColor = .black
        }
    }
//
//    public func textViewDidEndEditing(_ textView: UITextView, _ textViewPlaceHolder: String) {
//        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            textView.text = textViewPlaceHolder
//            textView.textColor = UIColor(named: "reviewPlaceHolderColor")
//        }
//    }
//
//    public func textViewDidChange(_ textView: UITextView, _ cntLabel: UILabel, _ reviewTextViewPlaceHolder: String) {
//        //100자 넘어가면 더 이상 입력 안됨
//        if textView.text.count > 100 {
//            textView.deleteBackward()
//        }
//
//        if textView.text == reviewTextViewPlaceHolder {
//            cntLabel.text = "0 / 100"
//        } else {
//            cntLabel.text = "\(textView.text.count) / 100"
//        }
//
//        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == reviewTextViewPlaceHolder {
//            textView.text = reviewTextViewPlaceHolder
//            textView.textColor = UIColor(named: "reviewPlaceHolderColor")
//        }
//    }
    
}

//extension UIButton {
//    func 
//}
