//
//  ClientVC.swift
//  Minute.tech
//
//  Created by Douglas James on 4/26/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import UIKit
import MapKit

class RequestVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, RequestController {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var callTechnicianBtn: UIButton!
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var technicianLocation: CLLocationCoordinate2D?;
    private var timer = Timer();
    private var canCallTechnician = true;
    private var clientCanceledRequest = false;
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        initializeLocationManager();
        RequestHandler.Instance.observeMessagesForRider(); //start listerning to database, and spying on whats going on inside
        RequestHandler.Instance.delegate = self;
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.001)) //think of these as the "zoom"
            myMap.setRegion(region, animated: true);
            myMap.removeAnnotations(myMap.annotations)
            
            if technicianLocation != nil {
                if !canCallTechnician {
                    let technicianAnnotation = MKPointAnnotation();
                    technicianAnnotation.coordinate = technicianLocation!;
                    technicianAnnotation.title = "Technician's location";
                    myMap.addAnnotation(technicianAnnotation);
                    
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Your Location";
            myMap.addAnnotation(annotation)
        }
    }
    
    @objc func updateClientsLocation() {
        RequestHandler.Instance.updateClientLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    func canCallTechnician(delegateCalled: Bool) {
        if delegateCalled {
            callTechnicianBtn.setTitle("Cancel Technician", for: UIControlState.normal);
            canCallTechnician = false;
        } else {
            callTechnicianBtn.setTitle("Call Technician", for: UIControlState.normal);
            canCallTechnician = true;
        }
    }
    
    func technicianAcceptedRequest(requestAccepted: Bool, technicianName: String) {
        if !clientCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Request accepted.", message: "\(technicianName) accepted your request.")
            } else {
                RequestHandler.Instance.cancelTechnician();
                timer.invalidate();
                alertTheUser(title: "Request canceled", message: "\(technicianName) canceled your request.")
            }
        }
        clientCanceledRequest = false;
    }
    
    func updateTechniciansLocation(lat: Double, long: Double) {
        technicianLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    @IBAction func callTechnician(_ sender: UIButton) {
        if userLocation != nil {
            if canCallTechnician {
                RequestHandler.Instance.requestTechnician(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude)); //providing the location to technician to find you
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(RequestVC.updateClientsLocation), userInfo: nil, repeats: true);
            } else {
                // cancel technician
                clientCanceledRequest = true;
                RequestHandler.Instance.cancelTechnician();
                timer.invalidate();
            }
        }
        
    }

    @IBAction func goBack(_ sender: Any) {
        if AuthProvider.Instance.logout() {
            if !canCallTechnician {
                RequestHandler.Instance.cancelTechnician();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            alertTheUser(title: "Could not go back.", message: "We could not go back at the moment, please try again later.");
            // problem with log out
        }
    }
    

    
    private func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
} //class
