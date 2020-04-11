//
//  AccountDetailVC.swift
//  Groceries
//
//  Created by Juho Alin on 10.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit

class AccountDetailVC: UITableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var birthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

}
