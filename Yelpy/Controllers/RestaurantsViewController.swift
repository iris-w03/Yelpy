//
//  RestaurantsViewController.swift
//  Yelpy
//
//  Created by Ziyue Wang on 2/21/22.
//

import UIKit
import AlamofireImage
import CoreLocation

// ––––– TODO: Build Restaurant Class
class RestaurantsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate,CLLocationManagerDelegate,UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // –––––– TODO: Update restaurants Array to an array of Restaurants
    var restaurantsArray: [Restaurant] = []
    var filteredData: [Restaurant]! = []
    var isMoreDataLoading = false
    
    let locationManager = CLLocationManager()
        
    var latitude = 37.773972
    var longitude = -122.431297
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        //tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        getAPIData()
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            
            latitude = locValue.latitude
            longitude = locValue.longitude
            
            //getAPIData()
            //self.tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if (!isMoreDataLoading) {
                let scrollViewContentHeight = tableView.contentSize.height
                let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
                if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                    isMoreDataLoading = true
                    loadMoreData()
                }
            }
    }
    
    
    // ––––– TODO: Update API to get an array of restaurant objects
    func getAPIData() {
        API.getRestaurants(lat: latitude, long: longitude) { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            self.restaurantsArray = restaurants
            self.filteredData = self.restaurantsArray
            self.tableView.reloadData()
        }
    }
    
    // Protocol Stubs
    // How many cells there will be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    

    // ––––– TODO: Configure cell using MVC
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Restaurant Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        
        let restaurant = filteredData[indexPath.row]
        cell.r = restaurant
        return cell
        
        }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filteredData = searchText.isEmpty ? restaurantsArray: restaurantsArray.filter{(item: Restaurant)->Bool in
            let name = item.name
            return name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    // cancel search
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false // remove cancel button
        searchBar.text = ""
        searchBar.resignFirstResponder() // hide keyboarad
        filteredData = restaurantsArray
        tableView.reloadData()
    }
    
    
    // –––––– TODO: Override segue to pass the restaurant object to the DetailsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier != "ProfileSegue"){
                    let cell = sender as! UITableViewCell
                    
                    if let indexPath = tableView.indexPath(for: cell){
                        let r = restaurantsArray[indexPath.row]
                        let detailViewContoller = segue.destination as! RestaurantDetailViewController
                        detailViewContoller.r = r
                    }
        }
    }
    
    func loadMoreData(){
        let lat = 37.773972
        let long = -122.431297
        let url = URL(string: "https://api.yelp.com/v3/transactions/delivery/search?latitude=\(lat)&longitude=\(long)")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task : URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            self.isMoreDataLoading = false
            self.tableView.reloadData()
        }
        task.resume()
    }
        

}

    
    

