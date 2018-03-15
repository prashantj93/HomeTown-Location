//
//  FirstMapViewController.swift
//  Assignment5
//
//  Created by prashant joshi on 11/11/17.
//  Copyright © 2017 prashant joshi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstMapViewController: UIViewController ,UIGestureRecognizerDelegate{

    var latVal = 0.0
    var longVal = 0.0
   
    
    @IBOutlet weak var mapView: MKMapView!
 var locationManager:CLLocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       for touch in touches {
            let touchPoint = touch.location(in: mapView)
            let location = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            latVal = location.latitude
            longVal = location.longitude
        }
    }
    
    }
