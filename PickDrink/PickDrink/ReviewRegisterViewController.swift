//
//  ReviewViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/30.
//

import Foundation
import UIKit
import Cosmos

class ReviewRegisterViewController: UIViewController {
    var navigationTitle: String = ""
    
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewTextViewCnt: UILabel!
    @IBOutlet weak var reviewRegisterBtn: UIButton!
    @IBOutlet weak var reviewPasswordTextField: UITextField!
    
    let textViewPlaceHolder: String = "음료 맛이 어떤지 간단하게 적어주세요!"
    let textBorderColor = UIColor(named: "reviewTextViewColor")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        starView.settings.fillMode = .full
        reviewTextView.textViewSetting(textViewPlaceHolder)
        textFieldSetting()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setNavigationBar() {
        self.navigationItem.title = navigationTitle
        let backBarButtonItemSetting = UIBarButtonItem(title: "메뉴 정보", style: .plain, target: self, action: #selector(backBarBtnAction(_:)))
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItemSetting
    }
    
    @objc private func backBarBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func textFieldSetting() {
        reviewPasswordTextField.layer.borderColor = textBorderColor?.cgColor
    }
    
    //이 부분 extension을 이용해서 빼서 같이 사용할 수 있을 것 같은데 어떻게 하지
    @objc func registerBtnClicked(_ sender: UIButton) {
        guard let modalVC = ModalViewController.getInstance() else { return }
        modalVC.modalType = .complain
//        modalVC.firstLabelContent = 
    }
    
}

extension ReviewRegisterViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if reviewTextView.text == textViewPlaceHolder {
            reviewTextView.text = ""
            reviewTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if reviewTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            reviewTextView.text = textViewPlaceHolder
            reviewTextView.textColor = textBorderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = reviewTextView.text as NSString
        let changedText = currentText.replacingCharacters(in: range, with: text)
        reviewTextViewCnt.text = "\(changedText.count) / 100"
        return true
    }
}
