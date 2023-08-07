//
//  MypageChangeNicknameViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/08/03.
//

import Foundation
import UIKit

class MypageChangeNicknameViewController: UIViewController {
    let firebaseManage = FirebaseManage.shared
    let authVM = AuthVM.shared
    var userInfo: UserInfo? = nil
    
    @IBOutlet weak var currentNickname: UITextField!
    @IBOutlet weak var newNickname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetting()
    }
    
    func viewSetting() {
        print(#fileID, #function, #line, "- viewSetting")
        guard let userInfo = userInfo else { return }
        currentNickname.text = userInfo.nickName
    }
    
    @IBAction func changeNicknameBtnClicked(_ sender: UIButton) {
        if newNickname.text == "" {
            let alert = UIAlertController()
            let alertAction = UIAlertAction(title: "변경할 닉네임을 입력해주세요", style: .default) { action in
                self.dismiss(animated: false)
            }
            alert.addAction(alertAction)
            self.present(alert, animated: false)
            return
        }
        guard let userId = userInfo?.uid,
              let userNickname = newNickname.text else { return }
        firebaseManage.changeCurrentUserNickname(userId, userNickname) { newNickname in
            self.authVM.userNickname.accept(newNickname)
            self.navigationController?.popViewController(animated: false)
        }
    }
    
}
