//
//  ModalViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/31.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

/// 모달
class ModalViewController: UIViewController {
    let firebaseManage = FirebaseManage.shared
    let db = Firestore.firestore()
    
    var userId = AuthVM.shared.userId.value
    var menuId: String = ""
    var reviewData: Review? = nil
    var reviewIndex: Int? = nil
    var modalType: Modal? = nil
    var firstLabelContent: String? = nil
    let textBorderColor = UIColor(named: "reviewTextViewColor")
    var collectionViewScrollToItem : (() -> ())? = nil
    
    var editCompletedClosure: ((_ reviewEditContent: String, _ reviewIndex: Int) -> ())? = nil
    var complainSendCompledtedClosure: (() -> ())? = nil
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        if textViewChecking() != true {
            let modalAlertAction = UIAlertAction(title: "확인", style: .cancel)
            makeAlert("에러", "입력하지 않은 항목이 있습니다.", modalAlertAction)
            return
        }
        
        guard let reviewData = reviewData else { return }
        let modalTextView = modalTextView.text ?? "없음"
        let reviewId = reviewData.reviewId ?? "없음"
        let userId = userId ?? "없음"
        
        switch modalType {
        case .complain:
            firebaseManage.sendComplain(modalTextView, reviewData, userId) {
                guard let complainSendCompledtedClosure = complainSendCompledtedClosure else { return }
                self.dismiss(animated: true)
                complainSendCompledtedClosure()
            }
        case .editReview:
            firebaseManage.editReview(reviewId, modalTextView) { //edit 성공
                guard let editCompletedClosure = self.editCompletedClosure,
                      let reviewIndex = self.reviewIndex else { return }
                
                editCompletedClosure(modalTextView, reviewIndex)
                self.dismiss(animated: true)
            }
        default: return
        }
    }
    
    //MARK: - 모달 textView가 내용이 있는지 확인하는 함수
    private func textViewChecking() -> Bool {
        if modalTextView.text == modalType?.textViewPlaceHolder {
            return false
        }
        return true
    }

    private func removeReview() {
        guard let reviewData = self.reviewData,
              let reviewId = reviewData.reviewId,
              let reviewStar = reviewData.reviewStar,
              let reviewContent = reviewData.reviewContent else { return }
        
        let originalReview : [String : String] = [
            "menuId" : menuId,
            "review" : reviewContent,
            "reviewId" : reviewId,
            "reviewStar": reviewStar,
        ]
        
        print(#fileID, #function, #line, "- updateReview()\(reviewId)")
        let reviewRemoveRequest = db.collection("reviews").document(self.menuId)
        reviewRemoveRequest.updateData([
            "reviews": FieldValue.arrayRemove([originalReview])
        ])
    }
    
    private func addReview() {
        guard let reviewData = self.reviewData,
              let reviewId = reviewData.reviewId,
              let reviewStar = reviewData.reviewStar,
              let reviewContent = modalTextView.text else { return }
        
        let reviewRemoveRequest = db.collection("reviews").document(self.menuId)
        do {
            let review : [String : String] = [
                "menuId" : self.menuId,
                "review" : reviewContent,
                "reviewId" : reviewId,
                "reviewStar": reviewStar,
            ]
            
            reviewRemoveRequest.updateData([
                "reviews": FieldValue.arrayUnion([review])
            ])
            
            let modalAlertActionhandler = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true)
            }
            makeAlert("리뷰 수정 완료", "메뉴 상세보기 화면으로 돌아갑니다.", modalAlertActionhandler)
        }
    }
    
    
    
    //MARK: - alert만들기
    private func makeAlert(_ titleText: String, _ messageText: String, _ alertAction: UIAlertAction) {
        let modalAlert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        
        modalAlert.addAction(alertAction)
        self.present(modalAlert, animated: true)
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
    
    func textViewDidChange(_ textView: UITextView) {
        guard let textViewPlaceHolder = modalType?.textViewPlaceHolder else { return }
        //100자 넘어가면 더 이상 입력 안됨
        if textView.text.count > 100 {
            textView.deleteBackward()
        }

        if textView.text == textViewPlaceHolder {
            modalTextViewCnt.text = "0 / 100"
        } else {
            modalTextViewCnt.text = "\(textView.text.count) / 100"
        }

    }
    

    //MARK: - 텍스트 뷰 입력 중
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = modalTextView.text as NSString
        let changedText = currentText.replacingCharacters(in: range, with: text)
        modalTextViewCnt.text = "\(changedText.count) / 100"
        return true
    }
}


