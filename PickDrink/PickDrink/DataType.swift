//
//  DataType.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/24.
//

import Foundation
import UIKit

struct Cafe: Codable {
    let cafeId: String?
    let cafeMenus: MenuCategory?
    let cafeName: String?
    
    enum CodingKeys: String, CodingKey {
        case cafeId = "cafe_id"
        case cafeMenus = "cafe_menus"
        case cafeName = "cafe_name"
    }
}

struct MenuCategory: Codable {
    let espresso, frappuccino, coldbrew, tea, refresher, fizzio, blended, etcDrink, brewedcoffee: [CafeMenuComposition]
    
    static func starbucksKoreaName(_ englishName: String) -> String{
        switch englishName {
            case "espresso" : return "에스프레소"
            case "frappuccino" : return "프라푸치노"
            case "coldbrew" : return "콜드브루"
            case "fizzio" : return "피지오(에이드)"
            case "tea" : return "티"
            case "refresher" : return "리프레셔"
            case "blended" : return "블렌디드"
            case "etcDrink" : return "기타음료(라떼 등)"
            case "brewedcoffee" : return "브루드 커피"
            default: return "없음"
        }
    }
    
    static func megaKoreaName(_ englishName: String) -> String {
        switch englishName {
            case "espresso" : return "에스프레소"
            case "frappuccino" : return "프라페"
            case "coldbrew" : return "콜드브루"
            case "fizzio" : return "에이드"
            case "tea" : return "티"
            case "refresher" : return "리프레셔"
            case "blended" : return "스무디/주스"
            case "etcDrink" : return "기타음료(라떼 등)"
            case "brewedcoffee" : return "브루드 커피"
            default: return "없음"
        }
    }
}

struct CafeMenuComposition: Codable {
    let menuId, menuName: String?
    
    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case menuName = "menu_name"
    }
}

struct MenuDetail: Codable {
    let name: String?
    let imgUrl: [String]?
    let allergy: String?
    let category: String?
    let description: String?
    let iceOrhot: Int?
    let price: String?
    let seasonOnly: Bool?
    let etc: String?
    var nutrition: Nutrition?
    
    enum CodingKeys: String, CodingKey {
        case name = "menu_name"
        case imgUrl = "menu_imgUrl"
        case allergy = "menu_allergy"
        case category = "menu_category"
        case description = "menu_description"
        case iceOrhot = "menu_iceOrHot"
        case price = "menu_price"
        case seasonOnly = "menu_seasonOnly"
        case etc = "menu_etc"
        case nutrition = "nutritionInfo"
    }
}

struct Nutrition: Codable {
    let calorie: String?
    let caffeine: String?
    let sugar: String? //당류
    let salt: String? //나트륨
    let protein: String? //단백질
    let fat: String? //지방
}

struct ReviewArray: Codable {
    let reviews: [Review]?
}

struct Review: Codable {
    let review: String?
    let reviewPassword: String?
    let reviewStar: String?
    let reviewId: String?
    let menuId: String?
    
    enum CodingKeys: String, CodingKey {
        case review
        case reviewPassword = "review_password"
        case reviewStar = "review_star"
        case reviewId = "review_id"
        case menuId = "menu_id"
    }
}

public enum Modal{
    case wrongContent //잘못 기재된 내용 신고하는 모달
    case complain //신고리뷰
    case editReview //리뷰 수정하기
    
    var firstTitle: String {
        switch self {
        case .wrongContent: return "잘못 기재된 메뉴"
        case .complain: return "신고 리뷰 내용"
        case .editReview: return "수정할 리뷰 내용"
        }
    }
    
    var secondTitle: String {
        switch self {
        case .wrongContent: return "잘못 기재된 내용"
        case .complain: return "신고 사유"
        case .editReview: return "수정 내용"
        }
    }
    
    var firstLabelTextFont: UIFont {
        switch self {
        case .wrongContent: return UIFont.boldSystemFont(ofSize: 16)
        default: return UIFont.systemFont(ofSize: 14)
        }
    }
    
    var textViewPlaceHolder: String {
        switch self {
        case .wrongContent: return "잘못 기재된 내용을 입력해주세요."
        case .complain: return "신고하시는 이유를 간단히 작성해주세요."
        case .editReview: return "리뷰를 어떻게 변경할 건지 작성해주세요."
        }
    }
}

