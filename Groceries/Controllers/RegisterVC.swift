//
//  RegisterVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
  
    @IBOutlet weak var registerButton: UIButton!
   
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.backgroundColor = .white
        registerButton.setTitleColor(UIColor(named: K.mazarineBlue), for: .normal)
        adjustButtonBorders(button: registerButton, cornerRadius: 25, borderWidth: 3, borderColorName: K.mazarineBlue)
        
        
                
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
    }
    
}

extension RegisterVC {
        
    func adjustButtonBorders(button: UIButton, cornerRadius: CGFloat?, borderWidth: CGFloat?, borderColorName: String?) {
    
    if let cd = cornerRadius, let bw = borderWidth, let bcn = borderColorName {
        button.layer.cornerRadius = cd
        button.layer.borderWidth = bw
        button.layer.borderColor = UIColor(named: bcn)?.cgColor
    }
        
}

}
