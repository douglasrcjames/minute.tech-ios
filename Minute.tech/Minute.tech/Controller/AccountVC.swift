//
//  AccountVC.swift
//  Minute.tech
//
//  Created by Douglas James on 4/28/18.
//  Copyright © 2018 Minute.tech. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {

    private let REQUEST_SEGUE = "RequestVC"
    
    @IBAction func makeRequest(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.REQUEST_SEGUE, sender: nil)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
