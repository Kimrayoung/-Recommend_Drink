//
//  DataType.swift
//  PickDrink
//
//  Created by 김라영 on 2023/03/24.
//

import Foundation
import UIKit

struct MenuDetail: Codable {
    let id: String?
    let name: String?
    let imgUrl: String?
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
    let reviewPassword: Int?
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

