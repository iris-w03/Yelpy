//
//  MapViewController.swift
//  Yelpy
//
//  Created by Ziyue Wang on 3/1/22.
//  Copyright © 2022 memo. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

class customAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var restaurantImage: UIImage?
    var rating: UIImage?
    
    init(location: CLLocationCoordinate2D) {
        self.coordinate = location
    }
}


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var updateCenter = false
    var showAnnotation = true
    var resturantName = ""
    var restaurants: [Restaurant]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingHeading()
        }
        
        // Additional setup after loading the view.
        self.mapView.showsUserLocation = true
    }
    
    func createAnnotationOnMap() {
        removeAnnotation()
        if let restaurants = restaurants {
            for restaurant in restaurants {
                var image: UIImage?
                if restaurant.imageURL == nil {
                    image = UIImage(named: "Food")
                } else {
                    if let data = try? Data(contentsOf: restaurant.imageURL!) {
                        image = UIImage(data: data)
                    }
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func removeAnnotation() {
        //restaurants?.removeAll()
        let annotationsToRemove = mapView.annotations
        mapView.removeAnnotations( annotationsToRemove )
    }
    
    func addAnnotationAtAddress(address: String, title: String, restImage: UIImage, rating: UIImage) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let custom = customAnnotation(location: coordinate.coordinate)
                    custom.restaurantImage = restImage
                    custom.title = title
                    custom.subtitle = address
                    custom.rating = rating
                    self.mapView.addAnnotation(custom)
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            performSegue(withIdentifier: "GoToDetails", sender: self)
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            resturantName = ((view.annotation?.title)!)!
            
            /*if showAnnotation {
                showAnnotation = false
            } else {
                for selectedAnnotation in mapView.selectedAnnotations {
                    mapView.deselectAnnotation(selectedAnnotation, animated: true)
                }
                showAnnotation = true
            }*/
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            removeAnnotation()
            restaurants?.removeAll()
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if updateCenter {
                let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
                loading.label.text = "Getting change"
                
                let location = self.mapView.centerCoordinate
                API().MapgetRestaurants(latitude: location.latitude, longitude: location.longitude) { (rest: [Restaurant]?, error: Error?) in
                    if let error = error {
                        print("error*** :\(error.localizedDescription)")
                        loading.mode = .customView
                        loading.customView = UIImageView(image: UIImage(named: "error.png"))
                        loading.label.text = "Finished"
                        loading.hide(animated: true, afterDelay: 1)
                    } else {
                        print("successfully")
                        self.restaurants = rest
                        self.createAnnotationOnMap()
                        loading.mode = .customView
                        loading.customView = UIImageView(image: UIImage(named: "check.png"))
                        loading.label.text = "Finished"
                        loading.hide(animated: true, afterDelay: 1)
                    }
                }
            }
        }
     
        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
            
            updateCenter = true
            let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
            loading.label.text = "Getting render"
            restaurants?.removeAll()
            let location = self.mapView.centerCoordinate
            API().MapgetRestaurants(latitude: location.latitude, longitude: location.longitude) {(rest: [Restaurant]?,error: Error?)  in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    loading.mode = .customView
                    loading.customView = UIImageView(image: UIImage(named: "error.png"))
                    loading.label.text = "Finished"
                    loading.hide(animated: true, afterDelay: 1)
                } else {
                    print("successful")
                    self.restaurants = rest
                    self.createAnnotationOnMap()
                    loading.mode = .customView
                    loading.customView = UIImageView(image: UIImage(named: "check.png"))
                    loading.label.text = "Finished"
                    loading.hide(animated: true, afterDelay: 1)
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "customAnnotation"
            
            guard !(annotation is MKUserLocation) else {
                return nil
            }
            let custom = annotation as! customAnnotation
            // custom image annotation
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if (annotationView == nil) {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let pinImage = custom.restaurantImage
                let size = CGSize(width: 40, height: 40)
                UIGraphicsBeginImageContext(size)
                pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                //annotationView?.image = resizedImage
                annotationView?.image = UIImage(named: "Food")
                
                let imageView: UIImageView! = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                
                //var stack = UIStackView()
                let address = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                address.text = custom.subtitle
                let rating = custom.rating
                imageView.image = rating
                let stack = UIStackView(arrangedSubviews: [address, imageView])
                stack.axis = .vertical
                stack.distribution = .equalSpacing
                stack.alignment = .center
                stack.spacing = 5
                annotationView?.detailCalloutAccessoryView = stack
                annotationView?.leftCalloutAccessoryView = UIImageView(image: resizedImage)
                annotationView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
            }
            else {
                annotationView!.annotation = annotation
            }
            
            
            return annotationView
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "GoToDetails" {
                //let destinationVC = segue.destination as! DetailsViewController
                for restaurant in restaurants! {
                    if restaurant.name == resturantName {
                        //destinationVC.restaurant = restaurant
                    }
                }
            }
        }
}
