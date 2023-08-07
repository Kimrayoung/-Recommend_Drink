//
//  ReviewTableViewCell.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/27.
//

import Foundation
import UIKit

enum CellVCType {
    case mypageReview
    case menuDetailReview
    case mypageComplain
}

/// 리뷰 collection에 들어갈 cell
class ReusableCell: UICollectionViewCell {
    var firebaseManage = FirebaseManage.shared
    var cellVCType: CellVCType? = nil
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cafeAndMenuLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var complainTargetReview: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var complainBtn: UIButton!
    @IBOutlet weak var userNickname: UILabel!

    var cellData: Any? = nil
    var cellIndex: Int? = nil
    
    var reviewComplainBtnClosure: ((_ reviewContent: String, _ modalType: Modal, _ reviewData: Review, _ reviewIndex: Int) -> ())? = nil
    
    var reviewDeleteBtnClosure: ((_ reviewData: Review, _ reviewIndex: Int) -> ())? = nil
    var complainDeleteBtnClosure: ((_ complainData: Complain, _ complainIndex: Int) -> ())? = nil
    
    var openModalClosure: ((_ reviewContent: String, _ modalType: Modal, _ reviewData: Review, _ reviewIndex: Int) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        cellView.backgroundColor = UIColor(named: "reviewPlaceHolderColor")
        complainBtn.addTarget(self, action: #selector(complainBtnClicked(_:)), for: .touchUpInside)
        
        editBtn.addTarget(self, action: #selector(editBtnClicked(_:)), for: .touchUpInside)
        
        deleteBtn.addTarget(self, action: #selector(deleteBtnClicked(_:)), for: .touchUpInside)
    }
    
    //MARK: - cell에 데이터 넣어주기
    func cellDataSetting() {
        if let cellData = cellData as? Review {
            guard let starImg = UIImage(named: cellData.reviewStar ?? "fivestars") else { return }
            starImageView.image = starImg
            contentLabel.text = cellData.reviewContent ?? "없음"
            
            if cellVCType == .menuDetailReview {
                self.userNickname.text = cellData.userNickname ?? "없음"
            } else if cellVCType == .mypageReview {
                self.userNickname.text = cellData.userNickname ?? "없음"
                self.cafeAndMenuLabel.text = cellData.menuName ?? "없음"
            }
        } else if let cellData = cellData as? Complain {
            cafeAndMenuLabel.text = "신고메뉴: \(cellData.menuName ?? "없음")"
            complainTargetReview.text = "신고 리뷰: \(cellData.complainReview ?? "없음")"
            contentLabel.text = "신고 내용: \(cellData.complainReason ?? "없음")"
        }
    }
    
    //MARK: - 수정, 삭제, 신고, 닉네임 hidden 설정
    // 마이페이지일 경우 ->  닉네임 라벨 보이지 않음
    // 메뉴 디테일 화면일 경우 -> 수정, 삭제 버튼 보이지 않음
    func cellHiddenDataSetting() {
        print(#fileID, #function, #line, "- reviewTableViewCell type check⭐️: \(String(describing: self.cellVCType))")
        
        if let cellType = self.cellVCType {
            switch cellType {
            case .menuDetailReview:
                self.cafeAndMenuLabel.isHidden = true
                self.complainTargetReview.isHidden = true
                self.editBtn.isHidden = true
                self.deleteBtn.isHidden = true
            case .mypageReview:
                self.complainTargetReview.isHidden = true
                self.userNickname.isHidden = true
                self.complainBtn.isHidden = true
            case .mypageComplain:
                self.userNickname.isHidden = true
                self.starImageView.isHidden = true
                self.editBtn.isHidden = true
                self.complainBtn.isHidden = true
            }
        }
    }
    
    //MARK: - 신고하기 버튼 클릭
    //modal로 이동
    @objc private func complainBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewComplainBtnClicked");
        //cell이 present를 해주는 것이 아니라 cell이 포함된 ViewController가 해당 모달을 열도록 해야 한다
        guard let reviewContent = contentLabel.text,
              let reviewComplainBtnClosure = reviewComplainBtnClosure,
              let reviewIndex = cellIndex,
              let reviewData = cellData as? Review else { return }
        
        reviewComplainBtnClosure(reviewContent, .complain, reviewData, reviewIndex)
    }
    
    //MARK: - 수정하기 버튼 클릭
    //modal로 이동
    @objc private func editBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewEditBtn")
        
        guard let openModalClosure = openModalClosure,
              let reviewContent = contentLabel.text,
              let reviewIndex = cellIndex,
              let reviewData = cellData as? Review else { return }
        
        openModalClosure(reviewContent, .editReview, reviewData, reviewIndex)
    }
    
    @objc private func deleteBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewDeleteBtn")
        
        if let reviewData = cellData as? Review {
            print(#fileID, #function, #line, "- review Data로 파싱")
            guard let reviewDeleteBtnClosure = reviewDeleteBtnClosure,
                  let index = cellIndex else { return }
            reviewDeleteBtnClosure(reviewData, index)
        } else if let complainData = cellData as? Complain {
            print(#fileID, #function, #line, "- complain Data로 파싱")
            guard let complainDeleteBtnClosure = complainDeleteBtnClosure,
                  let index = cellIndex else { return }
            complainDeleteBtnClosure(complainData, index)
        }
        
    }
    
}
