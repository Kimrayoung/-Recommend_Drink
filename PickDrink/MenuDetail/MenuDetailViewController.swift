//
//  MenuDetailViewController.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/24.
//

import Foundation
import UIKit

/// 메뉴 디테일 화면
class MenuDetailViewController: UIViewController {
    let firebaseManage = FirebaseManage.shared
    let authVM = AuthVM.shared
    var cafeId: String = ""
    var menuId: String = "" //나중에 db 연결해서는 이 메뉴 ID를 통해서 데이터를 가지고 온다
    
    var nutritionInfo: Nutrition? = nil
    var menuDetail: MenuDetail? = nil
    
    var menuReviews: [Review]? = nil
    var reviewTestData: [Review]? = nil
    let reviewReferenceTest: [Review]? = nil
    
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
        
//        reviewCollectionViewCell등록하기
        reviewCollectionView.register(ReusableCell.uiNib, forCellWithReuseIdentifier: ReusableCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - 해당 메뉴에 대한 데이터를 받아온다
    func receiveMenuData(){
        print(#fileID, #function, #line, "- <#comment#>")
        let cafe = cafeId + "_menus"
        
        firebaseManage.fetchMenuInfo(cafe, self.menuId) { menuInfo in
            self.menuDetail = menuInfo
            self.nutritionInfo = menuInfo?.nutrition
            self.basicSetting()
        }
        
    }
    
    //MARK: - 해당 메뉴에 대한 리뷰들을 받아온다
    func receiveReviewData() {
        firebaseManage.fetchReviewsAll(self.menuId) { reviews in
            print(#fileID, #function, #line, "- firebaseManage에서 받아온 review 체크⭐️: \(reviews)")
            self.menuReviews = reviews
            self.reviewCollectionView.reloadData()
            
            guard let menuReviewCnt = self.menuReviews?.count else { return }
            if menuReviewCnt > 1 {
                self.reviewCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            }
        }
    }
    
    //MARK: - 기본화면 세팅
    private func basicSetting() {
        priceLabel.text = menuDetail?.price
        descriptionLabel.text = menuDetail?.description ?? "없음"
        descriptionLabel.numberOfLines = 0
        
        
        //MARK: - 따뜻한 음료인지 차가운음료인지 셋팅(0 -> hot only, 1 -> ice Only, 2 -> ice and hot)
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
        else if menuDetail?.iceOrhot == 1 {
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
        else if menuDetail?.iceOrhot == 2 {
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
        print(#fileID, #function, #line, "- auth loginStatus checking: \(authVM.loginStatus.value)")
        if authVM.loginStatus.value != .login {
            let titleText = "에러"
            let reviewAlert = UIAlertController(title: titleText, message: "로그인 이후 작성 가능합니다!", preferredStyle: .alert)
            let reviewAlertAction = UIAlertAction(title: "확인", style: .cancel)

            reviewAlert.addAction(reviewAlertAction)
            self.present(reviewAlert, animated: true)
            return
        }
        
        guard let reviewRegisterVC = ReviewRegisterViewController.getInstance() else { return }
        if let menuName = menuDetail?.name {
            reviewRegisterVC.navigationTitle = menuName
            self.navigationController?.pushViewController(reviewRegisterVC, animated: true)
        }
        
        reviewRegisterVC.menuId = menuId
        reviewRegisterVC.menuName = menuDetail?.name ?? "없음"
        reviewRegisterVC.cafeId = cafeId
        
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


//MARK: - 콜렉션 뷰 dataSource관련 함수
extension MenuDetailViewController: UICollectionViewDataSource {
    //MARK: - 한개의 section에 몇개의 데이터가 들어갈건지 정해주기
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
        guard let reviewCell = reviewCollectionView.dequeueReusableCell(withReuseIdentifier: ReusableCell.reuseIdentifier, for: indexPath) as? ReusableCell else {
            print(#fileID, #function, #line, "- make reusable cell error🥺")
            return UICollectionViewCell()
        }
        
        let indexRow = indexPath.row
        
        guard let menuReviews = menuReviews else {
            print(#fileID, #function, #line, "- get menuReviews error🥺: \(String(describing: menuReviews))")
            return UICollectionViewCell()
        }
        
        reviewCell.cellVCType = .menuDetailReview
        reviewCell.cellData = menuReviews[indexRow]
        reviewCell.cellIndex = indexRow
        
        reviewCell.cellDataSetting()
        reviewCell.cellHiddenDataSetting()
        reviewCell.reviewComplainBtnClosure = openModal(_:_:_:_:)

        print(#fileID, #function, #line, "- menuDetailVC에서 reviewCell 체크⭐️: \(String(describing: reviewCell.cellData))")
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
        
        modalVC.collectionViewScrollToItem = {
            guard let menuReviewCnt = self.menuReviews?.count else { return }
            if menuReviewCnt > 1 {
                self.reviewCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            }
        }
        
        modalVC.complainSendCompledtedClosure = {
            let modalAlert = UIAlertController(title: "리뷰 신고 완료", message: "해당 리뷰에 대한 신고 접수가 완료되었습니다.", preferredStyle: .alert)
            
            let modalAlertAction = UIAlertAction(title: "확인", style: .default)
            
            modalAlert.addAction(modalAlertAction)
            self.present(modalAlert, animated: true)
        }

        self.present(modalVC, animated: true)
    }
    
}


