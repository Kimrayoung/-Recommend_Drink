//
//  MenuDetailViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/24.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

/// 메뉴 디테일 화면
class MenuDetailViewController: UIViewController {
    let db = Firestore.firestore()
    var cafeId: String = ""
    var menuId: String = "" //나중에 db 연결해서는 이 메뉴 ID를 통해서 데이터를 가지고 온다
    
    var nutritionInfo: Nutrition? = nil
    var menuDetail: MenuDetail? = nil
    
    var menuReviews: [Review]? = nil
    
    @IBOutlet weak var menuImg: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hotOrIceView: UIView!
    @IBOutlet weak var nutritionView: UIView!
    @IBOutlet weak var allergyLabel: UILabel!
    @IBOutlet weak var etcLabel: UILabel!
    
    @IBOutlet weak var reviewRegisterBtn: UIButton!
    @IBOutlet weak var reviewCollectionView: UICollectionView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        receiveMenuData()
        receiveReviewData()
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
    
    //MARK: - 해당 메뉴에 대한 데이터를 받아온다
    func receiveMenuData(){
        print(#fileID, #function, #line, "- <#comment#>")
        let cafe = cafeId + "_menus"
        let cafeMenuRequest = db.collection(cafe).document(menuId)
        cafeMenuRequest.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = try? document.data(as: MenuDetail.self) {
                    print(#fileID, #function, #line, "- data:\(data)")
                    self.menuDetail = data

                    self.nutritionInfo = data.nutrition
                    self.basicSetting()
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //MARK: - 해당 메뉴에 대한 리뷰들을 받아온다
    func receiveReviewData() {
        print(#fileID, #function, #line, "- <#comment#>")
        let reviewRequest = db.collection("reviews").document(menuId)
        reviewRequest.addSnapshotListener { documentSnapshot, err in
            guard let documentSnapshot = documentSnapshot else {
                print(#fileID, #function, #line, "- error fetching document: \(err)")
                return
            }
            if let data = try? documentSnapshot.data(as: ReviewArray.self) {
                print(#fileID, #function, #line, "- Review data parsing success:\(data)")
                self.menuReviews = data.reviews?.reversed()
            } else {
                print(#fileID, #function, #line, "- Review data parsing fail: \(documentSnapshot)")
            }
            self.reviewCollectionView.reloadData()
        }
    }
    
    //MARK: - 기본화면 세팅
    private func basicSetting() {
        priceLabel.text = menuDetail?.price
        descriptionLabel.text = menuDetail?.description ?? "없음"
        descriptionLabel.numberOfLines = 0
        
        
        //MARK: - 따뜻한 음료인지 차가운음료인지 셋팅
        if menuDetail?.iceOrhot == 0 {
            if let imageUrlString = menuDetail?.imgUrl?[0] {
                if let url = URL(string: imageUrlString) {
                    menuImg.loadImg(url: url)
                }
            }
            
            let button = UIButton(type: .system)
            hotOrIceView.addSubview(button)
            button.setTitle("Hot Only", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.layer.cornerRadius = 7
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.red.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .clear
            button.topAnchor.constraint(equalTo: self.hotOrIceView.topAnchor, constant: 0).isActive = true
            button.leftAnchor.constraint(equalTo: self.hotOrIceView.leftAnchor, constant: 0).isActive = true
            button.rightAnchor.constraint(equalTo: self.hotOrIceView.rightAnchor, constant: 0).isActive = true
            button.bottomAnchor.constraint(equalTo: self.hotOrIceView.bottomAnchor, constant: 0).isActive = true
        }
        else if menuDetail?.iceOrhot == 1 { //0 -> hot only, 1 -> ice Only, 2 -> ice and hot
            if let imageUrlString = menuDetail?.imgUrl?[0] {
                if let url = URL(string: imageUrlString) {
                    menuImg.loadImg(url: url)
                }
            }
            
            let button = UIButton(type: .system)
            button.setTitle("Ice Only", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            button.layer.cornerRadius = 7
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.blue.cgColor
            button.translatesAutoresizingMaskIntoConstraints = false
            hotOrIceView.addSubview(button)
            button.topAnchor.constraint(equalTo: self.hotOrIceView.topAnchor, constant: 0).isActive = true
            button.leftAnchor.constraint(equalTo: self.hotOrIceView.leftAnchor, constant: 0).isActive = true
            button.rightAnchor.constraint(equalTo: self.hotOrIceView.rightAnchor, constant: 0).isActive = true
            button.bottomAnchor.constraint(equalTo: self.hotOrIceView.bottomAnchor, constant: 0).isActive = true
            
        }
        else if menuDetail?.iceOrhot == 2 { //0 -> hot only, 1 -> ice Only, 2 -> ice and hot
            if let imageUrlString = menuDetail?.imgUrl?[1] {
                if let url = URL(string: imageUrlString) {
                    menuImg.loadImg(url: url)
                }
            }
            let segmentControl = UISegmentedControl(items: ["Hot", "Iced"])
            segmentControl.translatesAutoresizingMaskIntoConstraints = false
            print(#fileID, #function, #line, "- selectedSegmentIndex: \(segmentControl.selectedSegmentIndex)")
            segmentControl.selectedSegmentIndex = 1
            if segmentControl.selectedSegmentIndex == 0 {
                segmentControl.backgroundColor = .red
            } else {
                segmentControl.backgroundColor = .blue
            }
            segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(_:)), for: .valueChanged)
            hotOrIceView.addSubview(segmentControl)
            
            segmentControl.topAnchor.constraint(equalTo: self.hotOrIceView.topAnchor, constant: 0).isActive = true
            segmentControl.bottomAnchor.constraint(equalTo: self.hotOrIceView.bottomAnchor, constant: 0).isActive = true
            segmentControl.leftAnchor.constraint(equalTo: self.hotOrIceView.leftAnchor, constant: 0).isActive = true
            segmentControl.rightAnchor.constraint(equalTo: self.hotOrIceView.rightAnchor, constant: 0).isActive = true
        }
        
        let nutritionGesture = UITapGestureRecognizer(target: self, action: #selector(self.nutritionViewClicked(_ :)))
        self.nutritionView.addGestureRecognizer(nutritionGesture)
        allergyLabel.text = menuDetail?.allergy ?? "없음"
        etcLabel.text = menuDetail?.etc ?? "없음"

        reviewRegisterBtn.addTarget(self, action: #selector(reviewRegisterBtnClicked(_ :)), for: .touchUpInside)
    }
    
    //MARK: - 따뜻한 음료 <-> 아이스 음료 세그멘트 값 변경
    @objc func segmentControlValueChanged(_ sender: UISegmentedControl) {
        print(#fileID, #function, #line, "- segmentControlChanged\(sender.selectedSegmentIndex)")
        let segmentValue = sender.selectedSegmentIndex
        if segmentValue == 0 {
            sender.backgroundColor = .red
        } else {
            sender.backgroundColor = .blue
        }
        
        //MARK: - segment에 따라서 변경됨
        if let imageUrlString = menuDetail?.imgUrl?[segmentValue] {
            if let url = URL(string: imageUrlString) {
                menuImg.loadImg(url: url)
            }
        }
    }
    
    //MARK: - 리뷰를 쓰기 위해서 리뷰 등록 버튼 클릭
    @objc func reviewRegisterBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ⭐️reviewRegisterBtnClicked")
        guard let reviewRegisterVC = ReviewRegisterViewController.getInstance() else { return }
        if let menuName = menuDetail?.name {
            reviewRegisterVC.navigationTitle = menuName
            self.navigationController?.pushViewController(reviewRegisterVC, animated: true)
        }
        
        reviewRegisterVC.menuId = menuId
        
        reviewRegisterVC.reviewClosure = {
            self.receiveReviewData()
        }
    }
    
    //MARK: - 네비게이션 바 세팅
    private func navigationBarsetting() {
        self.navigationItem.title = menuDetail?.name
        let backBarButtonItemSetting = UIBarButtonItem(title: "메뉴리스트", style: .plain, target: self, action: #selector(navigationbackBarItemAction(_ :)))
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backBarButtonItemSetting
    }
    
    //MARK: - 네비게이션 뒤로가기 버튼 클릭
    @objc func navigationbackBarItemAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 영양성분을 보기 위해서 뷰를 클릭
    @objc func nutritionViewClicked(_ sender: UITapGestureRecognizer) {
        print(#fileID, #function, #line, "- ⭐️nutrition view Clicked: \(self.nutritionInfo)")
        guard let nutritionVC = NutritionViewController.getInstance(),
              let nutritionInfo = self.nutritionInfo else { return }
        
        nutritionVC.nutrition = nutritionInfo
        nutritionVC.tempMenuName = menuDetail?.name
        self.navigationController?.pushViewController(nutritionVC, animated: true)
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

//MARK: - 콜렉션 뷰 dataSource관련 함수
extension MenuDetailViewController: UICollectionViewDataSource {
    //한개의 section에 몇개의 데이터가 들어갈건지 정해주기
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let menuReviews = menuReviews {
            if menuReviews.isEmpty {
                self.reviewCollectionView.setEmptyMessage()
                return 0
            } else {
                self.reviewCollectionView.restore()
                return menuReviews.count
            }
        } else {
            self.reviewCollectionView.setEmptyMessage()
            return 0
        }
    }
    
    //MARK: - 어떤 cell이 들어갈 건지 정해주기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reviewCell = reviewCollectionView.dequeueReusableCell(withReuseIdentifier: ReviewCell.reuseIdentifier, for: indexPath) as? ReviewCell else { return UICollectionViewCell() }
        
        let indexRow = indexPath.row
        
        guard let menuReviews = menuReviews else { return UICollectionViewCell() }
        guard let starImg = UIImage(named: menuReviews[indexRow].reviewStar ?? "fivestars") else { return UICollectionViewCell() }
        
        reviewCell.reviewStarImageView.image = starImg
        reviewCell.reviewContentLabel.text = menuReviews[indexRow].review
        reviewCell.reviewData = menuReviews[indexRow]
        reviewCell.reviewIndex = indexRow
        
        reviewCell.reviewCompainBtnClosure = openModal(_:_:_:_:)
        reviewCell.reviewEditBtnClosure = reviewEdit(_:_:_:_:)

        return reviewCell
    }
}

extension MenuDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(reviewCollectionView.frame.size.width, reviewCollectionView.frame.size.height)
    }
}

//MARK: - reviewCell 관련 함수 처리
extension MenuDetailViewController{
    //MARK: - 리뷰 수정&삭제&신고하기 누르면 뜨는 모달 열기
    func openModal(_ reviewContent: String, _ modalType: Modal, _ reviewData: Review, _ reviewIndex: Int) {
        print(#fileID, #function, #line, "- reviewComplain")
        guard let modalVC = ModalViewController.getInstance() else { return }
        
        modalVC.menuId = menuId
        modalVC.reviewIndex = reviewIndex
        modalVC.reviewData = reviewData
        modalVC.modalType = modalType
        modalVC.firstLabelContent = reviewContent

        self.present(modalVC, animated: true)
    }
    //MARK: - 리뷰 수정하기
    func reviewEdit(_ reviewContent: String, _ modalType: Modal,_ reviewData: Review, _ reviewIndex: Int) {
        print(#fileID, #function, #line, "- reviewEdit")
        guard let passwordVC = PasswordAlertViewController.getInstance() else { return }
        
        guard let reviewPassword = reviewData.reviewPassword else { return }
        passwordVC.reviewPW = reviewPassword
        
        passwordVC.modalPresentationStyle = .overCurrentContext
        passwordVC.modalTransitionStyle =  .crossDissolve
        
        passwordVC.checkBtnClosure = {
            self.openModal(reviewContent, modalType, reviewData, reviewIndex)
        }
        
        self.present(passwordVC, animated: true)
    }
    
    //MARK: - 리뷰 삭제하기
    func reviewDelete(_ reviewPassword: String) {
        print(#fileID, #function, #line, "- reviewDelete", reviewPassword)
        
        guard let passwordVC = PasswordAlertViewController.getInstance() else { return }
        passwordVC.reviewPW = reviewPassword
        passwordVC.modalPresentationStyle = .overCurrentContext
        passwordVC.modalTransitionStyle = .crossDissolve
//        passwordVC.checkBtnClosure =
        self.present(passwordVC, animated: true)
    }
}
