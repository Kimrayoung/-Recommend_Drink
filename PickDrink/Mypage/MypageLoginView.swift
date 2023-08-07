//
//  MypageLoginView.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/12.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

///마이페이지 계정 custom view(로그인 o)
class MypageLoginView: UIView {
    let authVM = AuthVM.shared
    let firebaseManage = FirebaseManage.shared
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    
    let myPageMainColor = UIColor(named: "MypageMainColor")
    var userInfo: UserInfo? = nil
    var loginCompletion: (() -> ())? = nil
    var logoutCompletion: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadView() {
        print(#fileID, #function, #line, "- <#comment#>")
        let view = Bundle.main.loadNibNamed("MypageLoginView", owner: self, options: nil)?.first as! UIView
        
        view.frame = bounds
        addSubview(view)
        
        btnSetting()
        switch authVM.loginStatus.value {
        case .login: userSetting()
        default: notLoginSetting()
        }
    }
    
    func btnSetting() {
        logoutBtn.layer.cornerRadius = 10
        logoutBtn.layer.borderWidth = 1.5
        logoutBtn.layer.borderColor = myPageMainColor?.cgColor
        
        if authVM.loginStatus.value != .login {
            logoutBtn.setTitle("로그인/회원가입", for: .normal)
        }
    }
    
    /// 로그아웃 버튼 클릭
    /// - Parameter sender: <#sender description#>
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- btn clicked⭐️")
        switch authVM.loginStatus.value {
        case .login:
            authVM.firebaseLogout {
                self.loadView()
                guard let logoutCompletion = self.logoutCompletion else { return }
                logoutCompletion()
            }
        default:
            print(#fileID, #function, #line, "- <#comment#>")
            guard let loginCompletion = loginCompletion else { return }
            loginCompletion()
        }
        
    }
    
    private func userSetting() {
        //        guard let userId = authVM.userId.value else { return }
        print(#fileID, #function, #line, "- userInfo setting checking⭐️: \(userInfo)")
        if let userInfo = userInfo {
            if let userImgUrl = userInfo.profileImg {
                self.profileImg.loadImg(url: userImgUrl)
            } else {
                self.profileImg.image = UIImage(systemName: "person.circle")
                self.profileImg.tintColor = .black
            }
        }
        
        authVM.userNickname
            .subscribe(on: MainScheduler.instance)
            .bind { nickname in
                print(#fileID, #function, #line, "- nickname⭐️: \(nickname)")
                self.nickname.text = nickname
            }.disposed(by: disposeBag)
    }
    
    private func notLoginSetting() {
        let labelText = "로그인 하지 않은 상태입니다. \n로그인/회원가입 후 이용해주세요"
        self.nickname.text = labelText
        self.nickname.font = UIFont.systemFont(ofSize: 14, weight: .light)
        self.nickname.textColor = myPageMainColor
        
        self.profileImg.image = UIImage(systemName: "person.circle")?.withTintColor(myPageMainColor ?? .black, renderingMode: .alwaysOriginal)
    }
}
