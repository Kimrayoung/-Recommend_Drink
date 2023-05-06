//
//  RecommandMenuList.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class RecommandMenuList: UIViewController {
    let db = Firestore.firestore()
    
    var navigationBarTitle: String = ""
    var cafeId: String  = ""
    var recommandList: [String] = ["다이어트", "신메뉴", "인기⭐️", "논-카페인"]
    var recommandId: String = "diet"
    //menuCategory의 인덱스 순서대로 menuList에 저장
    var menuCategory: [String] = ["espresso", "coldbrew", "frappuccino", "fizzio", "tea", "refresher", "blended", "brewedcoffee", "etcDrink"]
    
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

    @IBOutlet weak var recommandStackView: UIStackView!
    @IBOutlet weak var recommanListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        recommandBtnSetting(recommandList)
        requestRecommand()
        recommanListTableView.dataSource = self
        recommanListTableView.delegate = self
        
        //tableview에 셀등록
        recommanListTableView.register(ListTableViewCell.uiNib, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
        requestRecommand()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - 네비게이션 바 세팅
    func setNavigationBar() {
        let backBarButtonItem = UIBarButtonItem(title: "카페리스트", style: .done, target: self, action: #selector(self.backBarBtnAction(_ :)))
        self.navigationItem.title = navigationBarTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItem
    }
    
    //MARK: - 네비게이션 뒤로가기 버튼 클릭
    @objc func backBarBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 추천대상 버튼 세팅하기
    func recommandBtnSetting(_ recommandList: [String]) {
        for i in 0..<recommandList.count {
            print(#fileID, #function, #line, "- comment")
            let recommandBtn: UIButton = MyStackBtn(recommandList[i], .recommandList, i)
            recommandBtn.addTarget(self, action: #selector(recommandBtnSelected(_:)), for: .touchUpInside)
            recommandStackView.addArrangedSubview(recommandBtn)
        }
    }
    
    //MARK: - 추천대상 버튼 클릭
    @objc fileprivate func recommandBtnSelected(_ sender: MyStackBtn) {
        if let id = sender.titleLabel?.text {
            switch id {
            case "신메뉴" : recommandId = "new"
            case "다이어트" : recommandId = "diet"
            case "논-카페인" : recommandId = "non_caffeine"
            case "인기⭐️" : recommandId = "best"
            default: return
            }
        }
        requestRecommand()
        recommandStackView.arrangedSubviews.map { btn in
            if btn.tag == sender.tag {
                btn.backgroundColor = UIColor(named: "recommandSelectedBtnColor")
            } else {
                btn.backgroundColor = UIColor(named: "recommandBtnColor")
            }
        }
        
    }
    
    private func requestRecommand() {
        let collection = cafeId + "_recommands"
        let recommandDocRef = db.collection(collection).document(recommandId)
        
        recommandDocRef.getDocument(as: Recommand.self) { result in
            switch result {
            case .success(let recommand):
                self.menuList = Array(repeating: [], count: self.menuCategory.count)
                print(#fileID, #function, #line, "- recommadMenusList: \(recommand.recommandMenus)")
                if let menus = recommand.recommandMenus {
                    self.menuList[0] = menus.espresso
                    self.menuList[1] = menus.coldbrew
                    self.menuList[2] = menus.frappuccino
                    self.menuList[3] = menus.fizzio
                    self.menuList[4] = menus.tea
                    self.menuList[5] = menus.refresher
                    self.menuList[6] = menus.blended
                    self.menuList[7] = menus.brewedcoffee
                    self.menuList[8] = menus.etcDrink
                }
            case .failure(let err):
                print(#fileID, #function, #line, "- err: \(err)")
            }
            self.recommanListTableView.reloadData()
            if self.menuList.count != 0 {
                self.recommanListTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        
    }
}

extension RecommandMenuList: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuCategory.count
    }
    //한 섹션에 몇개의 로우가 들어가는 지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#fileID, #function, #line, "- menuList: \(menuList.isEmpty)")
        if menuList.isEmpty {
            self.recommanListTableView.setEmptyMessage()
            return 0
        } else {
            self.recommanListTableView.restore()
            return menuList[section].count == 0 ? 1 : menuList[section].count
        }
    }
    
    //섹션별로 어떤 cell이 들어가는지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#fileID, #function, #line, "- sectionIndex: \(indexPath.section)")
        
        guard let recruitCell = recommanListTableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell()}
        
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        
        let category = menuCategory[sectionIndex]
        var categoryKorean = ""
        
        switch cafeId {
        case "starbucks":
            categoryKorean = MenuCategory.starbucksKoreaName(category)
        default:
            categoryKorean = ""
        }
        
        if menuList[sectionIndex].count == 0 {
            recruitCell.listLabel.text = "\(categoryKorean)에 해당하는 메뉴는 없습니다"
            recruitCell.listLabel.textColor = UIColor(named: "reviewTextViewCntLabel")
            recruitCell.listLabel.font = UIFont.systemFont(ofSize: 13)
        } else {
            recruitCell.listLabel.text = menuList[sectionIndex][rowIndex].menuName
            recruitCell.listLabel.textColor = .black
            recruitCell.listLabel.font = UIFont.systemFont(ofSize: 17)
        }
        
        return recruitCell
    }
    
    
}

extension RecommandMenuList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        print(#fileID, #function, #line, "- section: \(section)")
        let englishName = menuCategory[section]
        
        switch cafeId {
        case "starbucks": return MenuCategory.starbucksKoreaName(englishName)
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- comment")
        
        guard let menuDetailVC = MenuDetailViewController.getInstance() else { return }
        if menuList[indexPath.section].count != 0 {
            if let menuId = menuList[indexPath.section][indexPath.row].menuId {
                menuDetailVC.cafeId = self.cafeId
                menuDetailVC.menuId = menuId
                
                self.navigationController?.pushViewController(menuDetailVC, animated: true)
            }
        }
        
    }
}
