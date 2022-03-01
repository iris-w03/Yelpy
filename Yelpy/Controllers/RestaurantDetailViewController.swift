//
//  RestaurantDetailViewController.swift
//  Yelpy
//
//  Created by Ziyue Wang on 2/28/22.
//  Copyright © 2022 memo. All rights reserved.
//

import UIKit
import AlamofireImage

class RestaurantDetailViewController: UIViewController{
    
    @IBOutlet weak var restaurantImage: UIImageView!
    
    var r: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurantImage.af.setImage(withURL: r.imageURL!)
    }
}
