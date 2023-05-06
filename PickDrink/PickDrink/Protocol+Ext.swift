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
      print(#fileID, #function, #line, "- storyboardName checked: \(String(describing: self))")
    let name = storyboardName ?? String(describing: self)
    
    let storyBoard = UIStoryboard(name: name, bundle: Bundle.main)
    return storyBoard.instantiateViewController(withIdentifier: String(describing: self)) as? Self
  }
}

extension UIViewController: Storyboarded {}

extension UIImageView {
    func loadImg(url: URL) {
        print(#fileID, #function, #line, "- uiimage: \(url)")
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension UITableView {
    func setEmptyMessage() {
        print(#fileID, #function, #line, "- setEmptyMessage")
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            messageLabel.text = "아직 데이터를 준비하지 못했습니다🥺 \n조금만 기다려주세요"
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 15)
            messageLabel.sizeToFit()

            self.backgroundView = messageLabel
            self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UICollectionView {
    func setEmptyMessage() {
        print(#fileID, #function, #line, "- setEmptyMessage")
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            messageLabel.text = "아직 리뷰가 없습니다🥺 \n리뷰나 자신만의 꿀팁을 남겨주세요!❤️"
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = .systemFont(ofSize: 15)
            messageLabel.sizeToFit()

            self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
