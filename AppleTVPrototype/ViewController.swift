//
//  ViewController.swift
//  AppleTVPrototype
//
//  Created by James Scoltock on 6/28/18.
//  Copyright © 2018 Able. All rights reserved.
//

import UIKit

class ViewController: SQLViewController {
    
    var PartDatalist = [[[String]]]()

    @IBOutlet var PartDescription: UILabel!
    @IBOutlet var AblePart: UILabel!
    @IBOutlet var PartImage: UIImageView!
    
    @IBAction func Start(_ sender: Any) {
        for i in 1 ... self.PartDatalist.count - 1 {

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i+2)) {
                self.PartDescription.text = self.getDatalistValueFromColunmNameAndRow(Datalist: self.PartDatalist,ColumnName: "Description",Row:i)
                self.AblePart.text = self.getDatalistValueFromColunmNameAndRow(Datalist: self.PartDatalist,ColumnName: "PartNo",Row:i)
                self.displayImage()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let strSQL = "select top(100) PartNo, Description from dat_Parts_vw"   //  + OrderPartID.text!
        self.PopulateDatalist(strSQL: strSQL, numColumns: 2) { (Datalist) in
            self.PartDatalist = Datalist
        }
    }
    
    
    func displayImage() {
        
        let URL_IMAGE = URL(string: "http://fukushima/partimages/i_" + AblePart.text! + ".jpg")
        
        let session = URLSession(configuration: .ephemeral)  //prevents old images from being used if they were just annotated
        
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: URL_IMAGE!) { (data, response, error) in
            
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    
                    //checking if the response contains an image
                    if let imageData = data {
                        
                        //getting the image
                        let image = UIImage(data: imageData)
                        
                        DispatchQueue.main.async {
                            //displaying the image
                            self.PartImage.image = image
                        }
                        
                    } else {
                        print("Image file is corrupted")
                    }
                } else {
                    print("No response from server")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
    }
    
    /* Begining of Database Functions ******************************************************************************************/
    
    func PopulateDatalist(strSQL: String, numColumns: Int, completion: @escaping ([[[String]]]) -> Void ) {
        let client = SQLClient.sharedInstance()
        var PreDatalist = [String]()
        var PostDatalist = [[[String]]]()
        //var strTmp = String()
        
        client?.delegate = self
        client?.connect("Skynet", username: "iOSApps", password: "Holycow_2", database: "Able") {
            success in
            if success {
                client?.execute(strSQL) {
                    results in
                    for table in results as! NSArray {
                        for row in table as! NSArray {
                            for column in (row as? NSDictionary)! {
                                //print("\(column.key) = \(column.value)")
                                PreDatalist.append(((column.key) as? String)!)
                                if let strTmp = column.value as? String
                                {
                                    PreDatalist.append(((column.value) as? String)!)
                                }
                                else
                                {
                                    PreDatalist.append(((" ") as? String)!)
                                }
                            }           //colunm
                        }               //row
                    }                   //table
                    //client?.disconnect()
                    
                    //transform PreDatalist to PostDatalist
                    var CurrColumn = 0
                    var rowValues = [String]()
                    var rowColumnNames = [String]()
                    var rowValueAndColumnNames = [[String]]()
                    let lenPreDataList = PreDatalist.count
                    for i in 0..<lenPreDataList {
                        if i % 2 == 0 {  //odd columnName
                            //append to rowColumnames array
                            rowColumnNames.append(PreDatalist[i].uppercased())  //uppercase to make column name match problem free
                        }
                        else {
                            //append to colunNames array
                            rowValues.append(PreDatalist[i])
                        }
                        CurrColumn = CurrColumn + 1
                        if CurrColumn == numColumns * 2 {  // * 2 because we have twice as many entries - one for column namd and another for value
                            //above we mades arrays of names and values
                            //now we have to append those 2 arrays to a third array
                            rowValueAndColumnNames.append(rowColumnNames)
                            rowValueAndColumnNames.append(rowValues)
                            //now we add the third array to datalist
                            PostDatalist.append(rowValueAndColumnNames)
                            rowValues.removeAll()
                            rowColumnNames.removeAll()
                            rowValueAndColumnNames.removeAll()
                            CurrColumn = 0
                        }
                    }
                    completion(PostDatalist)
                }                       //client execute
            }                           //if success client connect
        }
    }
    
    func ExecuteSQL(_ strSQL : String) {
        let client = SQLClient.sharedInstance()
        client?.delegate = self
        
        client?.connect("Skynet", username: "iOSApps", password: "Holycow_2", database: "Able") {
            success in
            if success {
                client?.execute(strSQL) {
                    
                    results in
                    
                    for table in results as! NSArray {
                        for row in table as! NSArray {
                            for column in row as! NSDictionary {
                                print("\(column.key) = \(column.value)")
                                
                                //self.myFileName.text = ((column.value) as! String)
                                //self.filenameNoExtension = ((column.value) as! String)
                            }           //colunm
                        }               //row
                    }                   //table
                    //self.myImageUploadRequest(folder)
                    //self.MeasurementsTableview.reloadData()
                    //client?.disconnect()
                }                       //client execute
            }                           //if success client connect
        }                               //client connect
    }
    
    func getDatalistValueFromColunmNameAndRow(Datalist: [[[String]]], ColumnName: String, Row: Int) -> String {
        var indexOfColumnName = 0
        
        indexOfColumnName = Datalist[0][0].index(of:ColumnName.uppercased())!
        return Datalist[Row][1][indexOfColumnName]
    }
    
    /* End of Database Functions ****************************************************************************************/


}

