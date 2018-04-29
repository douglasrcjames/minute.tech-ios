//
//  DBReference.swift
//  Minute.technician
//
//  Created by Douglas James on 4/27/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: DatabaseReference{
        return Database.database().reference();
    }
    
    var techniciansRef: DatabaseReference {
        return dbRef.child(Constants.TECHNICIANS)
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.TECHNICIAN_REQUEST);
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.TECHNICIAN_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, password: String){
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isClient: false];
        techniciansRef.child(withID).child(Constants.DATA).setValue(data)
    }
    
} //class (singleton also)
