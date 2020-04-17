//
//  LoginDetailVC.swift
//  Groceries
//
//  Created by Juho Alin on 10.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class LoginDetailVC: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
   
    @IBOutlet weak var passwordTextField: UITextField!
    
    var emailAddress = "juhoalin@icloud.com"
    var password = "123456"
    
    var loginVC = LoginVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        tableView.tableFooterView = UIView()
   

    }


}

extension LoginDetailVC: UITextFieldDelegate {

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField.returnKeyType == .next {
        
        return IQKeyboardManager.shared.goNext()

    } else {
        
        return textField.resignFirstResponder()
    }
    
}
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == emailTextField && emailTextField.text != nil {
            emailAddress = emailTextField.text!
            print(emailAddress)
        } else if textField == passwordTextField && passwordTextField.text != nil {
            password = passwordTextField.text!
            print(password)
        }
    }

}

extension LoginDetailVC: LoginDelegate {
    
    func updateDetails() {
        
        loginVC.emailAddress = emailAddress
        loginVC.password = password
        
        print("Login details updated")
        
    }
    
    func deleteDetails() {
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    
    
    
}


