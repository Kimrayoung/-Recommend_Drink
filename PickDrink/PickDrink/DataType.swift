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
    let id: String?
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
        case id = "menu_id"
        case name = "menu_name"
        case imgUrl = "menu_imgUrl"
        case allergy = "menu_allergy"
        case category = "menu_category"
        case description = "menu_description"
        case iceOrhot = "menu_iceOrhot"
        case price = "menu_price"
        case seasonOnly = "menu_seasonOnly"
        case etc = "menu_etc"
        case nutrition = "menu_nutrition"
    }
}

struct Nutrition: Codable {
    let calorie: Int?
    let caffeine: Int?
    let saturatedfat: Int? //포화지방
    let carbohydrate: Int? //탄수화물
    let sugars: Int? //당류
    let salt: Int? //나트륨
    let protein: Int? //단백질
    let fat: Int? //지방
    let cholesterol: Int? //콜레스테롤
    let transfat: Int? //트랜스 지방
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

