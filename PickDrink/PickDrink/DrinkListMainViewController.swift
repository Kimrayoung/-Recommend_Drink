//
//  DrinkListMainViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/20.
//

import Foundation
import UIKit

@IBDesignable
class DrinkListMainViewController: UIViewController {
    let cafeList: [String] = ["스타벅스", "투썸플레이스", "메가커피", "할리스", "탐앤탐스"]
    
    let menuList: [[String]] = [["아메리카노", "카페라떼", "바닐라라떼", "헤이즐럿라떼", "카라멜마끼야또"], ["초코라떼", "오곡라떼", "밤라떼", "밀크티"],["자몽에이드", "오렌지에이드", "레몬에이드", "청포도에이드"], ["자몽주스", "오렌지주스", "딸기주스", "딸기바나나주스", "블루베리 주스"], ["루이보스", "캐모마일", "얼그레이", "히비스커스"]]
    
    let menuListSectionString: [String] = ["espresso", "Non-espresso", "Ade", "Juicy", "Tea"]
    
    @IBOutlet weak var cafeListStackView: UIStackView!
    @IBOutlet weak var selectedCafeName: UILabel!
    @IBOutlet weak var drinkListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return menuListSectionString.count
    }
    //한 섹션에 몇개의 로우가 들어가는 지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- menuList.count: \(menuList[section].count)")
        return menuList[section].count
    }
    
    //섹션별로 어떤 cell이 들어가는지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#fileID, #function, #line, "- sectionIndex: \(indexPath.section)")
        
        guard let recruitCell = drinkListTableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell()}
        
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        recruitCell.listLabel.text = menuList[sectionIndex][rowIndex]
        
        return recruitCell
    }
}

extension DrinkListMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(#fileID, #function, #line, "- section: \(section)")
        
        return menuListSectionString[section]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- menuList's clicked menu: \(menuList[indexPath.section][indexPath.row])")
        //메뉴 중에 하나를 클릭한다면 해당 메뉴를 기준으로 MenuDetailViewController가 열려야 한다
        
        guard let menuDetailVC = MenuDetailViewController.getInstance() else { return }
        menuDetailVC.menuId = menuList[indexPath.section][indexPath.row]
        
        self.navigationController?.pushViewController(menuDetailVC, animated: true)
    }
}
