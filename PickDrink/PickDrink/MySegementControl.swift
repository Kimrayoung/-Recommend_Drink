//
//  MySegementControl.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/27.
//

import Foundation
import UIKit

public enum segmentControlType {
    case onlyHot
    case onlyIce
    case HotAndIce
}

class MySegmentControl: UISegmentedControl {
    init(_ type: segmentControlType) {
        super.init(frame: CGRect.zero)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
