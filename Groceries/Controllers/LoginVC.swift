//
//  LoginVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView?.tintColor = .white
        
        loginButton.layer.cornerRadius = 25
        

    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
    }
    
    
}
