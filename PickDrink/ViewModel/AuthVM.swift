//
//  AuthVM.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/12.
//

import Foundation
import UIKit
import Security
import AuthenticationServices
import RxSwift
import RxRelay
import RxCocoa
import FirebaseAuth
import FirebaseAppCheck
import CryptoKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

///로그인 혹은 회원가입 관리
class AuthVM: NSObject {
    static let shared = AuthVM()
    
    let firebaseManage = FirebaseManage.shared
    
    var loginPlatform : BehaviorRelay<LoginPlatform?> = BehaviorRelay(value: nil)
    
    var loginStatus: BehaviorRelay<LoginStatus> = BehaviorRelay(value: .logout)
    var userId: BehaviorRelay<String?> = BehaviorRelay(value: "")
    let userNickname: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var deleteUserCompletion: (() -> ())? = nil
    
    private override init() {
        super.init()
    }
    
    //MARK: - 카카오 로그인
    func handleKakaoLogin() {
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            kakaoLoginWithKakaoTalk()
        }
        else {
            kakaoLoginWithKakaoAccount()
        }
    }
    
    //MARK: - ID토큰이 명시적으로 부여되었는지 확인
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        //nonce생성
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    //MARK: - nonce를 hash하는 코드
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    //MARK: - 애플 로그인 시작
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        print(#fileID, #function, #line, "- 애플 로그인 시작🍎")
        loginPlatform.accept(.apple)
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest() //request만들기
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    //MARK: - 로그인 없이 진행
    func notLogin() {
        loginPlatform.accept(.none)
        loginStatus.accept(.logout)
    }
}

//MARK: - 카카오 로그인 관련
extension AuthVM {
    //MARK: - 카카오 로그인 여부 체크(즉, 토큰에 접근할 수 있는지)
    func kakaoTokenAccessChecking() {
        loginPlatform.accept(.kakao)
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { [weak self] (_, error) in
                guard let self = self else { return }
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        self.handleKakaoLogin()
                    }
                    else {
                        //기타 에러
                        print(#fileID, #function, #line, "- 기타 error: \(error)")
                        self.loginStatus.accept(.loginFail)
                    }
                }
                //토큰 있음
                else {
                    self.kakaoUserInfoWithFirebaseLogin()
                }
            }
        }
        else {
            handleKakaoLogin()
        }
    }
    
    //MARK: - 카카오톡 앱으로 로그인
    func kakaoLoginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk {[weak self] (oauthToken, error) in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- 카카오톡 앱으로 로그인 error⭐️: \(error.localizedDescription)")
                self.loginStatus.accept(.loginFail)
            }
            else {
                print(#fileID, #function, #line, "- 카카오톡 앱으로 로그인 success⭐️")

                //do something
                _ = oauthToken
                self.kakaoUserInfoWithFirebaseLogin()
            }
        }
    } //kakaoLoginWithKakaoTalk

    //MARK: - 카카오 계정으로 로그인
    func kakaoLoginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount {[weak self] (oauthToken, error) in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- 카카오 계정으로 로그인 error⭐️: \(error.localizedDescription)")
                self.loginStatus.accept(.loginFail)
            }
            else {
                print(#fileID, #function, #line, "- 카카오 계정으로 로그인 success⭐️")

                //do something
                _ = oauthToken
                self.kakaoUserInfoWithFirebaseLogin()
            }
        }
    } //kakaoLoginWithKaKaoAccount
    
    //MARK: - 카카오 로그아웃
    func kakaoLogout() {
        UserApi.shared.logout { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- 카카오 로그아웃 error⭐️: \(error.localizedDescription)")
                self.loginStatus.accept(.logoutFail)
            }
            else {
                print(#fileID, #function, #line, "- 카카오 로그아웃 success⭐️")
                self.firebaseLogout(nil)
            }
        }
    }
    
    //MARK: - 카카오 회원탈퇴
    func kakaoUnLink() {
        UserApi.shared.unlink { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- 카카오 회원탈퇴 error⭐️: \(error.localizedDescription)")
                self.loginStatus.accept(.logoutFail)
            }
            else {
                print(#fileID, #function, #line, "- 카카오 회원탈퇴 success⭐️")
                self.firebaseUserDelete()
            }
        }
    }
}

