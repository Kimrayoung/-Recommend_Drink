//
//  RecommandMenuList.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/22.
//

import Foundation
import UIKit

class RecommandMenuList: UIViewController {
    let recommandList: [String] = ["다이어터", "달달구리", "논 카페인", "신메뉴"]
    
    let menuList: [[String]] = [["아메리카노", "카페라떼", "바닐라라떼", "헤이즐럿라떼", "카라멜마끼야또"], ["초코라떼", "오곡라떼", "밤라떼", "밀크티"],["자몽에이드", "오렌지에이드", "레몬에이드", "청포도에이드"], ["자몽주스", "오렌지주스", "딸기주스", "딸기바나나주스", "블루베리 주스"], ["루이보스", "캐모마일", "얼그레이", "히비스커스"]]
    
    let menuListSectionString: [String] = ["espresso", "Non-espresso", "Ade", "Juicy", "Tea"]
    var navigationBarTitle: String = ""

    @IBOutlet weak var recommandStackView: UIStackView!
    @IBOutlet weak var recommanListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        recommandBtnSetting(recommandList)
        recommanListTableView.dataSource = self
        recommanListTableView.delegate = self
        
        //tableview에 셀등록
        recommanListTableView.register(ListTableViewCell.uiNib, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "카페리스트", style: .done, target: self, action: #selector(self.backBarBtnAction(_ :)))
        self.navigationItem.title = navigationBarTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItem
    }
    
    @objc func backBarBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func recommandBtnSetting(_ recommandList: [String]) {
        for i in 0..<recommandList.count {
            print(#fileID, #function, #line, "- comment")
            let recommandBtn: UIButton = MyStackBtn(recommandList[i], .recommandList, i)
            recommandBtn.addTarget(self, action: #selector(recommandBtnSelected(_:)), for: .touchUpInside)
            recommandStackView.addArrangedSubview(recommandBtn)
        }
    }
    
    @objc fileprivate func recommandBtnSelected(_ sender: UIButton) {
        
        recommandStackView.arrangedSubviews.map { btn in
            if btn.tag == sender.tag {
                btn.backgroundColor = UIColor(named: "recommandSelectedBtnColor")
            } else {
                btn.backgroundColor = UIColor(named: "recommandBtnColor")
            }
        }
    }
}


extension RecommandMenuList: UITableViewDataSource {
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
        
        guard let recruitCell = recommanListTableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell()}
        
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        recruitCell.listLabel.text = menuList[sectionIndex][rowIndex]
        
        return recruitCell
    }
    
    
}

extension RecommandMenuList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(#fileID, #function, #line, "- section: \(section)")
        
        return menuListSectionString[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- comment")
        
        guard let menuDetailVC = MenuDetailViewController.getInstance() else { return }
        menuDetailVC.menuId = menuList[indexPath.section][indexPath.row]
        
        self.navigationController?.pushViewController(menuDetailVC, animated: true)
    }
}
