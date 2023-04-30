//
//  ModalViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/31.
//

import Foundation
import UIKit

/// 모달
class ModalViewController: UIViewController {
    var modalType: Modal? = nil
    var firstLabelContent: String? = nil
    let textBorderColor = UIColor(named: "reviewTextViewColor")
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    
    @IBOutlet weak var modalFirstContentLabel: PaddingLabel!
    @IBOutlet weak var modalTextView: UITextView!
    @IBOutlet weak var modalTextViewCnt: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicModalSetting()
        modalTextView.delegate = self
        registerBtn.addTarget(self, action: #selector(registerBtnClicked(_:)), for: .touchUpInside)
    }
    
    //MARK: - 모달화면 기본 세팅
    private func basicModalSetting() {
        modalView.layer.cornerRadius = 10
        
        modalFirstContentLabel.layer.borderWidth = 1
        modalFirstContentLabel.layer.borderColor = UIColor(named: "reviewPlaceHolderColor")?.cgColor
        modalFirstContentLabel.layer.cornerRadius = 8
        
        guard let modalType = modalType,
              let firstLabelContent = firstLabelContent else { return }
        
        firstTitleLabel.text = modalType.firstTitle
        secondTitleLabel.text = modalType.secondTitle
        modalFirstContentLabel.font = modalType.firstLabelTextFont
        modalFirstContentLabel.text = firstLabelContent
        
        self.modalTextView.textViewSetting(self.modalTextView, modalType.textViewPlaceHolder)
    }
    
    //MARK: - 모달 등록 버튼 클릭
    @objc private func registerBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- registerBtnClicked")
        if !textViewChecking() {
            let titleText = "에러"
            let titleString = NSAttributedString(string: "에러")
            
            let modalAlert = UIAlertController(title: titleText, message: "입력하지 않은 항목이 있습니다", preferredStyle: .alert)
            let modalAlertAction = UIAlertAction(title: "확인", style: .cancel)
            
            modalAlert.addAction(modalAlertAction)
            self.present(modalAlert, animated: true)
        }
    }
    
    //MARK: - 모달 textView가 내용이 있는지 확인하는 함수
    private func textViewChecking() -> Bool {
        if modalTextView.text == modalType?.textViewPlaceHolder {
            return false
        }
        return true
    }
    
}

//MARK: - 모달VC에 있는 textView관련 함수
extension ModalViewController: UITextViewDelegate {
    //MARK: - 텍스트 뷰 입력 시작
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textViewPlaceHolder = modalType?.textViewPlaceHolder else { return }
        if modalTextView.text == textViewPlaceHolder {
            print(#fileID, #function, #line, "- ?")
            modalTextView.text = ""
            modalTextView.textColor = .black
        }
    }

    //MARK: - 텍스트 뷰 입력 끝
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let textViewPlaceHolder = modalType?.textViewPlaceHolder else { return }
        if modalTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            modalTextView.text = textViewPlaceHolder
            modalTextView.textColor = textBorderColor
        }
    }

    //MARK: - 텍스트 뷰 입력 중
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = modalTextView.text as NSString
        let changedText = currentText.replacingCharacters(in: range, with: text)
        modalTextView.text = "\(changedText.count) / 100"
        return true
    }
}
