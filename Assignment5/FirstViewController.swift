//
//  FirstViewController.swift
//  Assignment5
//
//  Created by prashant joshi on 11/6/17.
//  Copyright © 2017 prashant joshi. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController,  UITextFieldDelegate, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var nickName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var countryStatePicker: UIPickerView!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var setLocation: UIButton!
    @IBOutlet weak var addUser: UIButton!
    
    var selectedCountry:String = "Canada"
    var selectedState: String = "Ontario"
    var selectedYear: String="1970"
    var listOfState = [String]()
    var listOfCountries = [String]()
    var listOfYear = [String]()
    var lat: Double?
    var long: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(countryStatePicker != nil){
            countryStatePicker.dataSource = self
            countryStatePicker.delegate = self
        }
        if(yearPicker != nil){
            yearPicker.dataSource = self
            yearPicker.delegate = self
        }
        loadCountries()
        loadYear()
        self.hideKeyboard()
        self.title = "Enter Information"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCountries(){
        if let url = URL(string: "https://bismarck.sdsu.edu/hometown/countries") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getCountriesList)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    func loadYear(){
        for i in 1970...2017 {
            listOfYear.append(String(i))
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
                
                var i:Int = 0;
                for anItem in jsonArray as! Array<String> {
                    listOfCountries.append(anItem)
                    print(listOfCountries[i])
                    i=i+1;
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        print(self.listOfCountries)
                        self.countryStatePicker.reloadComponent(0)
                        self.selectedCountry = self.listOfCountries[0]
                        self.loadState(selectedCountry: self.selectedCountry)
                    }
                }
            } catch {
            }
        }
    }
    
    func loadState(selectedCountry:String){
        print(selectedCountry)
        listOfState.removeAll()
        if let url = URL(string: "https://bismarck.sdsu.edu/hometown/states?country="+selectedCountry) {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getStateList)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    func getStateList(data:Data?, response:URLResponse?, error:Error?) -> Void {
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
                
                var i:Int = 0;
                for anItem in jsonArray as! Array<String> {
                    listOfState.append(anItem)
                    i=i+1;
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        print(self.listOfState)
                        self.countryStatePicker.reloadComponent(1)
                    }
                }
            } catch {
            }
        }
    }
    
   
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (pickerView == countryStatePicker){
            return 2
        }else {
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView == countryStatePicker){
            switch component {
            case 0: return listOfCountries.count
            case 1: return listOfState.count
            default: return 0
            }
        }
        else {
            return 48
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if (pickerView == countryStatePicker){
            switch component {
            case 0: return listOfCountries[row]
            case 1: return listOfState[row]
            default: return "None"
            }
            
        }
        else if (pickerView == yearPicker){
            return listOfYear[row]
            
        }else{ return nil}
        
       
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int) {
        if (pickerView == countryStatePicker){
            if component == 0 {
                selectedCountry = listOfCountries[row]
                loadState(selectedCountry: selectedCountry)
                countryStatePicker.reloadComponent(1)
            }
            if component == 1 {
                selectedState = listOfState[row]
            }
        }
        else if (pickerView == yearPicker){
            let yearValueSelected = listOfYear[row] as String
            selectedYear = yearValueSelected
            print(yearValueSelected)
            print(listOfYear[row])
        }
    }
    
    func swiftToJSONString(data:Any) -> String? {
        do {
            let arrayAsData: Data = try JSONSerialization.data(withJSONObject: data)
            return String(data: arrayAsData,encoding:String.Encoding.utf8)
        } catch {
            return nil
        }
    }

    @IBAction func addUser(_ sender: UIButton) {
        if ( nickName.text != "" && password.text != "" && city.text != ""){
            if(password.text!.characters.count >= 3){
                var dictionary:Dictionary<String,Any> = Dictionary()
                dictionary["nickname"] = nickName.text
                dictionary["password"] = password.text
                dictionary["country"] = selectedCountry
                dictionary["state"] = selectedState
                dictionary["city"] = city.text
                if let a = Double(selectedYear) {
                    dictionary["year"] = a
                }else{ //alert do ki year stringni ho sakti}
                }
                if((lat != nil ) && (long != nil )){
                    dictionary["latitude"] = lat
                    dictionary["longitude"] = long
                }
                Alamofire.request("https://bismarck.sdsu.edu/hometown/adduser", method: .post,
                                  parameters: dictionary, encoding: JSONEncoding.default)
                    .validate()
                    .responseString { response in
                        switch response.result {
                        case .success:
                            if let utf8Text = response.result.value {
                                print(utf8Text)
                                let alert = UIAlertController(title: "Alert", message: "User added sucessfully", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.nickName.text = ""
                                self.password.text = ""
                                self.city.text = ""
                                self.latitude.text = ""
                                self.longitude.text = ""
                            }
                        case .failure(let error):
                            print(error)
                            let alert = UIAlertController(title: "Alert", message: "User not added", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        }
                }
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "Passwords must be at least three characters long", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            }
   
        }else{
            let alert = UIAlertController(title: "Alert", message: "Enter all fields", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
    }
    
    
    
    @IBAction func setLocation(_ sender: UIButton) {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let viewController = segue.destination as! FirstMapViewController
        }
    }
    
    @IBAction func setMapLocationClicked(unwindSegue:UIStoryboardSegue) {
        if let source = unwindSegue.source as? FirstMapViewController {
            if((source.latVal != 0.0) && (source.longVal != 0.0) ){
                lat = source.latVal
                long = source.longVal
                latitude.text = String(source.latVal)
                longitude.text = String(source.longVal)
        }
        }
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

