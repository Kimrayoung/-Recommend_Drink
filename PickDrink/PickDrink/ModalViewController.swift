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
    let db = Firestore.firestore()
    
    var menuId: String = ""
    var reviewData: Review? = nil
    var reviewIndex: Int? = nil
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
            let modalAlertAction = UIAlertAction(title: "확인", style: .cancel)
            makeAlert("에러", "입력하지 않은 항목이 있습니다.", modalAlertAction)
            return
        }
        
        switch modalType {
        case .complain:
            sendComplaint()
        case .editReview:
            removeReview()
            addReview()
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
    
    //MARK: - 신고하기를 눌렀을 경우 -> 리뷰 내용, 리뷰 아이디, 메뉴 아이디
    private func sendComplaint() {
        guard let complainReview = modalFirstContentLabel.text,
              let reviewId = reviewData?.reviewId else { return }

        let complain: Complain = Complain(menuId: self.menuId, complainReview: complainReview, complainReason: self.modalTextView.text, reviewId: reviewId)
        
        do {
            try db.collection("complaints").addDocument(from: complain)
            
            let modalAlertActionhandler = UIAlertAction(title: "확인", style: .default) { _ in
                self.dismiss(animated: true)
            }
            makeAlert("신고사항 접수 완료", "메뉴 상세보기 화면으로 돌아갑니다.", modalAlertActionhandler)
        } catch let err {
            print(#fileID, #function, #line, "- err: \(err)")
        }
    }
    
    //1번 방법 - 배열의 전체를 삭제한 다음 전체 review를 다시 붙여넣기
    //1번 방법의 장점 - 순서 유지, 쉬움
    //1번 방법의 단점 - db수정이 오래걸릴 수 있음(전체 데이터를 다시 붙여넣어야 하니까)(데이터 완료가 언제 될지 예측이 어려움)
    //2번 방법 - 배열에서 해당 Review만 삭제한 후 수정한 Review를 가장 앞에 오게 함
    //2번 방법의 장점 - 귀찮음, db수정이 오래걸리지 않음,,?
    private func removeReview() {
        guard let reviewData = self.reviewData,
              let reviewId = reviewData.reviewId,
              let reviewPassword = reviewData.reviewPassword,
              let reviewStar = reviewData.reviewStar,
              let reviewContent = reviewData.review else { return }
        
        let originalReview : [String : String] = [
            "menuId" : menuId,
            "review" : reviewContent,
            "reviewId" : reviewId,
            "reviewStar": reviewStar,
            "reviewPassword": reviewPassword
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
              let reviewPassword = reviewData.reviewPassword,
              let reviewStar = reviewData.reviewStar,
              let reviewContent = modalTextView.text else { return }
        
        let reviewRemoveRequest = db.collection("reviews").document(self.menuId)
        do {
            let review : [String : String] = [
                "menuId" : self.menuId,
                "review" : reviewContent,
                "reviewId" : reviewId,
                "reviewStar": reviewStar,
                "reviewPassword": reviewPassword
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

        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textView.text == textViewPlaceHolder {
            textView.text = textViewPlaceHolder
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


