//
//  MenuDetailViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/24.
//

import Foundation
import UIKit

@IBDesignable
class MenuDetailViewController: UIViewController {
    var menuId: String = "" //나중에 db 연결해서는 이 메뉴 ID를 통해서 데이터를 가지고 온다
    
    let nutritionInfo: Nutrition = Nutrition(calorie: 10, caffeine: 150, saturatedfat: 0, carbohydrate: 2, sugars: 0, salt: 5, protein: 1, fat: 0, cholesterol: 0, transfat: nil)
    
    var menuDetail: MenuDetail = MenuDetail(id: "starbucks_americano", name: "아메리카노", imgUrl: nil, allergy: nil, category: "espresso", description: "진한 에스프레소에 시원한 정수물을 더하여 스타벅스의 깔끔하고 강렬한 에스프레소를 가장 부드럽고 시원하게 즐길 수 있는 커피", iceOrhot: 2, price: "4500/ 5000/ 5500", seasonOnly: false, etc: nil, nutrition: nil)
    
    let menuReviews: [Review] = [Review(review: "너무 맛있고 맛이 좋아요 또 먹고 싶어요 많이 먹고 싶어요 계속먹고 싶어요 아랄랄랄랄", reviewPassword: 0123, reviewStar: "fivestars", reviewId: "1234", menuId: "starbucks_americano"), Review(review: "너무 맛있고 맛이 좋아요 또 먹고 싶어요 많이 먹고 싶어요 계속먹고 싶어요 아랄랄랄랄22222222222222222222222222222222222222222", reviewPassword: 0123, reviewStar: "fourstars", reviewId: "1234", menuId: "starbucks_americano"), Review(review: "너무 맛있고 맛이 좋아요 또 먹고 싶어요 많이 먹고 싶어요 계속먹고 싶어요 아랄랄랄랄너무 맛있고 맛이 좋아요 또 먹고 싶어요 많이 먹고 싶어요 계속먹고 싶어요 아랄랄랄랄너무 맛있고 맛이 좋아요 또 먹고 싶어요 많이 먹고 싶어요 계속먹고 싶어요 아랄랄랄랄너무 맛있고 맛이", reviewPassword: 0123, reviewStar: "fivestars", reviewId: "1234", menuId: "starbucks_americano")]
    
    @IBOutlet weak var menuImg: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nutritionView: UIView!
    @IBOutlet weak var allergyLabel: UILabel!
    @IBOutlet weak var etcLabel: UILabel!
    
    @IBOutlet weak var reviewRegisterBtn: UIButton!
    @IBOutlet weak var reviewCollectionView: UICollectionView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        menuDetail.nutrition = nutritionInfo
        basicSetting()
        navigationBarsetting()
        
        reviewCollectionView.dataSource = self
        reviewCollectionView.delegate = self
        
        //reviewCollectionViewCell등록하기
        reviewCollectionView.register(ReviewCell.uiNib, forCellWithReuseIdentifier: ReviewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func basicSetting() {
        priceLabel.text = menuDetail.price
        descriptionLabel.text = menuDetail.description ?? "없음"
        
        let nutritionGesture = UITapGestureRecognizer(target: self, action: #selector(self.nutritionViewClicked(_ :)))
        self.nutritionView.addGestureRecognizer(nutritionGesture)
        allergyLabel.text = menuDetail.allergy ?? "없음"
        etcLabel.text = menuDetail.etc ?? "없음"

        reviewRegisterBtn.addTarget(self, action: #selector(reviewRegisterBtnClicked(_ :)), for: .touchUpInside)
    }
    
    @objc func reviewRegisterBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ⭐️reviewRegisterBtnClicked")
        guard let reviewRegisterVC = ReviewRegisterViewController.getInstance() else { return }
        if let menuName = menuDetail.name {
            reviewRegisterVC.navigationTitle = menuName
            self.navigationController?.pushViewController(reviewRegisterVC, animated: true)
        }
    }
    
    private func navigationBarsetting() {
        self.navigationItem.title = menuDetail.name
        let backBarButtonItemSetting = UIBarButtonItem(title: "메뉴리스트", style: .plain, target: self, action: #selector(navigationbackBarItemAction(_ :)))
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItemSetting
    }
    
    @objc func navigationbackBarItemAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nutritionViewClicked(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- ⭐️nutrition view Clicked")
        guard let nutritionVC = NutritionViewController.getInstance() else { return }
        
        nutritionVC.nutrition = nutritionInfo
        nutritionVC.tempMenuName = menuDetail.name
        self.navigationController?.pushViewController(nutritionVC, animated: true)
    }
    
}

extension MenuDetailViewController: UICollectionViewDataSource {
    //한개의 section에 몇개의 데이터가 들어갈건지 정해주기
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menuReviews.count
    }
    
    //어떤 cell이 들어갈 건지 정해주기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reviewCell = reviewCollectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.reuseIdentifier, for: indexPath) as? ReviewCell else { return UICollectionViewCell() }
        
        let indexRow = indexPath.row
        let starImg : UIImage = UIImage(named: menuReviews[indexRow].reviewStar ?? "fivestars")!
        reviewCell.reviewStarImageView.image = starImg
        reviewCell.reviewContentLabel.text = menuReviews[indexRow].review
        
        reviewCell.reviewCompainBtnClosure = {  reviewContent, modalType in
            guard let modalVC = ModalViewController.getInstance() else { return }
            modalVC.modalType = modalType
            modalVC.firstLabelContent = reviewContent
            self.present(modalVC, animated: true)
        }
        return reviewCell
    }
}

extension MenuDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(reviewCollectionView.frame.size.width, reviewCollectionView.frame.size.height)
    }
}
