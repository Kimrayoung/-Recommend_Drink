//
//  MyStackBtn.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/22.
//

import Foundation
import UIKit

//다른 곳에서도 사용할 수 있도록 public으로 선언
public enum btnType {
    case drinkList
    case recommandList
    case nutritionList
}

class MyStackBtn: UIButton {
    init(_ btnTitle: String, _ type: btnType, _ tag: Int) {
        super.init(frame: CGRect.zero)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        self.layer.cornerRadius = 10
        
        self.setTitle(btnTitle, for: .normal)
        self.tag = tag
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 90),
            self.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        //어떤 화면인지에 따라서 버튼의 배경색이 달라짐
        switch type {
        case .drinkList:
            self.setTitleColor(.white, for: .normal)
            if self.tag == 0 {
                self.backgroundColor = UIColor(named: "cafeListSelectedBtnColor")
            } else {
                self.backgroundColor = UIColor(named: "cafeListBtnColor")
            }
        case .recommandList:
            self.setTitleColor(.black, for: .normal)
            if self.tag == 0 {
                self.backgroundColor = UIColor(named: "recommandSelectedBtnColor")
            } else {
                self.backgroundColor = UIColor(named: "recommandBtnColor")
            }
        case .nutritionList:
            self.setTitleColor(.black, for: .normal)
            if self.tag == 0 {
                self.backgroundColor = UIColor(named: "NutritionSizeBtnSelectedColor")
            } else {
                self.backgroundColor = UIColor(named: "NutritionSizeBtnColor")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
