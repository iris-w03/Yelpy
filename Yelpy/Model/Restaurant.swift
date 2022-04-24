//
//  Restaurant.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import Foundation
import UIKit

// Lab 6: TODO: add MapKit framework --> import MapKit
import MapKit

class Restaurant {
    

    var imageURL: URL?
    var url: URL?
    var name: String
    var mainCategory: String
    var phone: String
    var rating: Double
    var reviews: Int
    var price: String
    var ratingImage: UIImage?
    
    
    // MARK: Lab 6:  Refactor Restaurant Model
    var coordinates: [String:Double]
    

    init(dict: [String: Any]) {
        imageURL = URL(string: dict["image_url"] as! String)
        name = dict["name"] as! String
        rating = dict["rating"] as! Double
        price = dict["price"] as? String ?? "$"
        reviews = dict["review_count"] as! Int
        phone = dict["display_phone"] as! String
        url = URL(string: dict["url"] as! String)
        mainCategory = Restaurant.getMainCategory(dict: dict)
        
        // LAB 6
        coordinates = dict["coordinates"] as! [String:Double]
        if rating != nil {
            switch rating {
            case 1:
                self.ratingImage = UIImage(named: "small_1")
                break
            case 1.5:
                self.ratingImage = UIImage(named: "small_1_half")
                break
            case 2:
                self.ratingImage = UIImage(named: "small_2")
                break
            case 2.5:
                self.ratingImage = UIImage(named: "small_2_half")
                break
            case 3:
                self.ratingImage = UIImage(named: "small_3")
                break
            case 3.5:
                self.ratingImage = UIImage(named: "small_3_half")
                break
            case 4:
                self.ratingImage = UIImage(named: "small_4")
                break
            case 4.5:
                self.ratingImage = UIImage(named: "small_4_half")
                break
            case 5:
                self.ratingImage = UIImage(named: "small_5")
                break
            default:
                self.ratingImage = UIImage(named: "small_0")
                break
            }
        }
        
    }
    
    // Helper function to get First category from restaurant
    static func getMainCategory(dict: [String:Any]) -> String {
        let categories = dict["categories"] as! [[String: Any]]
        return categories[0]["title"] as! String
    }

    
}
