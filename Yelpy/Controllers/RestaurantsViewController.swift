//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage
import Lottie
import CoreLocation
import SkeletonView

class RestaurantsViewController: UIViewController,CLLocationManagerDelegate {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // Initiliazers
    var restaurantsArray: [Restaurant] = []
    var filteredRestaurants: [Restaurant] = []
    
    let locationManager = CLLocationManager()
        
    var latitude = 37.773972
    var longitude = -122.431297
    // –––––  Lab 4: create an animation view
    
    var animationView: AnimationView?
    var refresh = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ––––– Lab 4 TODO: Call animation functions to start
        startAnimations()
        
        animationView = .init(name: "animationName")
        animationView?.frame = view.bounds
        animationView?.play()
        // ––––– Lab 4 TODO: Start animations
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let delayTime = DispatchTime.now() + 3.0
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.stopAnimations()
        })
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        
        // Search Bar delegate
        searchBar.delegate = self
        
        // Get Data from API
        getAPIData()
        
        // –––––  Lab 4: stop animations, you can add a timer to stop the animation
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            
            latitude = locValue.latitude
            longitude = locValue.longitude
            
            //getAPIData()
            //self.tableView.reloadData()
    }
    
    
    @objc func getAPIData() {
        API.getRestaurants(lat: latitude, long: longitude) { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            self.restaurantsArray = restaurants
            self.filteredRestaurants = restaurants
            self.tableView.reloadData()
            
        }
    }
    
}

// ––––– TableView Functionality –––––
extension RestaurantsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Restaurant Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        // Set cell's restaurant
        cell.r = filteredRestaurants[indexPath.row]
        if self.refresh {
            cell.showAnimatedSkeleton()
        }else{
            cell.hideSkeleton()
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let r = filteredRestaurants[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r = r
        }
        
    }
    
}

extension RestaurantsViewController: UISearchBarDelegate {
    
    // Search bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredRestaurants = restaurantsArray.filter { (r: Restaurant) -> Bool in
                return r.name.lowercased().contains(searchText.lowercased())
            }
        }
        else {
            filteredRestaurants = restaurantsArray
        }
        tableView.reloadData()
    }
    
    
    // Show Cancel button when typing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // Logic for searchBar cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false // remove cancel button
        searchBar.text = "" // reset search text
        searchBar.resignFirstResponder() // remove keyboard
        filteredRestaurants = restaurantsArray // reset results to display
        tableView.reloadData()
    }
    
}
//Skeleton View is a way to show the users that your page is loading and are fetching the data. We will implement one to display while the animation is playing.

extension RestaurantsViewController: SkeletonTableViewDataSource{func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
    return "RestaurantCell"
    }
    func startAnimations(){
        animationView = .init(name: "4762-food-carousel")
        // ---- 1.Set the size to the frame
        //animationView!.frame = view.bounds
        animationView!.frame = CGRect(x: view.frame.width / 3, y:0, width:100, height:100)
        
        //fit the animation
        animationView!.contentMode = .scaleAspectFit
        view.addSubview(animationView!)
        // ---- 2. Set animation loop mode
        animationView!.loopMode = .loop
        
        // ---- 3.Animation speed -Larger number = faste
        animationView!.animationSpeed = 5
        
        // ---- 4. Play animation
        animationView!.play()
        view.showGradientSkeleton()
        
    }
    // ––––– Lab 4 TODO: Call animation functions to stop
    @objc func stopAnimations(){
        // ---- 1. Stop Animation
        animationView?.stop()
        // ---- 2. Change the subview to last and remove the current subview
        view.subviews.last?.removeFromSuperview()
        view.hideSkeleton()
        refresh = false
    }
    

}






