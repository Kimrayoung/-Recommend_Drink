//
//  MypageAccountViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/08/01.
//

import Foundation
import UIKit

class MypageAccountViewController: UIViewController {
    let authVM = AuthVM.shared
    let firebaseManage = FirebaseManage.shared
    
    var userInfo: UserInfo? = nil
    
    @IBOutlet weak var nicknameChangeView: UIView!
    @IBOutlet weak var loginPlatformImg: UIImageView!
    @IBOutlet weak var deleteUserView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch authVM.loginPlatform.value {
        case .apple:
            loginPlatformImg.image = UIImage(named: "appleLogo")
        case .kakao:
            loginPlatformImg.image = UIImage(named: "kakaoLogo")
        default: return
        }
        
        viewConnectGestureSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func viewConnectGestureSetting() {
        let nicknameChangeViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.moveToNicknameChangeVC(_ :)))
        self.nicknameChangeView.addGestureRecognizer(nicknameChangeViewGesture)
        
        let deleteUserViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.deleteUser(_:)))
        self.deleteUserView.addGestureRecognizer(deleteUserViewGesture)
    }
    
    @objc func moveToNicknameChangeVC(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- <#comment#>")
        guard let nicknameChangeVC = MypageChangeNicknameViewController.getInstance() else { return }
        
        nicknameChangeVC.userInfo = userInfo
        self.navigationController?.pushViewController(nicknameChangeVC, animated: false)
    }
    
    @objc func deleteUser(_ sender: UIButton) {
        print(#fileID, #function, #line, "- 회원탈퇴 클릭⭐️")
        guard let userInfo = userInfo else { return }
        let alert = UIAlertController(title: "회원탈퇴 확인", message: "정말 회원을 탈퇴하시겠습니까? \n작성하신 리뷰와 컴플레인은 모두 삭제됩니다", preferredStyle: .alert)
        
        let yesAlertAction = UIAlertAction(title: "확인", style: .default) { action in
            guard let loginPlatform = self.authVM.loginPlatform.value else { return }
            
            switch loginPlatform {
            case .apple:
                self.authVM.appleLoginDeleteUser()
            case .kakao:
                self.authVM.kakaoUnLink()
            }
        }
        
        let cancelAlertAction = UIAlertAction(title: "취소", style: .cancel) { action in
            self.navigationController?.popViewController(animated: false)
        }
        
        alert.addAction(yesAlertAction)
        alert.addAction(cancelAlertAction)
        
        self.present(alert, animated: true, completion: nil)
        
        self.authVM.deleteUserCompletion = {
            self.firebaseManage.deleteUserInfo(userInfo)
            guard let navigationController = self.navigationController else { return }
            var navigationArray = navigationController.viewControllers
            let temp = navigationArray.first
            navigationArray.removeAll()
            navigationArray.append(temp!)
            self.navigationController?.viewControllers = navigationArray
        }
       
    
    }
    
}
