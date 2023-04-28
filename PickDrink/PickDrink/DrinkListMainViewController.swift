//
//  DrinkListMainViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/20.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

//MARK: - 메뉴 리스트 화면
@IBDesignable
class DrinkListMainViewController: UIViewController {
    let db = Firestore.firestore()
    
    let cafeList: [String] = ["스타벅스", "투썸플레이스", "메가커피", "할리스", "탐앤탐스"]
    var cafeId: String = ""
    
    //menuCategory의 인덱스 순서대로 menuList에 저장
    let menuCategory: [String] = ["espresso", "coldbrew", "frappuccino", "fizzio", "tea", "refresher", "blended", "brewedcoffee", "etcDrink"]
    
    //menuList[0] = espresso 메뉴들
    //menuList[1] = coldbrew 메뉴들
    //menuList[2] = frappuccino 메뉴들(프라페, 할리치노 등)
    //menuList[3] = fizzio 메뉴들(에이드)
    //menuList[4] = tea 메뉴들
    //menuList[5] = refresher 메뉴들
    //menuList[6] = blended 메뉴들(스무디, 주스)
    //menuList[7] = brewedCoffee 메뉴들
    //menuList[8] = etcDrink 메뉴들
    var menuList: [[CafeMenuComposition]] = []
    
    @IBOutlet weak var cafeListStackView: UIStackView!
    @IBOutlet weak var selectedCafeName: UILabel!
    @IBOutlet weak var drinkListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuList = Array(repeating: [], count: menuCategory.count)
        receiveCafeData()
        makeCafeBtn(cafeList)
        drinkListTableView.dataSource = self
        drinkListTableView.delegate = self
        
        //사용하는 셀 등록
        drinkListTableView.register(ListTableViewCell.uiNib, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func receiveCafeData(){
        let starbucks = db.collection("cafes").document("starbucks")
        starbucks.getDocument(as: Cafe.self) { result in
            switch result {
            case .success(let data):
                print(#fileID, #function, #line, "")
                self.cafeId = data.cafeId ?? ""
                if let cafeMenus = data.cafeMenus {
                    self.menuList[0] = cafeMenus.espresso
                    self.menuList[1] = cafeMenus.coldbrew
                    self.menuList[2] = cafeMenus.frappuccino
                    self.menuList[3] = cafeMenus.fizzio
                    self.menuList[4] = cafeMenus.tea
                    self.menuList[5] = cafeMenus.refresher
                    self.menuList[6] = cafeMenus.blended
                    self.menuList[7] = []
                    self.menuList[8] = cafeMenus.etcDrink
                }
                self.drinkListTableView.reloadData()
            case .failure(let err):
                print(#fileID, #function, #line, "- err: \(err)")
            }
        }
    }
    
    func makeCafeBtn(_ cafeList: [String]) {
        for i in 0..<cafeList.count {
            print(#fileID, #function, #line, "- cafeListName: \(cafeList[i])")
            let cafeBtn: UIButton = MyStackBtn(cafeList[i], .drinkList, i)
            
            cafeBtn.addTarget(self, action: #selector(cafeListBtnSelected(_ :)), for: .touchUpInside)
            
            cafeListStackView.addArrangedSubview(cafeBtn)
        }
    }
    
    @objc func cafeListBtnSelected(_ sender: UIButton) {
        print(#fileID, #function, #line, "- sender.label: \(String(describing: sender.titleLabel?.text))")
        
        if let cafeName = sender.titleLabel?.text {
            selectedCafeName.text = cafeName
        }
        
        cafeListStackView.arrangedSubviews.map { btn in
            if btn.tag == sender.tag {
                btn.backgroundColor = UIColor(named: "cafeListSelectedBtnColor")
                
            } else {
                btn.backgroundColor = UIColor(named: "cafeListBtnColor")
            }
        }
    }
    
}

extension DrinkListMainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- menuList: \(menuList[0])")
        return menuList[section].count == 0 ? 1 : menuList[section].count
    }

    //섹션별로 어떤 cell이 들어가는지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print(#fileID, #function, #line, "- sectionIndex: \(indexPath.section)")

        guard let recruitCell = drinkListTableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell()}

        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        let category = menuCategory[sectionIndex]
        var categoryKorean = ""
        
        switch cafeId {
        case "starbucks":
            categoryKorean = MenuCategory.starbucksKoreaName(category)
        case "mega":
            categoryKorean = MenuCategory.megaKoreaName(category)
        default:
            categoryKorean = ""
        }
        
        if menuList[sectionIndex].count == 0 {
            recruitCell.listLabel.text = "\(categoryKorean)에 해당하는 메뉴는 없습니다"
        } else {
            recruitCell.listLabel.text = menuList[sectionIndex][rowIndex].menuName
        }

        return recruitCell
    }
}

extension DrinkListMainViewController: UITableViewDelegate {
    //MARK: - tableview header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(#fileID, #function, #line, "- cafeId: \(cafeId)")
        let englishName = menuCategory[section]
        
        switch cafeId {
        case "starbucks": return MenuCategory.starbucksKoreaName(englishName)
        case "mega": return MenuCategory.megaKoreaName(englishName)
        default: return ""
        }
    }
    
    //MARK: - tableview cell클릭시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- menuList's clicked menu: \(menuList[indexPath.section][indexPath.row])")
        //메뉴 중에 하나를 클릭한다면 해당 메뉴를 기준으로 MenuDetailViewController가 열려야 한다
        guard let menuDetailVC = MenuDetailViewController.getInstance(),
              let menuId = menuList[indexPath.section][indexPath.row].menuId else { return }
    
        menuDetailVC.menuId = menuId

        self.navigationController?.pushViewController(menuDetailVC, animated: true)
    }
}
