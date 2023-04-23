//
//  PasswordAlertViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/04/06.
//

import Foundation
import UIKit

///패스워드 잘못 입력했을 때 뜨는 알림창
class PasswordAlertViewController: UIViewController {
    var reviewPW: String = ""
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordWrongLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okayBtn: UIButton!
    
    var checkBtnClosure: (() -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordWrongLabel.isHidden = true
        alertViewBackgroundSetting()
        alertBtnBorderSetting()
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked(_:)), for: .touchUpInside)
        okayBtn.addTarget(self, action: #selector(okayBtnClicked(_:)), for: .touchUpInside)
    }
    
    //MARK: - alert창 배경 세팅
    private func alertViewBackgroundSetting() {
        alertView.layer.backgroundColor = UIColor.black.cgColor
//        alertView.layer.opacity = 0.7
        alertView.layer.cornerRadius = 9
        alertView.layer.masksToBounds = true
        passwordTextField.backgroundColor = UIColor(named: "LabelThinColor")
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "ex) 0000", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        passwordTextField.textColor = .white
    }
    
    //MARK: - alert창 버튼 보더 세팅
    private func alertBtnBorderSetting() {
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.white.cgColor
        okayBtn.layer.borderWidth = 1
        okayBtn.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK: - alert창 취소버튼 클릭
    @objc private func cancelBtnClicked(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    //MARK: - alert창 확인버튼 클릭
    @objc private func okayBtnClicked(_ sender: UIButton) {
        guard let userInputPw = passwordTextField.text else { return }
        
        if userInputPw == reviewPW {
            if let checkBtnClosure = checkBtnClosure {
                checkBtnClosure()
            }
            self.dismiss(animated: true)
        } else {
            passwordWrongLabel.isHidden = false
        }
        
    }
    
}
