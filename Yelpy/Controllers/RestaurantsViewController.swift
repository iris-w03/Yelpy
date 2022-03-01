//
//  RestaurantsViewController.swift
//  Yelpy
//
//  Created by Ziyue Wang on 2/21/22.
//

import UIKit
import AlamofireImage

// ––––– TODO: Build Restaurant Class
class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    // –––––– TODO: Update restaurants Array to an array of Restaurants
    var restaurantsArray: [Restaurant] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getAPIData()
    }
    
    
    // ––––– TODO: Update API to get an array of restaurant objects
    func getAPIData() {
        API.getRestaurants() { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            self.restaurantsArray = restaurants
            self.tableView.reloadData()
        }
    }
    
    // Protocol Stubs
    // How many cells there will be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantsArray.count
    }
    

    // ––––– TODO: Configure cell using MVC
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Restaurant Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        
        let restaurant = restaurantsArray[indexPath.row]
        cell.r = restaurant
        return cell
        
        }
        
    // –––––– TODO: Override segue to pass the restaurant object to the DetailsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell){
            let r = restaurantsArray[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r = r
        }
    }
}

    
    

