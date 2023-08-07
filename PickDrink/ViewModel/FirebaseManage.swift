//
//  FirebaseUserAndReviewManage.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseManage {
    static let shared = FirebaseManage()
    
    let userRef = Firestore.firestore().collection("User")
    let reviewRef = Firestore.firestore().collection("reviews")
    let complainRef = Firestore.firestore().collection("complains")
    
    //MARK: - 로그인한 유저가 fireStore에 Doc을 가지고 있는지
    func existCheckFirebaseUser(_ userInfo: UserInfo, _ completion: @escaping (Bool) -> ()) {
        let userId = userInfo.uid
        userRef.document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                print(#fileID, #function, #line, "- userId: \(userId)'s userDocument exist⭐️")
                completion(true)
                return
            } else {
                print("Document does not exist⭐️")
                completion(false)
                self.makeFirebaseUserDoc(userInfo)
            }
        }
    }
    
    //MARK: - 로그인한 유저 정보를 firestore에 넣어줌
    func makeFirebaseUserDoc(_ userInfo: UserInfo) {
        print(#fileID, #function, #line, "- 로그인한 유저정보 firebase에 넣어주기")
        let userId = userInfo.uid
        do {
            try userRef.document(userId).setData(from: userInfo)
        } catch let error {
            print(#fileID, #function, #line, "- error writing user to firestore: \(error.localizedDescription)")
        }
    }
    
    
    /// 유저정보 가지고 오기
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - completion: <#completion description#>
    func fetchCurrentUser(_ userId: String, _ completion: @escaping (UserInfo?) -> ()) {
        userRef.document(userId).getDocument { snapShot, error in
            if let error = error {
                print(#fileID, #function, #line, "- get user Document error: \(error.localizedDescription)")
                return
            }
            
            guard let snapShot = snapShot else { return }
            let fetchedUser = try? snapShot.data(as: UserInfo.self)
            completion(fetchedUser)
        }
    }
    
    func existUserNicknameChecking(_ userNickname: String, _ completion: @escaping (Bool) -> ()) {
        userRef.whereField("nickname", isEqualTo: userNickname)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print(#fileID, #function, #line, "- get doc error: \(error.localizedDescription)")
                } else {
                    guard let querySnapshot = querySnapshot else { return }
                    querySnapshot.count > 0 ? completion(false) : completion(true)
                }
            }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - userId: <#userId description#>
    ///   - userNickname: <#userNickname description#>
    ///   - completion: <#completion description#>
    func changeCurrentUserNickname(_ userId: String, _ userNickname: String, _ completion: @escaping (String) -> ()) {
        userRef.document(userId).updateData([
            "nickName" : userNickname
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                completion(userNickname)
            }
        }
        
        reviewRef.whereField("user_id", isEqualTo: userId).getDocuments { querySnapshot, error in
            let batch = Firestore.firestore().batch()
            if let error = error {
                print(#fileID, #function, #line, "- get review doc error: \(error.localizedDescription)")
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                print(#fileID, #function, #line, "- get snapshot error")
                return
            }
            print(#fileID, #function, #line, "- querySnapshot count: \(querySnapshot.count)")
            querySnapshot.documents.forEach { queryDocSnapshot in
                print(#fileID, #function, #line, "- queryDoc ID: \(queryDocSnapshot.documentID)")
                let docRef = self.reviewRef.document(queryDocSnapshot.documentID)
                batch.updateData(["user_nickname" : userNickname], forDocument: docRef)
            }
            
            batch.commit { error in
                if let error = error {
                    print(#fileID, #function, #line, "- error writing batch: \(error.localizedDescription)")
                } else {
                    print(#fileID, #function, #line, "- batch success")
                }
            }
        }
        
    }
    
    func fetchMenuInfo(_ cafeId: String, _ menuId: String, _ completion: @escaping (MenuDetail?) -> Void) {
        let menuRef = Firestore.firestore().collection(cafeId).document(menuId)
        menuRef.getDocument(completion: { (document, error) in
            if let document = document, document.exists {
                if let menuDetailData = try? document.data(as: MenuDetail.self) {
                    print(#fileID, #function, #line, "- menuDetail data⭐️:\(menuDetailData)")
                    completion(menuDetailData)
                } else {
                    print(#fileID, #function, #line, "- MenuDetail로 데이터 파싱 실패")
                }
            } else {
                print("Document does not exist")
            }
        })
    }
    
    func fetchReviewsInMenuDetail(_ menuId: String, _ completion: @escaping ([Review]?) -> Void){
        var fetchReviews: [Review] = []
        print(#fileID, #function, #line, "- starbucks review menuId check⭐️: \(menuId)")
        reviewRef.whereField("menu_id", isEqualTo: menuId).limit(to: 2)
            .getDocuments { snapShot, error in
                if let error = error {
                    print(#fileID, #function, #line, "- firebase get field menuReview error⭐️: \(error.localizedDescription)")
                } else {
                    for doc in snapShot!.documents {
                        if let docParsing = try? doc.data(as: Review.self) {
                            print(#fileID, #function, #line, "- doc after Parsing data all⭐️: \(docParsing)")
                            fetchReviews.append(docParsing)
                        }
                    } //doc for loop
                    completion(fetchReviews)
                }
            } //getDocument
    }
    
    func fetchReviewsAll(_ menuId: String, _ completion: @escaping ([Review]?) -> Void){
        var fetchReviews: [Review] = []
        reviewRef.whereField("menu_id", isEqualTo: menuId)
            .getDocuments { snapShot, error in
                if let error = error {
                    print(#fileID, #function, #line, "- firebase get field menuReview error⭐️: \(error.localizedDescription)")
                } else {
                    for doc in snapShot!.documents {
                        if let docParsing = try? doc.data(as: Review.self) {
                            print(#fileID, #function, #line, "- doc after Parsing data all⭐️: \(docParsing)")
                            fetchReviews.append(docParsing)
                        }
                    } //doc for loop
                    completion(fetchReviews)
                }
            } //getDocument
    }
    
    func sendReview(_ userId:String, _ review: Review, _ completion: @escaping () -> ()) {
        print(#fileID, #function, #line, "- sendReview⭐️")
        guard let reviewId = review.reviewId else { return }
        do {
            try reviewRef.document(reviewId).setData(from: review)
            completion()
        } catch let error {
            print("Error writing demo_reviews to Firestore🥺: \(error)")
        }
        
        let reviewDocRef = Firestore.firestore().document("reviews/\(reviewId)")
        userRef.document(userId).updateData(["reviews": FieldValue.arrayUnion([reviewDocRef])])
    }
    
    func editReview(_ reviewId: String, _ reviewContent: String, _ completion: @escaping () -> ()) {
        reviewRef.document(reviewId).updateData([
            "review_content" : reviewContent
        ]) { err in
            if let err = err {
                print(#fileID, #function, #line, "- review edit error⭐️: \(err.localizedDescription)")
            } else {
                print(#fileID, #function, #line, "- review edit success🔥")
                completion()
            }
        }
    }
    
    func deleteReview(_ review: Review, _ completion: @escaping (Bool) -> ()) {
        guard let reviewId = review.reviewId,
              let userId = review.userId else { return }
        
        //review collection의 문서 삭제
        reviewRef.document(reviewId).delete { error in
            if let error = error {
                print(#fileID, #function, #line, "- review delete error: \(error.localizedDescription)")
                completion(false)
            } else {
                print(#fileID, #function, #line, "- review delete success⭐️")
            }
        } //reviewRef.document.delete()
        
        //userRef의 reference삭제
        userRef.document(userId).updateData([
            "reviews": FieldValue.arrayRemove([reviewId])
        ])
        completion(true)
    }
    
    
    /// 리뷰 신고
    /// - Parameters:
    ///   - complainContent: 신고한 내용
    ///   - reviewData: 어떤 리뷰에 대해서 신고하는 건지
    func sendComplain(_ complainContent: String, _ reviewData: Review, _ userId: String, _ completion: () -> ()) {
        let complainId = UUID().uuidString
        let complain: Complain = Complain(complainId: complainId, menuId: reviewData.menuId, complainReview: reviewData.reviewContent, complainReason: complainContent, reviewId: reviewData.reviewId, menuName: reviewData.menuName, userId: userId)
        
        do {
            try complainRef.document(complainId).setData(from: complain)
        } catch let error {
            print("Error writing demo_reviews to Firestore🥺: \(error)")
        }
        
        let complainDocRef = Firestore.firestore().document("complains/\(complainId)")
        userRef.document(userId).updateData(["complains": FieldValue.arrayUnion([complainDocRef])])
        completion()
    }
    
    func deleteComplain(_ complain: Complain, _ completion: @escaping (Bool) -> ()) {
        guard let complainId = complain.complainId,
              let userId = complain.userId else { return }
        
        complainRef.document(complainId).delete { error in
            if let error = error {
                print(#fileID, #function, #line, "- complain delte error: \(error.localizedDescription)")
                completion(false)
            } else {
                print(#fileID, #function, #line, "- complain delte success😀")
            }
        }
        
        userRef.document(userId).updateData([
            "complains": FieldValue.arrayRemove([complainId])
        ])
        completion(true)
    }
    
    //유저 삭제하는 부분 필요
    func deleteUserInfo(_ userInfo: UserInfo) {
        print(#fileID, #function, #line, "- 유저 정보 전체 삭제")
        let userId = userInfo.uid
        let reviewRef = userInfo.reviews
        let complainRef = userInfo.complains
        
        reviewRef?.forEach({ ref in
            ref.delete { error in
                if let error = error {
                    print(#fileID, #function, #line, "- ref review delete error: \(error.localizedDescription)")
                } else {
                    print(#fileID, #function, #line, "- review Ref delete success⭐️")
                }
            }
        })
        
        complainRef?.forEach({ ref in
            ref.delete { error in
                if let error = error {
                    print(#fileID, #function, #line, "- complain ref delete error: \(error.localizedDescription)")
                } else {
                    print(#fileID, #function, #line, "- complain ref delete success⭐️")
                }
            }
        })
        
        userRef.document(userId).delete { error in
            if let error = error {
                print(#fileID, #function, #line, "- deleteUser error: \(error.localizedDescription)")
            } else {
                print(#fileID, #function, #line, "- delete user success⭐️")
            }
        }
    }

}
