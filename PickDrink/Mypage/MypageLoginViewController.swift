//
//  MypageLoginViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/08/01.
//

import Foundation
import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa

class MypageLoginViewController: UIViewController {
    let authVM = AuthVM.shared
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var kakaoLoginBtn: UIButton!
    @IBOutlet weak var loginBtnStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kakaoLoginBtn.addTarget(self, action: #selector(kakaoLoginBtnClicked(_:)), for: .touchUpInside)
        
        appleLoginBtnSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func appleLoginBtnSetting() {
        print(#fileID, #function, #line, "- .")
        let appleLoginBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleLoginBtn.addTarget(self, action: #selector(appleLoginBtnClicked(_:)), for: .touchUpInside)
        self.loginBtnStackView.addArrangedSubview(appleLoginBtn)
    }
    
    //MARK: - 카카오 로그인 눌렀을 경우
    @objc func kakaoLoginBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- kakaoLoginBtnClicked")
        authVM.kakaoTokenAccessChecking()
        authVM.loginStatus
            .withUnretained(self)
            .bind { (vc, loginStatus) in
                switch loginStatus {
                case .login:
                    self.navigationController?.popViewController(animated: true)
                default: return
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - 애플 로그인 눌렀을 경우
    @objc func appleLoginBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- loginBtnClcked")
        authVM.startSignInWithAppleFlow()
        authVM.loginStatus
            .withUnretained(self)
            .bind { vc, loginStatus in
                switch loginStatus {
                case .login:
                    self.navigationController?.popViewController(animated: true)
                default: return
                }
            }
            .disposed(by: disposeBag)
    }
}
