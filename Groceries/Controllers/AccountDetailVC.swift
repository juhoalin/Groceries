//
//  AccountDetailVC.swift
//  Groceries
//
//  Created by Juho Alin on 10.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//



import UIKit
import IQKeyboardManagerSwift

class AccountDetailVC: UITableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
    var emailAddress = ""
    var password = ""
    var confirmPAssword = ""
    
    var registerVC = RegisterVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        birthTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        
        registerVC.delegate = self
        
        
    }
    


}

//MARK: - Capturing textfield data

extension AccountDetailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            
            return IQKeyboardManager.shared.goNext()

        } else {
            
            return textField.resignFirstResponder()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
                
        if textField == firstNameTextField && firstNameTextField.text != nil {
            firstName = firstNameTextField.text!
            print(firstName)
       
        } else if textField == lastNameTextField && lastNameTextField.text != nil {
            lastName = lastNameTextField.text!
            print(lastName)
   
        } else if textField == birthTextField && birthTextField.text != nil {
            dateOfBirth = birthTextField.text!
            print(dateOfBirth)
  
        } else if textField == emailTextField && emailTextField.text != nil {
            emailAddress = emailTextField.text!
            print(emailAddress)
   
        } else if textField == passwordTextField && passwordTextField.text != nil {
            password = passwordTextField.text!
            print(password.count)

        } else if textField == confirmTextField && confirmTextField.text != nil {
            confirmPAssword = confirmTextField.text!
            
            if confirmPAssword != password {
                let alert = UIAlertController(title: "Wrong password", message: "Confirming password does not match your password", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                alert.view.tintColor = UIColor(named: K.mazarineBlue)
                
                self.present(alert, animated: true, completion: nil)
                
                confirmTextField.text = ""
            }
            
            print(confirmPAssword.count)
       
        }
        
    }
    
}

//MARK: - DetailsDelegate methods

extension AccountDetailVC: DetailsDelegate {
    
    func updateDetails() {
        
        print("Updated details")
        
        registerVC.firstName = firstName
        registerVC.lastName = lastName
        registerVC.dateOfBirth = dateOfBirth
        registerVC.email = emailAddress
        registerVC.password = password
        registerVC.confirmPassword = confirmPAssword
    
    }
    
    func emptyTextFields() {
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        birthTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmTextField.text = ""
    }
    
}

