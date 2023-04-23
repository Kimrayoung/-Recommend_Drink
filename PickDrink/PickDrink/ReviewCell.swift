//
//  ReviewTableViewCell.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/27.
//

import Foundation
import UIKit

/// 리뷰 collection에 들어갈 cell
class ReviewCell: UICollectionViewCell {
    
    @IBOutlet weak var reviewStarImageView: UIImageView!
    @IBOutlet weak var reviewContentLabel: UILabel!
    @IBOutlet weak var reviewEditBtn: UIButton!
    @IBOutlet weak var reviewDeleteBtn: UIButton!
    @IBOutlet weak var reviewComplainBtn: UIButton!
    var reviewPassword: String? = nil
    
    var reviewCompainBtnClosure: ((_ reviewContent: String, _ modalType: Modal) -> ())? = nil
    var reviewEditBtnClosure: ((_ reviewContent: String, _ modalType: Modal, _ reviewPassword: String) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewComplainBtn.addTarget(self, action: #selector(reviewComplainBtnClicked(_:)), for: .touchUpInside)
        
        reviewEditBtn.addTarget(self, action: #selector(reviewEditBtnClicked(_:)), for: .touchUpInside)
    }
    
    //MARK: - 리뷰 신고하기 버튼 클릭
    @objc private func reviewComplainBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewComplainBtnClicked");
        //cell이 present를 해주는 것이 아니라 cell이 포함된 ViewController가 해당 모달을 열도록 해야 한다
        guard let reviewContent = reviewContentLabel.text,
              let reviewCompainBtnClosure = reviewCompainBtnClosure else { return }
        reviewCompainBtnClosure(reviewContent, .complain)
    }
    
    //MARK: - 리뷰 수정하기 버튼 클릭
    //1. alert창이 뜬다
    //2. alert창에서 비밀번호를 체크한다
    //3-1. alert창에서 입력한 비빌번호가 맞다면 modal화면으로 이동한다
    //3-2. alert창에서 입력한 비빌번호가 틀리다면 hidden이었던 label이 보인다
    @objc private func reviewEditBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewEditBtn")
        guard let reviewEditBtnClosure = reviewEditBtnClosure,
              let reviewContent = reviewContentLabel.text,
              let reviewPassword = reviewPassword
        else { return }
        reviewEditBtnClosure(reviewContent, .editReview, reviewPassword)
    }
    
}
