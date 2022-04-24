//
//  MapRestaurant.swift
//  Yelpy
//
//  Created by 小元宵 on 4/24/22.
//  Copyright © 2022 memo. All rights reserved.
//

import Foundation
import UIKit

class MapRestaurant: NSObject {
    
    let name: String?
    let address: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImage: UIImage?
    let reviewCount: NSNumber?
    let rating: Double?
    let phoneNumber: String?
    let id:  String?
    
    init(dictionary: [String: Any]) {
        
        name = dictionary["name"] as? String
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["display_address"] as? NSArray
            if addressArray != nil {
                if addressArray!.count > 0 {
                    address = addressArray![0] as! String
                }
                if addressArray!.count > 1 {
                    address += ", " + (addressArray![1] as! String)
                }
            }
        }
        self.address = address
        
        let imageURLString = dictionary["image_url"] as? String
        
        if imageURLString != "" {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        let categoriesArray = dictionary["categories"] as? [NSDictionary]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category["title"] as! String
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
        id = dictionary["id"] as? String
        
        phoneNumber = dictionary["phone"] as? String

        rating = dictionary["rating"] as? Double
        
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
        } else {
            self.ratingImage = UIImage(named: "small_0")
        }
        
    }
    
    class func restaurant(restaurantsDict: [[String: Any]]) -> [MapRestaurant]{
        var restaurants = [MapRestaurant]()
        for dictionary in restaurantsDict {
            let restaurant = MapRestaurant(dictionary: dictionary)
            restaurants.append(restaurant)
        }
        
        return restaurants
    }
}
