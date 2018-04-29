//
//  TechnicianVC.swift
//  Minute.technician
//
//  Created by Douglas James on 4/26/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import UIKit
import MapKit
class RequestVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, RequestController {

    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var acceptTechnicianBtn: UIButton!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var clientLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer(); //timer repeats something like a function over and over again
    
    private var acceptedTechnician = false;
    private var technicianCanceledRequest = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        RequestHandler.Instance.delegate = self;
        RequestHandler.Instance.observeMessagesForTechnician();
        // Do any additional setup after loading the view.
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
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)) //think of these as the "zoom"
            myMap.setRegion(region, animated: true);
            myMap.removeAnnotations(myMap.annotations)
            if clientLocation != nil {
                if acceptedTechnician {
                    print("WE MADE IT IN THERE")
                    let clientAnnotation = MKPointAnnotation();
                    clientAnnotation.coordinate = clientLocation!;
                    clientAnnotation.title = "Client's Location"
                    myMap.addAnnotation(clientAnnotation);
                }
            }
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Your Location";
            myMap.addAnnotation(annotation)
        }
    }
    
    func acceptRequest(lat: Double, long: Double) {
        if !acceptedTechnician {
            technicianRequest(title: "Technician request", message: "You have a request for a Minute.technician at this location: Latitude of \(lat), & Longitude of \(long)", requestAlive: true)
        }
    }
    
    //change to canceledRequest (protocol)
    func clientCanceledRequest() {
        if technicianCanceledRequest {
            RequestHandler.Instance.cancelRequestForTechnician();// cancel request from technicians perspective
            self.acceptedTechnician = false;
            self.acceptTechnicianBtn.isHidden = true;
            technicianRequest(title: "Request canceled.", message: "The client canceled the request.", requestAlive: false);
        }
    }
    
    func requestCanceled() {
        acceptedTechnician = false;
        acceptTechnicianBtn.isHidden = true;
        timer.invalidate();
    }
    
    func updateClientsLocation(lat: Double, long: Double){
        clientLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    //xcode told me to add @objc, might have been a mistake
    @objc func updateTechnicianLocation() {
        RequestHandler.Instance.updateTechnicianLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    @IBAction func cancelRequest(_ sender: UIButton) {
        view.sendSubview(toBack: myMap)
        if acceptedTechnician {
            technicianCanceledRequest = true;
            acceptTechnicianBtn.isHidden = true;
            RequestHandler.Instance.cancelRequestForTechnician();
            timer.invalidate();
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        if AuthProvider.Instance.logout() {
            if acceptedTechnician {
                // so if user goes back, the request is canceled if its live
                acceptTechnicianBtn.isHidden = true;
                RequestHandler.Instance.cancelRequestForTechnician();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            technicianRequest(title: "Could not go back.", message: "We could not go back at the moment, please try again later.", requestAlive: false)
        }
    }
    
    private func technicianRequest(title: String, message: String, requestAlive: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: {(alertAction: UIAlertAction) in
                
                self.acceptedTechnician = true;
                self.acceptTechnicianBtn.isHidden = false;
                //this shouldnt be 5 seconds, for battery consumption
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(5), target: self, selector: #selector(RequestVC.updateTechnicianLocation), userInfo: nil, repeats: true);
                //inform that we accepted the technician request
                RequestHandler.Instance.technicianAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude));
            });
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(accept);
            alert.addAction(cancel);
        } else {
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil);
            alert.addAction(ok);
        }
        
        present(alert,animated: true, completion: nil);
        //add user request to pool
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}//class
