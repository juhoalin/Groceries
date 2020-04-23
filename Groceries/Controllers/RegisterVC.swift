//
//  RegisterVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

protocol DetailsDelegate {
    func updateDetails()
    
    func emptyTextFields()
}

class RegisterVC: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    
    
    let db = Firestore.firestore()
    
    
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.backgroundColor = .white
        registerButton.setTitleColor(UIColor(named: K.mazarineBlue), for: .normal)
        adjustButtonBorders(button: registerButton, cornerRadius: 25, borderWidth: 3, borderColorName: K.mazarineBlue)
    
    let appearance = UINavigationBarAppearance()
    
    navigationItem.title = "Register"
    
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = UIColor(named: K.mazarineBlue)
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    
    navigationItem.standardAppearance = appearance
    
    navigationItem.scrollEdgeAppearance = appearance
    
    IQKeyboardManager.shared.enable = false
    IQKeyboardManager.shared.enableAutoToolbar = false


    }
    
    //MARK: - Saving Registeration Data
        
    var delegate: DetailsDelegate?
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
  
        delegate?.updateDetails()
               
        if password == confirmPassword {
        
        Auth.auth().createUser(withEmail: email, password: confirmPassword) { (AuthDataResult, error) in
            if let e = error {
                print("Error in creating new user \(e.localizedDescription)")
                
                let alert = UIAlertController(title: "Something went wrong", message: e.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                alert.view.tintColor = UIColor(named: K.mazarineBlue)

                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                if let userID = Auth.auth().currentUser?.uid {
                
                self.db.collection("users").document("\(userID)").setData([
                    
                    "emailaddress": self.email,
                    "firstname": self.firstName,
                    "lastname": self.lastName,
                    "dateofbirth": self.dateOfBirth
                    
                ]) { (error) in
                    
                    if let e = error {
                        print("Error saving personal information \(e.localizedDescription)")
                        
                        let alert = UIAlertController(title: "Something went wrong", message: e.localizedDescription, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        alert.view.tintColor = UIColor(named: K.mazarineBlue)

                        
                        self.present(alert, animated: true, completion: nil)
                        

                    } else {
                        
                        self.db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document("Example Category").collection(K.Firebase.items).document("Example Item").setData(["name": "Example Item","done": false]) { (error) in
                            if let e = error {
                                let alert = UIAlertController(title: "Something went wrong", message: e.localizedDescription, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                
                                alert.view.tintColor = UIColor(named: K.mazarineBlue)
                                
                                self.present(alert, animated: true, completion: nil)

                            } else {
                                self.db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document("Example Category").setData(["name": "Example Category", "creationDate": Date().timeIntervalSince1970])
                                print("Successfully created new user")
                                self.performSegue(withIdentifier: K.registerToCategory, sender: self)
                                self.delegate?.emptyTextFields()

                            }
                        }
                        
                    }
                    
                }
                
                }
                }
            
            }
        }
        
        }         
    }
    


//MARK: - Additional functions and connetcting embedded tableview


extension RegisterVC {
        
    func adjustButtonBorders(button: UIButton, cornerRadius: CGFloat?, borderWidth: CGFloat?, borderColorName: String?) {
    
    if let cd = cornerRadius, let bw = borderWidth, let bcn = borderColorName {
        button.layer.cornerRadius = cd
        button.layer.borderWidth = bw
        button.layer.borderColor = UIColor(named: bcn)?.cgColor
    }
        
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.embedAccountDetails {
            if let detailVC = segue.destination as? AccountDetailVC {
                self.delegate = detailVC
                detailVC.registerVC = self
                print("Segue between VC:s")
            }
        }
    }
    

}

