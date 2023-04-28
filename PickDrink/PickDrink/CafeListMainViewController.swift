//
//  CafeListMainViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/20.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

//MARK: - 카페 리스트 화면
class CafeListMainViewController: UIViewController {
    let db = Firestore.firestore()
    
    let cafeList: [String] = ["스타벅스", "투썸플레이스", "메가커피", "할리스", "탐앤탐스"]
    @IBOutlet weak var cafeListTableView: UITableView!
    var categorie: String = "espresso"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafeListTableView.tag = 1 //카페리스트 tableView's tag = 1
        cafeListTableView.dataSource = self
        cafeListTableView.delegate = self
        //tableview에 사용할 cell등록해주기
        self.cafeListTableView.register(ListTableViewCell.uiNib, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension CafeListMainViewController:  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cafeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#fileID, #function, #line, "- indexPath: \(indexPath.row)")
        guard let recruitCell = cafeListTableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell()}
        
        let index = indexPath.row
        recruitCell.listLabel.text = cafeList[index]
        
        return recruitCell
    }
    
    
}

extension CafeListMainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "카페 리스트"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#fileID, #function, #line, "- tableView: \(tableView.tag)")
        print(#fileID, #function, #line, "- indexPath: \(indexPath)")
        
        let indexRow = indexPath.row
        
        if let recommandMenuListVC = RecommandMenuList.getInstance() {
            recommandMenuListVC.navigationBarTitle = cafeList[indexRow]
            self.navigationController?.pushViewController(recommandMenuListVC, animated: true)
        }
    }
}
