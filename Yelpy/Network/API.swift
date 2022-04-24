//
//  File.swift
//  Yelpy
//
//  Created by Ziyue Wang on 3/1/22.
//  Copyright © 2022 Ziyue. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class API {
    static let apikey = "gjSp5LrrEi9tJFLQALnw-RdZSRy-TLiJsfPM09LzFMNpMnmSHQZ2n2R_f3ptONYEalxMIudE9avxn_bQvvDZJc1zpPdfPDOvdh08RlT8vZGbqFx3dbtkuliMwATHXnYx"
    static let baseURLString = "https://api.yelp.com/v3/transactions/delivery/search"
    static let baseURLStringM = "https://api.yelp.com/v3/businesses/search"
    
    var session: URLSession
    
    init() {
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func MapgetRestaurants(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping ([MapRestaurant]?, Error?) -> Void) {
        let parameter = "term=Restaurant&location=\(latitude),\(longitude)&limit=50"
        let url = URL(string: API.baseURLStringM + "?" + parameter)!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(API.apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    
                let restaurants = dataDictionary["businesses"] as! [[String: Any]]
                
                completion(MapRestaurant.restaurant(restaurantsDict: restaurants), nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
        
        }
    
    func getRestaurants(lat: CLLocationDegrees, long:CLLocationDegrees, completion: @escaping ([Restaurant]?) -> Void) {
        let parameter = "latitude=\(lat)&longitude=\(long)"
        let url = URL(string: API.baseURLString + "?" + parameter)!
        
        
        // Coordinates for San Francisco
        //let lat = 37.773972
        //let long = -122.431297
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        request.setValue("Bearer \(API.apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                
                // ––––– TODO: Get data from API and return it using completion
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                                
                let restDictionaries = dataDictionary["businesses"] as! [[String: Any]]
                
                let restaurants = restDictionaries.map({ Restaurant.init(dict: $0) })
                
                // Using For Loop
//                var restaurants: [Restaurant] = []
//                for dictionary in restDictionaries {
//                    let restaurant = Restaurant.init(dict: dictionary)
//                    restaurants.append(restaurant)
//                }

                                
                return completion(restaurants)
                
                }
            }
        task.resume()
    }
        
    
    func getRestaurantReviews(with restaurantId: String, completion: @escaping ([Reviewers]?, Error?) -> Void) {
        
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(restaurantId)/reviews")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(API.apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                let reviewers = dataDictionary["reviews"] as! [[String: Any]]
                
                completion(Reviewers.reviews(yelpReviwers: reviewers), nil)
            } else {
                completion(nil, error)
            }
        }
        task.resume()
    }

}

    
