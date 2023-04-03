//
//  NutritionViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/28.
//

import Foundation
import UIKit

class NutritionViewController: UIViewController {
    let stackBtnList : [[String]] = [["Tall", "355ml"], ["Grande", "473ml"],["Venti", "591ml"]]
    var nutrition: Nutrition? = nil
    
    @IBOutlet weak var sizeStackView: UIStackView!
    @IBOutlet weak var menuName: UILabel!
    var tempMenuName: String? = nil
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nutritionStack: UIStackView!
    
    @IBOutlet weak var calorieGramLabel: UILabel!
    @IBOutlet weak var caffeineGramLabel: UILabel!
    @IBOutlet weak var saturatedfatGramLabel: UILabel!
    @IBOutlet weak var carbohydrateGramLabel: UILabel!
    @IBOutlet weak var sugarsGramLabel: UILabel!
    @IBOutlet weak var saltGramLabel: UILabel!
    @IBOutlet weak var proteinGramLabel: UILabel!
    @IBOutlet weak var fatGramLabel: UILabel!
    @IBOutlet weak var cholesterolGramLabel: UILabel!
    @IBOutlet weak var transfatGramLabel: UILabel!
    
    @IBOutlet weak var complainBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuName.text = tempMenuName ?? "없음"
        sizeSetting()
        ingredientSetting()
        complainBtn.addTarget(self, action: #selector(wrongContentBtnClicked(_:)), for: .touchUpInside)
    }
    
    private func sizeSetting() {
        sizeLabel.text = stackBtnList[0][0] + " - " + stackBtnList[0][1]
        for i in 0..<stackBtnList.count {
            let stackBtn = MyStackBtn(stackBtnList[i][0], .nutritionList, i)
            stackBtn.addTarget(self, action: #selector(sizeBtnSelected(_:)), for: .touchUpInside)
            sizeStackView.addArrangedSubview(stackBtn)
        }
        
    }
    
    @objc private func sizeBtnSelected(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        let selectedTag = sender.tag
        sizeLabel.text = stackBtnList[selectedTag][0] + " - " + stackBtnList[selectedTag][1]
        
        sizeStackView.arrangedSubviews.map { btn in
            if btn.tag == selectedTag {
                btn.backgroundColor = UIColor(named: "NutritionSizeBtnSelectedColor")
            } else {
                btn.backgroundColor = UIColor(named: "NutritionSizeBtnColor")
            }
        }
    }
    
    func ingredientSetting() {
        let stackCount = nutritionStack.subviews.count
        print(#fileID, #function, #line, "- nutritionStackView.subviewsCount: \(stackCount)")
        if let nutrition = nutrition {
            calorieGramLabel.text = nutrition.calorie != nil ? String(nutrition.calorie!) + "kcal" : "정보없음"
            caffeineGramLabel.text = nutrition.caffeine != nil ? String(nutrition.caffeine!) + "mg" : "정보없음"
            saturatedfatGramLabel.text = nutrition.saturatedfat != nil ? String(nutrition.saturatedfat!) + "g" : "정보없음"
            carbohydrateGramLabel.text = nutrition.carbohydrate != nil ? String(nutrition.carbohydrate!) + "g" : "정보없음"
            sugarsGramLabel.text = nutrition.sugars != nil ? String(nutrition.sugars!) + "g" : "정보없음"
            saltGramLabel.text = nutrition.salt != nil ? String(nutrition.salt!) + "mg" : "정보없음"
            proteinGramLabel.text = nutrition.protein != nil ? String(nutrition.protein!) + "g" : "정보없음"
            fatGramLabel.text = nutrition.fat != nil ? String(nutrition.fat!) + "g" : "정보없음"
            cholesterolGramLabel.text = nutrition.cholesterol != nil ? String(nutrition.cholesterol!) + "mg" : "정보없음"
            transfatGramLabel.text = nutrition.transfat != nil ? String(nutrition.transfat!) + "g" : "정보없음"
        }
    }
    
    @objc func wrongContentBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <#comment#>")
        guard let modalVC = ModalViewController.getInstance() else { return }
        modalVC.modalType = .wrongContent
        modalVC.firstLabelContent = menuName.text
        self.present(modalVC, animated: true)
    }
}
