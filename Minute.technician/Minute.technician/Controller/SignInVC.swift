//
//  SignInVC.swift
//  Minute.technician
//
//  Created by Douglas James on 4/25/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController, UITextFieldDelegate {
    
    private let ACCOUNT_SEGUE = "AccountVC"
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self;
        self.passwordTextField.delegate = self;
    }
    
    //hidekeyboaard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    @IBAction func login(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!) { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem with Authentication", message: message!);
                } else {
                    RequestHandler.Instance.technician = self.emailTextField.text!;
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    self.performSegue(withIdentifier: self.ACCOUNT_SEGUE, sender: nil)
                }
            }
            
        } else {
            alertTheUser(title: "Email and password are required.", message: "Please enter email and password into text fields.")
        }
    }
    
    @IBAction func signup(_ sender: UIButton) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!) { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem with creating a new user.", message: message!)
                } else {
                    RequestHandler.Instance.technician = self.emailTextField.text!;
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    self.performSegue(withIdentifier: self.ACCOUNT_SEGUE, sender: nil)
                    print("User created successfully!")
                }
            }
        } else {
            alertTheUser(title: "Email and password are required.", message: "Please enter email and password into text fields.")
        }
    
    }
    
    private func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
} //class