//MARK: - 애플 로그인 관련
extension AuthVM: ASAuthorizationControllerDelegate {
    //MARK: - 애플 로그인 성공
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print(#fileID, #function, #line, "- 애플 로그인 성공🍎")
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let userID = appleIDCredential.user
            let userEmail = appleIDCredential.email ?? "이메일 제공안함"
            guard let fullName = appleIDCredential.fullName else { return }
            let userName = (fullName.familyName ?? "") + (fullName.givenName ?? "없음")
            print(#fileID, #function, #line, "- fullName⭐️: \(appleIDCredential.fullName)")
            let appleUserInfo = UserInfo(uid: userID, email: userEmail, nickName: userName, profileImg: nil, reviews: [], complains: [])
            
            self.userId.accept(userID)
//            userInfo.accept(appleUserInfo)
            print(#fileID, #function, #line, "- apple User Info🍎 - \(String(describing: self.userId.value))")

            //Firebase에 Apple Login 인증 정보를 설정
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // authorization Code to Unregister! => get user authorizationCode when login.
            if let authorizationCode = appleIDCredential.authorizationCode, let codeString = String(data: authorizationCode, encoding: .utf8) {
                print(#fileID, #function, #line, "- codeString🔥: \(codeString)")
                
                let url = URL(string: "https://us-central1-pickdrink-492de.cloudfunctions.net/getRefreshToken?code=\(codeString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com")!
                
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    print(#fileID, #function, #line, "- error🔥: \(String(describing: error?.localizedDescription))")
                    if let data = data {
                        print(#fileID, #function, #line, "- data🔥: \(data)")
                        let refreshToken = String(data: data, encoding: .utf8) ?? "token parsing 실패"
                        print(#fileID, #function, #line, "- refreshToken checking🔥: \(refreshToken)")
 
                        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                        UserDefaults.standard.synchronize()
                    }
                }
                task.resume()
            }
            
            appleWithFirebaseLogin(credential, appleUserInfo)
        }
    }//authorizationController 성공
    
    //MARK: - 애플 로그인 실패
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    //MARK: - 애플 로그인 회원 탈퇴
    func appleLoginDeleteUser() {
        let token = UserDefaults.standard.string(forKey: "refreshToken")
        print(#fileID, #function, #line, "- token checking⭐️: \(token)")
        //token으로 데이터 삭제
        if let token = token {
            let url = URL(string: "https://us-central1-pickdrink-492de.cloudfunctions.net/revokeToken?refresh_token=\(token)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "https://apple.com")!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard data != nil else { return }
                print(#fileID, #function, #line, "- revoke token error🔥: \(error?.localizedDescription)")
                print(#fileID, #function, #line, "- revokeToken response checking🔥: \(response)")
                
            }
            task.resume()
        }
        print(#fileID, #function, #line, "- revokeToken success⭐️")
        // Delete other information from the database...
        
        print(#fileID, #function, #line, "- firebase 계정탈퇴시도🔥")
        firebaseUserDelete()
    }
}

//MARK: - firebase 로그인 관련
extension AuthVM {
    //MARK: - 카카오 유저 정보 가져와서 파이어베이스 로그인
    func kakaoUserInfoWithFirebaseLogin() {
        UserApi.shared.me() { [weak self] (user, error) in
            guard let self = self else { return }
            if let error = error {
                print(error)
            }
            else {
                //do something
                guard let kakaoIdInt = user?.id,
                      let kakaoNickname = user?.kakaoAccount?.profile?.nickname,
                      let kakaoProfileImg = user?.kakaoAccount?.profile?.profileImageUrl,
                      let kakaoEmail = user?.kakaoAccount?.email else { return }
                
                let kakaoId = String(describing: kakaoIdInt)
                
                let kakaoUserInfo = UserInfo(uid: kakaoId, email: kakaoEmail, nickName: kakaoNickname, profileImg: kakaoProfileImg, reviews: [], complains: [])
                
                self.userId.accept(kakaoId)
                
                //MARK: - firebase로그인(firebase 회원 여부 체크 후 로그인)
                print(#fileID, #function, #line, "- kakaoEmail checking🔥: \(kakaoEmail)")
                print(#fileID, #function, #line, "- password checking🔥: \(kakaoId)")
                Auth.auth().createUser(withEmail: kakaoEmail, password: kakaoId) { authResult, error in
                    if let error = error {
                        print(#fileID, #function, #line, "- firebase Login fail🔥: \(error)")
                        Auth.auth().signIn(withEmail: kakaoEmail, password: kakaoId) { result, error in
                            if let error = error {
                                print(#fileID, #function, #line, "- firebase 로그인 에러🔥: \(error)")
                                self.loginStatus.accept(.loginFail)
                            } else {
                                print(#fileID, #function, #line, "- firebase 로그인 성공⭐️")
                                self.loginStatus.accept(.login)
                                guard let userId = self.userId.value else { return }
                                self.firebaseManage.fetchCurrentUser(userId) { info in
                                    guard let info = info else { return }
                                    self.userNickname.accept(info.nickName ?? "없음")
                                }
                            }
                        } //로그인
                        
                    } else { //회원가입
                        print(#fileID, #function, #line, "- firebase Login success: \(String(describing: authResult))")
                        self.userNickname.accept(kakaoUserInfo.nickName ?? "")
                        self.updateFirebaseUser(kakaoNickname, kakaoProfileImg)
                        self.loginStatus.accept(.login)
                        self.firebaseManage.makeFirebaseUserDoc(kakaoUserInfo) //fireStore에 User정보 만들어주기
                    }
                }
            }
        }
    } //kakaoUserInfoWithFirebaseLogin
    
    //MARK: - 애플 유저 정보로 firebase 로그인
    func appleWithFirebaseLogin(_ credential: OAuthCredential, _ userInfo: UserInfo) {
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- firebase Loing error🔥: \(error.localizedDescription)")
                return
            }
            //로그인 성공
            print(#fileID, #function, #line, "- firebase 로그인 성공🔥")
            self.loginStatus.accept(.login)
            firebaseManage.existCheckFirebaseUser(userInfo) { isExist in
                if isExist == true {
                    guard let userId = self.userId.value else { return }
                    self.firebaseManage.fetchCurrentUser(userId) { info in
                        guard let info = info else { return }
                        self.userNickname.accept(info.nickName ?? "없음")
                    }
                } else {
                    self.userNickname.accept(userInfo.nickName ?? "")
                }
            }
            
        }
    }//appleLoginWithFirebaseLogin
    
    //MARK: - 파이어베이스에 user정보 업데이트(프로필 사진, 닉네임)
    func updateFirebaseUser(_ nickName: String, _ profileImg: URL?) {
        guard let user = Auth.auth().currentUser?.createProfileChangeRequest() else { return }
        
        user.displayName = nickName
        if let profileImg = profileImg {
            user.photoURL = profileImg
        }
        
        user.commitChanges { error in
            print(#fileID, #function, #line, "- firebase userInfo update error: \(String(describing: error))")
        }
        
    }
    
    //MARK: - firebase 로그아웃
    func firebaseLogout(_ completion: (() -> ())?) {
        do {
            try Auth.auth().signOut()
            self.loginStatus.accept(.logout)
            if let completion = completion {
                completion()
            }
        } catch {
            print(#fileID, #function, #line, "- firebase logout error: \(error.localizedDescription)")
            self.loginStatus.accept(.logoutFail)
        }
    }
    
    //MARK: - firebase 회원탈퇴
    func firebaseUserDelete() {
        let user = Auth.auth().currentUser
        
        user?.delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print(#fileID, #function, #line, "- firebase user 탈퇴 error: \(error)")
                self.loginStatus.accept(.logoutFail)
            } else {
                print(#fileID, #function, #line, "- firebase user 탈퇴 success")
                self.loginStatus.accept(.logout)
                guard let deleteUserCompletion = deleteUserCompletion else { return }
                deleteUserCompletion()
            }
        }
    }
}
