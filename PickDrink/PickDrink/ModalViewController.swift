//
//  ModalViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/31.
//

import Foundation
import UIKit
public enum modal{
    case wrongContent //잘못 기재된 내용 신고하는 모달
    case complain //신고리뷰
    
    var firstTitle: String {
        switch self {
        case .wrongContent: return "잘못 기재된 메뉴"
        case .complain: return "신고 리뷰 내용"
        }
    }
    
    var secondTitle: String {
        switch self {
        case .wrongContent: return "신고 리뷰 내용"
        case .complain: return "신고 사유"
        }
    }
    
    var firstLabelTextFont: UIFont {
        switch self {
        case .wrongContent: return UIFont.boldSystemFont(ofSize: 16)
        case .complain: return UIFont.systemFont(ofSize: 14)
        }
    }
    
    var textViewPlaceHolder: String {
        switch self {
        case .wrongContent: return "잘못 기재된 내용을 입력해주세요."
        case .complain: return "신고하시는 이유를 간단히 작성해주세요."
        }
    }
}

class ModalViewController: UIViewController {
    var modalType: modal? = nil
    var firstLabelContent: String? = nil
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    
    @IBOutlet weak var modalFirstContentLabel: UILabel!
    @IBOutlet weak var modalTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicModalSetting()
    }
    
    private func basicModalSetting() {
        modalFirstContentLabel.layer.borderWidth = 1
        modalFirstContentLabel.layer.borderColor = UIColor(named: "reviewTextViewColor")?.cgColor
        modalFirstContentLabel.layer.cornerRadius = 8
        
        guard let modalType = modalType,
              let firstLabelContent = firstLabelContent else { return }
        
        firstTitleLabel.text = modalType.firstTitle
        secondTitleLabel.text = modalType.secondTitle
        modalFirstContentLabel.font = modalType.firstLabelTextFont
        modalFirstContentLabel.text = firstLabelContent
        self.modalTextView.textViewSetting(modalType.textViewPlaceHolder)

    }
    
}
