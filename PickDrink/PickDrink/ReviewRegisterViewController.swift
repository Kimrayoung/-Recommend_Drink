//
//  ReviewViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/30.
//

import Foundation
import UIKit
import Cosmos
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

/// 리뷰등록 화면
class ReviewRegisterViewController: UIViewController {
    let db = Firestore.firestore()
    var menuId: String = ""
    var navigationTitle: String = ""
    
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewTextViewCnt: UILabel!
    @IBOutlet weak var reviewRegisterBtn: UIButton!
    @IBOutlet weak var reviewPasswordTextField: UITextField!
    
    let textViewPlaceHolder: String = "음료에 대한 생각이나 꿀팁을 간단하게 적어주세요!"
    let textBorderColor = UIColor(named: "reviewPlaceHolderColor")
    
    var reviewClosure: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        starView.settings.fillMode = .full
        reviewPasswordTextField.delegate = self
        reviewTextView.delegate = self
        reviewTextView.textViewSetting(self.reviewTextView,textViewPlaceHolder)
        textFieldSetting()
        reviewRegisterBtn.addTarget(self, action: #selector(registerBtnClicked(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - 네비게이션 세팅
    private func setNavigationBar() {
        self.navigationItem.title = navigationTitle
        let backBarButtonItemSetting = UIBarButtonItem(title: "메뉴 정보", style: .plain, target: self, action: #selector(backBarBtnAction(_:)))
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItemSetting
    }
    
    //MARK: - 네비게이션 뒤로가기 버튼 클릭
    @objc private func backBarBtnAction(_ sender: UIButton) {
        print(#fileID, #function, #line, "- \(reviewPasswordTextField.text)")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 비밀번호 텍스트필드 보더 세팅
    private func textFieldSetting() {
        reviewPasswordTextField.layer.borderColor = textBorderColor?.cgColor
    }
    
    //MARK: - 리뷰 등록하기 버튼 클릭
    @objc func registerBtnClicked(_ sender: UIButton) {
        let passwordCheck = passwordChecking()
        let starAndReviewCheck = starAndReviewChecking()
        
        print(#fileID, #function, #line, "- passwordChecking", passwordCheck)
        if !passwordCheck {
            let titleText = "에러"
            let passwordAlert = UIAlertController(title: titleText, message: "비밀번호를 확인해주세요!", preferredStyle: .alert)
            
            let passwordAlertAction = UIAlertAction(title: "확인", style: .cancel)

            passwordAlert.addAction(passwordAlertAction)
            self.present(passwordAlert, animated: true)
            return
        } else if !starAndReviewCheck {
            let titleText = "에러"
            let reviewAlert = UIAlertController(title: titleText, message: "입력하지 않은 항목이 있습니다", preferredStyle: .alert)
            let reviewAlertAction = UIAlertAction(title: "확인", style: .cancel)
            
            reviewAlert.addAction(reviewAlertAction)
            self.present(reviewAlert, animated: true)
            return
        }
        
        sendReviewData()
        
        //별점, 리뷰, 비밀번호가 모두 입력이 되어있는 것을 확인했다면 해당 페이지가 pop되고 review가 추가됨
        self.navigationController?.popViewController(animated: true)
        //메뉴 디테일 화면에서 방금 추가한 리뷰가 바로 보이도록 해야한다

    }
    
    //MARK: - 패스워드 입력되었는지 확인
    private func passwordChecking() -> Bool {
        if reviewPasswordTextField.text == "" {
            return false
        } else if reviewPasswordTextField.text?.count != 4 {
            return false
        }
        return true
    }
    
    //MARK: - 별점이랑 리뷰가 등록되었는지 확인
    private func starAndReviewChecking() -> Bool {
        print(#fileID, #function, #line, "- starView.rating: \(Int(starView.rating))")
        if reviewTextView.text == textViewPlaceHolder {
            return false
        } else if Int(starView.rating) == 0 {
            return false
        }
        return true
    }
    
    //MARK: - firestroe로 데이터 보내기
    private func sendReviewData() {
        var starRating: String = ""
        if starView.rating == 1 {
            starRating = "onestar"
        } else if starView.rating == 2 {
            starRating = "twostars"
        } else if starView.rating == 3 {
            starRating = "threestars"
        } else if starView.rating == 4 {
            starRating = "fourstars"
        } else if starView.rating == 5 {
            starRating = "fivestars"
        }
        
        guard let password = reviewPasswordTextField.text else { return }
        //해당 메뉴에 해당 하는 문서가 있으면 update이고 없으면 set
        
        let reviewSendRequest = db.collection("reviews").document(menuId)
        reviewSendRequest.getDocument { (doc, err) in
            if let doc = doc, doc.exists {
                let review : [String : String] = [
                    "menuId" : self.menuId,
                    "review" : self.reviewTextView.text,
                    "reviewId" : UUID().uuidString,
                    "reviewStar": starRating,
                    "reviewPassword": password
                ]
                
                reviewSendRequest.updateData([
                    "reviews": FieldValue.arrayUnion([review])
                ])
            } else {
                do {
                    let review: Review = Review(review: self.reviewTextView.text, reviewPassword: self.reviewPasswordTextField.text, reviewStar: starRating, reviewId: UUID().uuidString, menuId: self.menuId)

                    let setReview: ReviewArray = ReviewArray(reviews: [review])
                    
                    try self.db.collection("reviews").document(self.menuId).setData(from: setReview)
                    
                } catch let error {
                    print(#fileID, #function, #line, "- err: \(error)")
                }
            }
            
            if let reviewClosure = self.reviewClosure {
                reviewClosure()
            }
        }
    }
    
}

//MARK: - 리뷰 textView관련 extension
extension ReviewRegisterViewController: UITextViewDelegate {
    //MARK: - 리뷰 textView에 입력이 시작되었을 경우
    func textViewDidBeginEditing(_ textView: UITextView) {
        if reviewTextView.text == textViewPlaceHolder {
            print(#fileID, #function, #line, "- ?")
            reviewTextView.text = ""
            reviewTextView.textColor = .black
        }
    }

    //MARK: - 리뷰 textView에 입력이 끝났을 경우
    func textViewDidEndEditing(_ textView: UITextView) {
        if reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            reviewTextView.text = textViewPlaceHolder
            reviewTextView.textColor = textBorderColor
        }
    }
    
    //MARK: - 리뷰 입력 중
    func textViewDidChange(_ textView: UITextView) {
        //MARK: - 리뷰가 100자 이상 넘어가면 안되도록
        if textView.text.count > 100 {
            textView.deleteBackward()
        }

        if textView.text == textViewPlaceHolder {
            reviewTextViewCnt.text = "0 / 100"
        } else {
            reviewTextViewCnt.text = "\(textView.text.count) / 100"
        }
    }

    //MARK: - 리뷰 textView에 입력 중일 때
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = reviewTextView.text as NSString
        let changedText = currentText.replacingCharacters(in: range, with: text)
        reviewTextViewCnt.text = "\(changedText.count) / 100"
        return true
    }
}

//MARK: - textField관련 extension
extension ReviewRegisterViewController: UITextFieldDelegate {
    //MARK: - password text에는 숫자만 입력하도록 함
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
