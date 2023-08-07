//
//  MypageReviewViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/07/26.
//

import Foundation
import UIKit

enum CollectionViewType {
    case review
    case complain
}

class MypageReviewAndComplainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let firebaseManage = FirebaseManage.shared
    let userId = AuthVM.shared.userId.value
    
    var userInfo: UserInfo? = nil
    var collectionViewType: CollectionViewType? = nil
    
    var fetchedReviews: [Review] = []
    var fetchedComplains: [Complain] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ReusableCell.uiNib, forCellWithReuseIdentifier: ReusableCell.reuseIdentifier)
        
        if let collectionViewType = collectionViewType {
            switch collectionViewType {
            case .review: fetchReviewData()
            case .complain: fetchComplainData()
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func fetchReviewData() {
        guard let userInfo = userInfo else { return }
        userInfo.fetchMyReviews { reviews in
            print(#fileID, #function, #line, "- reviews⭐️: \(reviews)")
            self.fetchedReviews = reviews
            self.collectionView.reloadData()
        }
    }
    
    func fetchComplainData() {
        guard let userInfo = userInfo else { return }
        print(#fileID, #function, #line, "- complain data get⭐️")
        userInfo.fetchMyComplain { complains in
            print(#fileID, #function, #line, "- complains⭐️: \(complains)")
            self.fetchedComplains = complains
            self.collectionView.reloadData()
        }
    }
}

extension MypageReviewAndComplainViewController {
    func openModal(_ reviewContent: String, _ modalType: Modal, _ reviewData: Review, _ reviewIndex: Int) {
        print(#fileID, #function, #line, "- reviewComplain")
        guard let modalVC = ModalViewController.getInstance() else { return }
        
//        modalVC.menuId = menuId
        modalVC.reviewIndex = reviewIndex
        modalVC.reviewData = reviewData
        modalVC.modalType = modalType
        modalVC.firstLabelContent = reviewContent
        
        modalVC.editCompletedClosure = { reviewContent, index in
            self.fetchedReviews[index].reviewContent = reviewContent
            let indexPath = IndexPath(row: index, section: 0)
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        modalVC.collectionViewScrollToItem = {
            let menuReviewCnt = self.fetchedReviews.count
            if menuReviewCnt > 1 {
                self.collectionView.scrollToItem(at: IndexPath(item: reviewIndex, section: 0), at: .top, animated: false)
            }
        }

        self.present(modalVC, animated: true)
    }
    
    func deleteReviewData(_ reviewData: Review, _ reviewIndex: Int) {
        firebaseManage.deleteReview(reviewData) { result in
            if result == true {
                print(#fileID, #function, #line, "- 데이터 삭제 성공")
                self.fetchedReviews.remove(at: reviewIndex)
                self.collectionView.reloadData()
            } else {
                print(#fileID, #function, #line, "- 데이터 삭제 실패")
            }
        }
    }
    
    func deleteComplainData(_ complainData: Complain, _ complainIndex: Int) {
        firebaseManage.deleteComplain(complainData) { result in
            if result == true {
                print(#fileID, #function, #line, "- 컴플레인 데이터 삭제 성공")
                self.fetchedComplains.remove(at: complainIndex)
                self.collectionView.reloadData()
            } else {
                print(#fileID, #function, #line, "- 컴플레인 데이터 삭제 실패")
            }
        }
        
    }
}

extension MypageReviewAndComplainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCell.reuseIdentifier, for: indexPath) as? ReusableCell else { return UICollectionViewCell()}
        
        let indexRow = indexPath.row
        switch collectionViewType {
        case .review:
            cell.cellVCType = .mypageReview
            cell.cellData = fetchedReviews[indexRow]
            cell.cellIndex = indexRow
            cell.openModalClosure = openModal(_:_:_:_:)
            cell.reviewDeleteBtnClosure = deleteReviewData(_:_:)
        case .complain:
            cell.cellVCType = .mypageComplain
            cell.cellData = fetchedComplains[indexRow]
            cell.cellIndex = indexRow
            cell.complainDeleteBtnClosure = deleteComplainData(_:_:)
        case .none:
            print(#fileID, #function, #line, "- ")
        }
        
        cell.cellDataSetting()
        cell.cellHiddenDataSetting()

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionViewType {
        case .review:
            if fetchedReviews.isEmpty {
                self.collectionView.setEmptyMessage()
                return 0
            } else {
                self.collectionView.restore()
                return fetchedReviews.count
            }
        case .complain:
            if fetchedComplains.isEmpty {
                self.collectionView.setEmptyMessage()
                return 0
            } else {
                self.collectionView.restore()
                return fetchedComplains.count
            }
        case .none:
            print(#fileID, #function, #line, "- <#comment#>")
            return 0
        } //switch
    }
}

extension MypageReviewAndComplainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#fileID, #function, #line, "- cell 사이즈 지정")
        
        let height = collectionViewType == .review ? 180 : 250
        return CGSizeMake(collectionView.frame.size.width, CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
