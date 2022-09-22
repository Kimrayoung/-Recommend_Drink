//
//  MainViewController.swift
//  project
//
//  Created by 김라영 on 2022/09/20.
//

import Foundation
import UIKit

class MainViewController : UIViewController {

    @IBOutlet weak var mainWeatherImage: UIImageView!
    
    let imageCollection = [
        UIImage(named: "sun"),
        UIImage(named: "rainy"),
        UIImage(named: "snowy")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changeWeatherImage(_ sender: UIButton) {
        mainWeatherImage.image = imageCollection[sender.tag]
    }
}
