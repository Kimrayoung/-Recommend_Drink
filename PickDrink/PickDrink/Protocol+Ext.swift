//
//  Protocol+Ext.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/20.
//

import Foundation
import UIKit

//nib파일 생성해서 가지고 오는 프로토콜
protocol Nibbed {
    static var uiNib: UINib { get }
}

extension Nibbed {
    static var uiNib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed {}
extension UICollectionViewCell: Nibbed {}

//nib 파일 이름 가지고 오기
protocol ReuseIdentifier {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifier {}
extension UICollectionViewCell: ReuseIdentifier {}

protocol WithIdentifier {
    static var withIdentifier: String { get }
}

extension WithIdentifier {
    static var withIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol Storyboarded { //프로토콜 선언
  static func getInstance(_ storyboardName: String?) -> Self?
}

extension Storyboarded {
  static func getInstance(_ storyboardName: String? = nil) -> Self? {
    //String(describing) -> 해당하는 클래스의 이름을 가지고 올 수 있다 -> 즉, 자기자신의 이름을 가지고 올 수 있다
      //특정 클래스의 이름을 가져온다
      print(#fileID, #function, #line, "- storyboardName checked: \(String(describing: self))")
    let name = storyboardName ?? String(describing: self)
    
    //스토리보드의 이름이랑 viewController의 이름이 일치한다면? -> 잘 가져와짐
    let storyBoard = UIStoryboard(name: name, bundle: Bundle.main)
    return storyBoard.instantiateViewController(withIdentifier: String(describing: self)) as? Self
  }
}

extension UIViewController: Storyboarded {}

protocol loadNib {
    
}
