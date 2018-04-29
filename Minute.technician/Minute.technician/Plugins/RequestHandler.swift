//
//  TechnicianHandler.swift
//  Minute.technician
//
//  Created by Douglas James on 4/27/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol RequestController: class {
    func acceptRequest(lat: Double, long: Double); //tasks to give (doesnt care who does them)
    func clientCanceledRequest();
    func requestCanceled();
    func updateClientsLocation(lat: Double, long: Double);
}

class RequestHandler {
    private static let _instance = RequestHandler();
    weak var delegate: RequestController?; //saying that we will be the one to intercept the data for the protocol
    var client = "";
    var technician = "";
    var technician_id = "";
    static var Instance: RequestHandler{
        return _instance;
    }
    
    func observeMessagesForTechnician() {
        // CLIENT REQUESTED REQUEST
        //grab data from technician_requested in DB
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            //is that value a dictionary?
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        // inform the technician vc about the request (using protocol and delegation)
                        self.delegate?.acceptRequest(lat: latitude, long: longitude);
                        //put into ticket list
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.client = name;
                }
            }
            // CLIENT CANCELED REQUEST
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshoit: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.client {
                            self.client = ""
                            self.delegate?.clientCanceledRequest();
                        }
                    }
                }
            });
        }
        
        // CLIENT UPDATING LOCATION
        DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double{
                    if let long = data[Constants.LONGITUDE] as? Double{
                        self.delegate?.updateClientsLocation(lat: lat, long: long)
                    }
                }
            }
        }
        
        
        // TECHNICIAN ACCEPTS REQUEST
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.technician {
                        self.technician_id = snapshot.key;
                    }
                }
            }
        }
        
        // TECHNICIAN CANCELS REQUEST
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.technician {
                        //if we are the technician that has currently canceled the request
                        self.delegate?.requestCanceled(); //inform client
                    }
                }
            }
        }
        
    } //observe messages for technician
    
    func technicianAccepted(lat: Double, long: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: technician, Constants.LATITUDE: lat, Constants.LONGITUDE: long];
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
    }
    
    func cancelRequestForTechnician() {
        DBProvider.Instance.requestAcceptedRef.child(technician_id).removeValue();
    }
    
    func updateTechnicianLocation(lat: Double, long: Double){
        DBProvider.Instance.requestAcceptedRef.child(technician_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
}
