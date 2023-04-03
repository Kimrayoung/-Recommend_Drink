//
//  ReviewTableViewCell.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/27.
//

import Foundation
import UIKit

class ReviewCell: UICollectionViewCell {
    
    @IBOutlet weak var reviewStarImageView: UIImageView!
    @IBOutlet weak var reviewContentLabel: UILabel!
    @IBOutlet weak var reviewEditBtn: UIButton!
    @IBOutlet weak var reviewDeleteLabel: UIButton!
    @IBOutlet weak var reviewComplainBtn: UIButton!
    
    var reviewCompainBtnClosure: ((_ reviewContent: String, _ modalType: modal) -> ())? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reviewComplainBtn.addTarget(self, action: #selector(reviewComplainBtnClicked(_:)), for: .touchUpInside)
    }
    
    @objc private func reviewComplainBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- reviewComplainBtnClicked");
        //cell이 present를 해주는 것이 아니라 cell이 포함된 ViewController가 해당 모달을 열도록 해야 한다
        guard let reviewContent = reviewContentLabel.text,
              let reviewCompainBtnClosure = reviewCompainBtnClosure else { return }
        reviewCompainBtnClosure(reviewContent, .complain)
    }
}
