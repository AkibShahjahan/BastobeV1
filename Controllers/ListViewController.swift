//
//  ListViewController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-08-11.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import UIKit
 
class ListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var screenTitleLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    
    var friendsList = NSMutableArray()
    var listType: String = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        design();
        
        screenTitleLabel.text = listType;
                
        let fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, first_name, last_name, email, picture.type(large)"]);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                if let userNameArray : NSArray = (result.valueForKey("data") as! NSArray)
                {
                    for i in 0 ..< userNameArray.count {
                        let data = userNameArray[i].valueForKey("picture") as? NSDictionary
                        
                        let dict: NSDictionary = ["name":String(userNameArray[i].valueForKey("first_name") as! String) + " " + String(userNameArray[i].valueForKey("last_name") as! String),
                            "picData" : data!
                        ]
                        
                        self.friendsList.addObject(dict)
                        
                    }
                    self.tableView.reloadData()
                } else {
                    print("Error Getting Friends \(error)");
                }
            }
        }
        
        tableView.separatorColor = designs.colors.theme;
        tableView.tableFooterView = UIView();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(listType == strings.listType.friends) {
            return friendsList.count;
        } else {
            return strings.rulebook.pointRules.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil) //Cell's Name
        tableView.registerNib(nib, forCellReuseIdentifier: "ListCell");
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as! ListTableViewCell
        
        if(listType == strings.listType.friends) {
            let name: String = (friendsList.objectAtIndex(indexPath.row) as! NSDictionary).valueForKey("name") as! String
            cell.contentLabel.text = name;
            let data = (friendsList.objectAtIndex(indexPath.row) as! NSDictionary).valueForKey("picData") as? NSDictionary
            let dataDict = data!["data"] as? NSDictionary
            let imageStringUrl = dataDict!["url"] as? String
            let imageUrl = NSURL(string: imageStringUrl!)
            let imageData = NSData(contentsOfURL: imageUrl!)
            cell.sideImage.image = UIImage(data: imageData!)!
            cell.sideImage.layer.cornerRadius = cell.sideImage.frame.size.width / 2;
            cell.sideImage.clipsToBounds = true;
            
        } else {
            cell.contentLabel.text = strings.rulebook.pointRules[indexPath.row];
            cell.contentLabel.font = cell.contentLabel.font.fontWithSize(13)

            cell.sideImage.transform = CGAffineTransformMakeScale(0.5, 0.5)
            cell.sideImage.backgroundColor = designs.colors.theme;
            cell.sideImage.layer.cornerRadius = (cell.sideImage.frame.height)/2;            
        }
        
        cell.preservesSuperviewLayoutMargins = false;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        
        return cell
    }
    
    func design() {
        closeButton.layer.shadowRadius = designs.button.shadowRadius;
        closeButton.layer.shadowOpacity = designs.button.shadowOpactiyLabels;
        closeButton.layer.shadowOffset = CGSizeZero;
        closeButton.layer.masksToBounds = false;
    }
    
    @IBAction func closeAction(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil);
    }

}
