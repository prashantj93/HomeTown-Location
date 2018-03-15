//
//  ListTableViewController.swift
//  Assignment5
//
//  Created by prashant joshi on 11/11/17.
//  Copyright © 2017 prashant joshi. All rights reserved.
//

import Foundation
import UIKit

class ListTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    var listOfCountries = [String]()
    var listOfYear = [String]()
    var selectedCountry:String = "Select Country"
    var selectedYear:String = "Select Year"
    var url:String = "https://bismarck.sdsu.edu/hometown/users"
    
    @IBOutlet weak var countryPicker: UIPickerView!
    var fullString = ""
    @IBOutlet weak var yearPicker: UIPickerView!
    var listData: Array<String> = []
    var listSubtitleData: Array<String> = []
    @IBOutlet weak var viewTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(countryPicker != nil){
            countryPicker.dataSource = self
            countryPicker.delegate = self
            getUrl()
        }
        if(yearPicker != nil){
            yearPicker.dataSource = self
            yearPicker.delegate = self
            getUrl()
        }
        if let url = URL(string: "https://bismarck.sdsu.edu/hometown/users") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getWebPage)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
        viewTable.delegate = self
        viewTable.dataSource = self
        loadCountries()
        loadYear()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == countryPicker){
            return listOfCountries.count
        }else {
            return 49
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        print(pickerView.tag)
        
        if (pickerView == countryPicker){
            return listOfCountries[row]
            
        }
        else if (pickerView == yearPicker){
            return listOfYear[row]
       
        }else{ return nil}
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
    
    func loadYear(){
        var j:Int = 1
        listOfYear.insert("Select Year", at: 0)
        for i in 1970...2017 {
            listOfYear.insert(String(i), at: j)
            j = j+1
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
                
                var i:Int = 1;
                listOfCountries.insert("Select Country", at: 0)
                for anItem in jsonArray as! Array<String> {
                 listOfCountries.insert(anItem, at: i)
                    i=i+1;
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        print(self.listOfCountries)
                        self.countryPicker.reloadComponent(0)
                    }
                }
            } catch {
            }
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
    
    @IBAction func applyClick(_ sender: UIButton) {
        listData.removeAll()
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
                    
                    var i:Int = 0;
                    for anItem in jsonResult as! [Dictionary<String, AnyObject>] {
                        
                        fullString = ""
                        let fName = anItem["nickname"] as! String
                        let cName = anItem["country"] as! String
                        let sName = anItem["state"] as! String
                        let ciName = anItem["city"] as! String
                        let yName = anItem["year"] as! Int
                        fullString = "Country:" + cName + ",State: " + sName + " ,City:" + ciName + ",Year:\(yName)"
                        listData.insert(String(fName), at: i)
                        listSubtitleData.insert(fullString, at: i)
                        i=i+1;
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                              self.viewTable.reloadData()
                        }
                    }
                } catch {
                    print("Unable to convert JSON")
                }
            } else {
                print("Unable to convert data to text")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(listData.count)
        return listData.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)
        cell.detailTextLabel!.text = listSubtitleData[indexPath.row]
        cell.textLabel!.text = listData[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.none;
        return cell
    }
    
    
}
