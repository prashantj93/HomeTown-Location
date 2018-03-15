//
//  ListViewController.swift
//  Assignment5
//
//  Created by prashant joshi on 11/11/17.
//  Copyright © 2017 prashant joshi. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UITableViewController{
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var viewTable: UITableView!
    var fullName = ""
    var listData: Array<String> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.title = "Select Instructor"
        
        if let url = URL(string: "https://bismarck.sdsu.edu/hometown/users") {
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
                        
                        fullName = ""
                        let fName = anItem["nickname"] as! String
                        let lName = anItem["country"] as! String
                        //let id = anItem["id"] as! Int
                        fullName =  fName + " " + lName
                        listData.insert(String(fullName), at: i)
                        i=i+1;
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                         //   self.tableView.reloadData()
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
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return listData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)
        cell.textLabel!.text = listData[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
        return cell
    }
    
    override func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        //print(indexPath.row)
    }


}
