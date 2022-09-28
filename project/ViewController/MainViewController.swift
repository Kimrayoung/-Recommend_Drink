//
//  MainViewController.swift
//  project
//
//  Created by 김라영 on 2022/09/20.
//

import Foundation
import UIKit

class MainViewController : UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    let imageCollection : [NameEntity] = [
        NameEntity(name: "kim", nameImg: "sun"),
        NameEntity(name: "park", nameImg: "foggy"),
        NameEntity(name: "Lee", nameImg: "rainy"),
        NameEntity(name: "Son", nameImg: "snowy"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
}
