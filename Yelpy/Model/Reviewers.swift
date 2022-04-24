//
//  Reviewers.swift
//  Yelpy
//
//  Created by Ziyue Wang on 4/23/22.
//  Copyright © 2022 memo. All rights reserved.
//

import Foundation
import UIKit

class Reviewers: NSObject {
    
    let rating: Double?
    let reviewText: String?
    let dateCreated: String?
    let reviewerName: String?
    let reviewerImage: UIImage?
    let ratingImage: UIImage?
    
    init(dictionary: [String: Any]) {
        
        rating = dictionary["rating"] as? Double
        
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
        
        reviewText = dictionary["text"] as? String
        
        dateCreated = dictionary["time_created"] as? String
        
        let user = dictionary["user"] as? NSDictionary
        
        reviewerName = user!["name"] as? String
        let urlString = user!["image_url"] as? String
        let imageURL: URL?
        if urlString != "" {
            imageURL = URL(string: urlString!)
        } else {
            imageURL = URL(string: "")
        }
        if let data = try? Data(contentsOf: imageURL!) {
            reviewerImage = UIImage(data: data)
        } else {
            reviewerImage = UIImage(named: "Food")
        }
        
    }
    
    class func reviews(yelpReviwers: [[String: Any]]) -> [Reviewers] {
        var reviews = [Reviewers]()
        for reviwer in yelpReviwers {
            let review = Reviewers(dictionary: reviwer)
            reviews.append(review)
        }
        return reviews
    }
    
}

