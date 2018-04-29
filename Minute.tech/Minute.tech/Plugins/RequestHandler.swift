//
//  TechnicianHandler.swift
//  Minute.tech
//
//  Created by Douglas James on 4/27/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import Foundation
import FirebaseDatabase

//delegates
protocol RequestController: class {
    func canCallTechnician(delegateCalled: Bool);
    func technicianAcceptedRequest(requestAccepted: Bool, technicianName: String);
    func updateTechniciansLocation(lat: Double, long: Double);
}

class RequestHandler {
    private static let _instance = RequestHandler();
    weak var delegate: RequestController?;
    var client = "";
    var technician = "";
    var client_id = "";
    
    static var Instance: RequestHandler{
        return _instance;
    }
    
    func observeMessagesForRider() {
        // CLIENT REQUESTED TECHNICIAN
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.client {
                        self.client_id = snapshot.key;
                        self.delegate?.canCallTechnician(delegateCalled: true);
                    }
                }
            }
        }

        // CLIENT CANCELED TECHNICIAN
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.client {
                        self.delegate?.canCallTechnician(delegateCalled: false);
                    }
                }
            }
        }
        // TECHNICIAN ACCEPTED REQUEST
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.technician == "" {
                        self.technician = name; //get the technician name and put into the technician variable, WE WILL WANT TO SHOW THIS1
                        self.delegate?.technicianAcceptedRequest(requestAccepted: true, technicianName: self.technician)
                        
                    }
                }
            }
        }
        
        // TECHNICIAN ACCEPTED REQUEST
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.technician{
                        self.technician = "";
                        self.delegate?.technicianAcceptedRequest(requestAccepted: false, technicianName: name);
                        
                    }
                }
            }
        }
        
        // TECHNICIAN UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.technician{
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateTechniciansLocation(lat: lat, long: long);
                            }
                        }
                    }
                }
            }
        }
        
    }
    

    
    
    func requestTechnician(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: client, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data);
    } //request technician
    
    func cancelTechnician() {
        DBProvider.Instance.requestRef.child(client_id).removeValue(); //find the id in the databse and remove it
    }
    
    func updateClientLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(client_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
}
