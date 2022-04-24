//
//  Singletons.swift
//  Yelpy
//
//  Created by Ziyue Wang on 3/2/22.
//  Copyright © 2022 memo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

//all VC's can access restaurant array
class Restaurants {
    static let sharedInstance = Restaurants()
    var array = [Restaurant]()
}

