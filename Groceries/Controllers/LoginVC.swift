//
//  LoginVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit
import Firebase

protocol LoginDelegate {
    
    func updateDetails()
    
    func deleteDetails()
    
}

class LoginVC: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    var emailAddress = ""
    var password = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginButton.layer.cornerRadius = 25
        
        navigationItem.title = "Login"
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(named: K.mazarineBlue)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        
        navigationItem.scrollEdgeAppearance = appearance

        

    }
    
    var delegate: LoginDelegate?
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        delegate?.updateDetails()
        print(emailAddress)
        
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (authResult, error) in
            if let e = error {
                
                let alert = UIAlertController(title: "Something went wrong", message: e.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                alert.view.tintColor = UIColor(named: K.mazarineBlue)

                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.performSegue(withIdentifier: K.loginToCategory, sender: self)
                self.delegate?.deleteDetails()
                print("Login successfull")
                
            }
        }
        
    }
    
    
}

extension LoginVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loginEmbedSegue {
            if let loginDetailsVC = segue.destination as? LoginDetailVC {
                
                self.delegate = loginDetailsVC
                loginDetailsVC.loginVC = self
                
                print("Login embed segue")
                
            }
        }
    }
    
}
