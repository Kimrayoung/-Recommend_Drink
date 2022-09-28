//
//  MainViewController+TableView.swift
//  project
//
//  Created by 김라영 on 2022/09/23.
//

import Foundation
import UIKit

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "name", for: indexPath) as! NameCell
        let data = imageCollection[indexPath.row]
        cell.nameLabel.text = data.name
        cell.nameImg.image = UIImage(named: data.nameImg)
        
        return cell
    }
}
