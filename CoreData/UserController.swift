//
//  UserController.swift
//  Bastobe
//
//  Created by Akib Shahjahan on 2016-08-13.
//  Copyright © 2016 Akib Shahjahan. All rights reserved.
//

import Foundation
import CoreData


func getLocalUsers() -> [NSManagedObject] {
    //1
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    //2
    let fetchRequest = NSFetchRequest(entityName: "User")
    do {
        let results =
            try managedContext.executeFetchRequest(fetchRequest)
        let user = results as! [NSManagedObject]
        return user;
    } catch let error as NSError {
        print("Could not fetch \(error), \(error.userInfo)")
        return [];
    }
}

func getLocalUserPoints() -> Int {
    var users = getLocalUsers();
    if(users == []) { return 0; }
    return (users[0].valueForKey("points") as? Int)!;
}

func setLocalUserPoints(points: Int) {
    let getUser = getLocalUsers();
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    
    let managedContext = appDelegate.managedObjectContext
    if(getUser == []) {
    
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
    
        let newUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        newUser.setValue(points, forKey: "points")
        
        do {
            try managedContext.save()
        } catch _ as NSError  {
            // ERROR
        }
    } else {
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            let user = results as! [NSManagedObject]
            user[0].setValue(points, forKey: "points");
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

func getLocalUserLastLocation() -> String {
    var users = getLocalUsers();
    print(users);
    if(users == [] || users[0].valueForKey("lastLocation") == nil) { return ""; }
    return (users[0].valueForKey("lastLocation") as? String)!;
}

func setLocalUserLastLocation(location: String) {
    let getUser = getLocalUsers();
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    
    let managedContext = appDelegate.managedObjectContext
    if(getUser == []) {
        
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext:managedContext)
        
        let newUser = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        newUser.setValue(location, forKey: "lastLocation")
        
        do {
            try managedContext.save()
        } catch _ as NSError  {
            // ERROR
        }
    } else {
        let fetchRequest = NSFetchRequest(entityName: "User")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            let user = results as! [NSManagedObject]
            user[0].setValue(location, forKey: "lastLocation");
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}