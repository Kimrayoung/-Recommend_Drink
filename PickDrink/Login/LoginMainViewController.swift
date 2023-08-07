//
//  LoginMainViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/11.
//

import Foundation
import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa

@available(iOS 13.0, *)
class LoginMainViewController: UIViewController {
    let authVM = AuthVM.shared
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var appLogo: UILabel!
    @IBOutlet weak var appLogoImg: UIImageView!
    
    @IBOutlet weak var loginBtnStackView: UIStackView!
    @IBOutlet weak var kakaoLoginBtn: UIButton!
    var notLoginBtnColor = UIColor(named: "NotLoginBtn")
    override func viewDidLoad() {
        print(#fileID, #function, #line, "- viewDidLoad")
        super.viewDidLoad()
        
        kakaoLoginBtn.addTarget(self, action: #selector(kakaoLoginBtnClicked(_:)), for: .touchUpInside)
        
        appleLoginBtnSetting()
        notLoginBtnSetting()
    }
    
   
    
    func appleLoginBtnSetting() {
        print(#fileID, #function, #line, "- .")
        let appleLoginBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleLoginBtn.addTarget(self, action: #selector(appleLoginBtnClicked(_:)), for: .touchUpInside)
        self.loginBtnStackView.addArrangedSubview(appleLoginBtn)
    }
    
    func notLoginBtnSetting() {
        print(#fileID, #function, #line, "- <#comment#>")
        let notLoginBtn = UIButton(type: .system)
        notLoginBtn.setTitle("로그인 없이 계속하기", for: .normal)
        notLoginBtn.backgroundColor = notLoginBtnColor
        notLoginBtn.layer.cornerRadius = 10
        notLoginBtn.setTitleColor(.white, for: .normal)
        notLoginBtn.addTarget(self, action: #selector(notLoginBtnClicked(_:)), for: .touchUpInside)
        self.loginBtnStackView.addArrangedSubview(notLoginBtn)
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
                    self.moveToTabbarController()
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
                    self.moveToTabbarController()
                default: return
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - 로그인 없이 진행하기 버튼 눌렀을 경우
    @objc func notLoginBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        authVM.notLogin()
        moveToTabbarController()
    }
    
    //MARK: - Main화면으로 이동(음료리스트화면)
    func moveToTabbarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.modalTransitionStyle = .crossDissolve
        
        self.present(mainVC, animated: true)
    }
}
