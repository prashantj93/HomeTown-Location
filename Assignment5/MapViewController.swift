//
//  MapViewController.swift
//  Assignment5
//
//  Created by prashant joshi on 11/11/17.
//  Copyright © 2017 prashant joshi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    var listOfCountries = [String]()
    var listOfYear = [String]()
    var selectedCountry:String = "Select Country"
    var selectedYear:String = "Select Year"
    var url:String = "https://bismarck.sdsu.edu/hometown/users"
    var range:CLLocationDistance = 10000000
    var fullString:String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var yearPicker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0){
            return listOfCountries.count
        }else{
            return 49
    }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if (pickerView.tag == 0){
            return listOfCountries[row]
        }else{
            return listOfYear[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        
        if (pickerView == countryPicker){
            let countryValueSelected = listOfCountries[row] as String
            selectedCountry = countryValueSelected
            print(countryValueSelected)
            print(listOfCountries[row])
        }
        else if (pickerView == yearPicker){
            let yearValueSelected = listOfYear[row] as String
            selectedYear = yearValueSelected
            print(yearValueSelected)
            print(listOfYear[row])
        }
    }
    
   func getUrl(){
        if ( selectedCountry == "Select Country" && selectedYear == "Select Year" ){
        url =  "https://bismarck.sdsu.edu/hometown/users"
        }else if( selectedCountry != "Select Country" && selectedYear != "Select Year" ){
            url = "http://bismarck.sdsu.edu/hometown/users?country=" + selectedCountry + "&year=" + selectedYear
        }else if(selectedCountry != "Select Country" && selectedYear == "Select Year"){
          url = "http://bismarck.sdsu.edu/hometown/users?country=" + selectedCountry
        }else if(selectedCountry == "Select Country" && selectedYear != "Select Year"){
            url = "http://bismarck.sdsu.edu/hometown/users?year=" + selectedYear
    }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(countryPicker != nil){
            countryPicker.dataSource = self
            countryPicker.delegate = self
        }
        if(yearPicker != nil){
            yearPicker.dataSource = self
            yearPicker.delegate = self
        }
        if let url = URL(string: url) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getWebPage)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
        
        
        loadCountries()
        loadYear()
       
    }
    
    func loadYear(){
        listOfYear.append("Select Year")
        for i in 1970...2017 {
            listOfYear.append(String(i))
        }
    }
    
    func loadCountries(){
        getUrl()
        if let url = URL(string:"https://bismarck.sdsu.edu/hometown/countries") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getCountriesList)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    func getCountriesList(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        
        if data != nil && (status == 200) {
            do {
                let json:Any = try JSONSerialization.jsonObject(with: data!)
                let jsonArray:NSArray = json as! NSArray
                print(jsonArray.count)
                
                
                listOfCountries.append("Select Country")
                for anItem in jsonArray as! Array<String> {
                    listOfCountries.append(anItem)
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.countryPicker.reloadComponent(0)
                    }
                }
            } catch {
            }
        }
    }
    
    @IBAction func applyClick(_ sender: UIButton) {
        getUrl()
        if let url = URL(string: url) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getWebPage)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
        
    }
    
    func getWebPage(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        
        if data != nil && (status == 200) {
            if let webPageContents = String(data: data!, encoding:String.Encoding.utf8) {
                
                let jsonData:Data? = webPageContents.data(using: String.Encoding.utf8)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData!)
                   mapView.removeAnnotations(mapView.annotations)
                    var i:Int = 0;
                    for anItem in jsonResult as! [Dictionary<String, AnyObject>] {
                        
                        fullString = ""
                        let nickname = anItem["nickname"] as! String
                        let country = anItem["country"] as! String
                        let state = anItem["state"] as! String
                        let lat = anItem["latitude"] as! Double
                        let long = anItem["longitude"] as! Double
                        var coordinate = CLLocationCoordinate2DMake(32.715736, -117.161087)
                        if(lat != 0.0 && long != 0.0 ){
                            print(lat)
                            print(long)
                         coordinate = CLLocationCoordinate2DMake(lat, long)
                         
                            let marker = AnnotatedLocation(
                                coordinate: coordinate,
                                title: "",
                                subtitle: nickname)
                            mapView!.addAnnotation(marker)
                        }else{
                            let locator = CLGeocoder()
                            print(country+","+state)
                            locator.geocodeAddressString(country+","+state)
                            { (placemarks, errors) in
                                if let place = placemarks?[0] {
                                    coordinate = CLLocationCoordinate2DMake((place.location?.coordinate.latitude)!, (place.location?.coordinate.longitude)!)
                                    print(coordinate)
                                    let marker = AnnotatedLocation(
                                        coordinate: coordinate,
                                        title:"",
                                        subtitle: nickname)
                                    self.mapView!.addAnnotation(marker)
                                } else {
                                    print( errors! )
                                }
                            }
                        }
                            if(selectedCountry != "Select Country"){
                                let locator = CLGeocoder()
                                print(selectedCountry)
                                locator.geocodeAddressString(selectedCountry)
                                { (placemarks, errors) in
                                    if let place = placemarks?[0] {
                                        let coordinate1 = CLLocationCoordinate2DMake((place.location?.coordinate.latitude)!, (place.location?.coordinate.longitude)!)
                                        self.updateMapRegion(location: coordinate1, rangeSpan: self.range)
                                    } else {
                                        print( errors! )
                                    }
                                }                            
                        }
                        
                       
                        i=i+1;
                    }
                    print(i)
                    
                } catch {
                    print("Unable to convert JSON")
                }
            } else {
                print("Unable to convert data to text")
            }
        }
    }
    
    func updateMapRegion(location:CLLocationCoordinate2D, rangeSpan:CLLocationDistance){
        let region = MKCoordinateRegionMakeWithDistance(location, rangeSpan, rangeSpan)
        //mapView.region = region
        self.mapView.setRegion(region, animated: true)
    }
   
    class AnnotatedLocation:NSObject, MKAnnotation {
        let coordinate: CLLocationCoordinate2D
        let subtitle:String?
        
        init(coordinate: CLLocationCoordinate2D,title:String,subtitle:String) {
            self.coordinate = coordinate
            self.subtitle = subtitle
        }
    }
}
