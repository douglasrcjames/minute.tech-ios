//
//  AuthProvider.swift
//  Minute.technician
//
//  Created by Douglas James on 4/26/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void; //closure, for error alert with login

struct LoginErrorCode {
    
    static let INVALID_EMAIL = "Invalid email address, please provide a real email address.";
    static let WRONG_PASSWORD = "Wrong password, please enter the correct password.";
    static let PROBLEM_CONNECTING = "Problem connecting to database, please try later.";
    static let USER_NOT_FOUND = "User not found, please register.";
    static let EMAIL_ALREADY_IN_USE = "Email already in use, please use another email.";
    static let WEAK_PASSWORD = "Password should be at least 6 characters long.";
    
}

class AuthProvider {
    private static let _instance = AuthProvider();
    
    static var Instance: AuthProvider {
        return _instance;
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            } else {
                loginHandler?(nil);
            }
        }
    }//login func
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
            } else {
                if user?.uid != nil {
                    
                    //store user to database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    
                    //login user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                    
                }
            }
            
        }
    } //sign up function
    
    func logout() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?){
        if let errCode = AuthErrorCode(rawValue: err.code){
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD);
                break;
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
    }
} //class
