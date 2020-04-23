//
//  ViewController.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.isHidden = true
        
        
        registerButton.backgroundColor = UIColor.white
        registerButton.setTitleColor(UIColor(named: K.mazarineBlue), for: .normal)
        loginButton.layer.cornerRadius = 25
        
        adjustButtonBorders(button: registerButton, cornerRadius: 25, borderWidth: 3, borderColorName: K.mazarineBlue)
        
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
    }
    
}

extension WelcomeVC {
    
    func adjustButtonBorders(button: UIButton, cornerRadius: CGFloat?, borderWidth: CGFloat?, borderColorName: String?) {
        
        if let cd = cornerRadius, let bw = borderWidth, let bcn = borderColorName {
            button.layer.cornerRadius = cd
            button.layer.borderWidth = bw
            button.layer.borderColor = UIColor(named: bcn)?.cgColor
        }
       
        
    }
    
}

