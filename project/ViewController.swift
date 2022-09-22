//
//  ViewController.swift
//  project
//
//  Created by 김라영 on 2022/09/02.
//

import UIKit

class ViewController: UIViewController {
    let 상수: Int? = nil
    var 변수: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // if-let
        let a = 상수
        if a != nil { print(a) }
        if let b = 상수 { print(b) }
        
        let view : UIView
        // guard-let
        let c = 상수
        if c == nil { print("nil") }
        guard let d = 상수 else { print("nil"); return }
        
    
        
    }

}

