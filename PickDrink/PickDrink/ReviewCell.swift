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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
