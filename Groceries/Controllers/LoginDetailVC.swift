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

}


