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
import SkeletonView
import CoreLocation

class RestaurantsViewController: UIViewController,CLLocationManagerDelegate {
        
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    var restaurantsArray: [Restaurant] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredRestaurants: [Restaurant] = []
    
    
    let locationManager = CLLocationManager()
    
    //var latitude = 37.773972
    //var longitude = -122.431297
    
    // Variable inits
    var animationView: AnimationView?
    var refresh = true
    
    let yelpRefresh = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAnimations()
        // Table View
        tableView.visibleCells.forEach { $0.showSkeleton() }
        tableView.delegate = self
        tableView.dataSource = self
        
        // Search Bar delegate
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        
        locationManager.delegate = self
    
    
        // Get Data from API
        getAPIData()
        
        yelpRefresh.addTarget(self, action: #selector(getAPIData), for: .valueChanged)
        tableView.refreshControl = yelpRefresh
    }
    
    
    
    @objc func getAPIData() {
        let curLocation = getCurrentLocation(locationManager: locationManager)
        
        API().getRestaurants(lat: curLocation.lat,long: curLocation.long) { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            
            self.restaurantsArray = restaurants
            self.filteredRestaurants = restaurants
            self.tableView.reloadData()
            
            // MARK: LAB6 Checking for coordinates
            for rest in self.restaurantsArray {
                 print("COORDINATES", rest.coordinates)
             }
            
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.stopAnimations), userInfo: nil, repeats: false)
        
            self.yelpRefresh.endRefreshing()
            
        }
    }
    
    //Uses CLLocationManager to ask the user for their location
    //If they decline, return hardcoded san francisco coordinates
    func getCurrentLocation(locationManager: CLLocationManager)-> ( lat: Double, long:Double) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            if let currentLocation = locationManager.location {
                print("successfully received current location")
                return (currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            }
        case .denied:
            print("user denied location services. Attempting reprompt")
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            print("user location services not determined. Attempting reprompt")
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
        
        // fail to get current location or denied location tracking -> return coordinates for San Francisco
        return (Double(37.773972), Double(-122.431297))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined:
                break
            default:
                getAPIData()
        }
    }

}

extension RestaurantsViewController: SkeletonTableViewDataSource {
    
    
    func startAnimations() {
        // Start Skeleton
        view.isSkeletonable = true
        
        animationView = .init(name: "4762-food-carousel")
        // Set the size to the frame
        //animationView!.frame = view.bounds
        animationView!.frame = CGRect(x: view.frame.width / 3 , y: 156, width: 100, height: 100)

        // fit the
        animationView!.contentMode = .scaleAspectFit
        view.addSubview(animationView!)
        
        // 4. Set animation loop mode
        animationView!.loopMode = .loop

        // Animation speed - Larger number = faste
        animationView!.animationSpeed = 5

        //  Play animation
        animationView!.play()
        
    }
    

    @objc func stopAnimations() {
        // ----- Stop Animation
        animationView?.stop()
        // ------ Change the subview to last and remove the current subview
        view.subviews.last?.removeFromSuperview()
        view.hideSkeleton()
        refresh = false
    }
    

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "RestaurantCell"
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
        
        // Initialize skeleton view every time cell gets initialized
        cell.showSkeleton()
        
        // Stop animation after like .5 seconds
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            cell.stopSkeletonAnimation()
            cell.hideSkeleton()
        }
        
        
        return cell
    }
    
    
    // ––––– TODO: Send restaurant object to DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let r = filteredRestaurants[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r = r
        }
        
    }
    
}


// ––––– UI SearchBar Functionality –––––
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





