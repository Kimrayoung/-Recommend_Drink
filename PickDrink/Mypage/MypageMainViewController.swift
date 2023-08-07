//
//  MypageMainViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/12.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

///마이페이지 화면
class MypageMainViewController: UIViewController{
    let authVM = AuthVM.shared
    let firebaseManage = FirebaseManage.shared
    
    var userInfo: UserInfo? = nil
    
    @IBOutlet weak var appLogo: UILabel!
    
    @IBOutlet weak var userInfoView: MypageLoginView!
    @IBOutlet weak var reviewManageView: UIView!
    @IBOutlet weak var complainManageView: UIView!
    @IBOutlet weak var accountManageView: UIView!
    
    @IBOutlet weak var manageStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoView.loginCompletion = {
            guard let loginVC = MypageLoginViewController.getInstance() else { return }
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        
        userInfoView.logoutCompletion = {
            self.viewSetting()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewSetting()
        viewConnectGestureSetting()
        
        //네비게이션 바 안보이도록 셋팅
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
//
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        viewSetting()
//    }
 
    func viewSetting() {
        print(#fileID, #function, #line, "- viewHiddentSetting loginstatus: \(authVM.loginStatus.value)")
        authVM.loginStatus.withUnretained(self)
            .bind { vc, loginstauts in
                switch loginstauts {
                case .login:
                    self.reviewManageView.isHidden = false
                    self.complainManageView.isHidden = false
                    self.accountManageView.isHidden = false

                    if let userId = self.authVM.userId.value {
                        self.firebaseManage.fetchCurrentUser(userId) { userInfo in
                            guard let userInfo = userInfo else { return }
                            self.userInfo = userInfo
                            self.userInfoView.userInfo = userInfo
                            self.userInfoView.loadView()
                        }
                    }
                    
                default:
                    self.reviewManageView.isHidden = true
                    self.complainManageView.isHidden = true
                    self.accountManageView.isHidden = true
                    
                    self.userInfoView.loadView()
                }
            }.dispose()
    }

    //MARK: - 각 view에 제스처 설정
    func viewConnectGestureSetting() {
        let reviewGesture = UITapGestureRecognizer(target: self, action: #selector(self.moveToReviewManageVC(_ :)))
        self.reviewManageView.addGestureRecognizer(reviewGesture)
        
        let complainGesture = UITapGestureRecognizer(target: self, action: #selector(self.moveToComplainManageVC(_:)))
        self.complainManageView.addGestureRecognizer(complainGesture)
        
        let accountGesture = UITapGestureRecognizer(target: self, action: #selector(self.moveToAccountManageVC(_:)))
        self.accountManageView.addGestureRecognizer(accountGesture)
    }
        
    //MARK: - review관리 화면으로 이동
    @objc func moveToReviewManageVC(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- <#comment#>")
        guard let mypageReviewAndComplainVC = MypageReviewAndComplainViewController.getInstance() else { return }
        
        mypageReviewAndComplainVC.userInfo = self.userInfo
        mypageReviewAndComplainVC.collectionViewType = .review
        
        self.navigationController?.pushViewController(mypageReviewAndComplainVC, animated: true)
    }
    
    //MARK: - 컴플레인 관리 화면으로 이동
    @objc func moveToComplainManageVC(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- <#comment#>")
        guard let mypageReviewAndComplainVC = MypageReviewAndComplainViewController.getInstance() else { return }
        
        mypageReviewAndComplainVC.userInfo = self.userInfo
        mypageReviewAndComplainVC.collectionViewType = .complain
        
        self.navigationController?.pushViewController(mypageReviewAndComplainVC, animated: true)
    }
    
    //MARK: - 계정관리 화면으로 이동
    @objc func moveToAccountManageVC(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- <#comment#>")
        guard let mypageAccountVC = MypageAccountViewController.getInstance() else { return }
        
        mypageAccountVC.userInfo = self.userInfo
        self.navigationController?.pushViewController(mypageAccountVC, animated: true)
    }
    
    
    
}
