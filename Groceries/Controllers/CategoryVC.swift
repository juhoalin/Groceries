//
//  CategoryVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit
import Firebase

class CategoryVC: UITableViewController {
    
    var categoryArray: [FSCategoryModel] = []
    
    var selectedCategory: String?
  
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = "Groceries"
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(named: K.mazarineBlue)
        appearance.titleTextAttributes = [.font: UIFont(name: "Pacifico-Regular", size: 19) ?? UIFont.systemFont(ofSize: UIFont.systemFontSize), .foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.tableFooterView = UIView()
        
    
        
            loadCategories()
        

    }
    
    //MARK: - Buttons pressed

    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
             let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                print("User signed out")
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError.localizedDescription)")
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
   
        present(alert, animated: true, completion: nil)
          
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Create a New Category", message: "Organize your tasks", preferredStyle: .alert)
        
        var alertTextField = UITextField()
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Groceries"
            alertTextField = textfield
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let text = alertTextField.text, text.isEmpty == false {
                print("Added new category")
                self.addCategory(with: text)
                self.tableView.reloadData()
                
               
            } else {
                print("Could not add new category")
                return
            }
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTitle = categoryArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = currentTitle.name
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        
        cell.textLabel?.textColor = UIColor(named: K.mazarineBlue)
        
        return cell
        
    }
    
    //MARK: - Tablew View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        selectedCategory = cell?.textLabel?.text
        
        performSegue(withIdentifier: K.categoryToItem, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
    
    
    //MARK: - FireBase data handling
    
    let currentUser = Auth.auth().currentUser?.uid
    
    func loadCategories() {
        
        if let user = currentUser {
        
            db.collection(K.Firebase.users).document(user).collection(K.Firebase.categories).order(by: K.Firebase.date, descending: false)
                .addSnapshotListener { (querySnapshot, error) in
                    
                    if let e = error {
                        print("Error loading categories from Firestore \(e)")
                    } else {
                        self.categoryArray = []
                        
                        if let categories = querySnapshot?.documents {
                            for cat in categories {
                                let data = cat.data()
                                if let categoryName = data[K.Firebase.name] as? String {
                                    
                                    self.categoryArray.append(FSCategoryModel(name: categoryName))
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        let indexPath = IndexPath(item: self.categoryArray.count - 1, section: 0)
                                        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                                    }
                                    
                                }
                            }
                        }
                    }
                    
            }
            
        }
        
    }
    
    func addCategory(with title: String?) {
        
        if let name = title {
            if let user = Auth.auth().currentUser?.uid {
                
                db.collection(K.Firebase.users).document(user).collection(K.Firebase.categories).document(name).setData([K.Firebase.name: name, K.Firebase.date: Date().timeIntervalSince1970]) { (error) in
                    if let e = error {
                        print("Error adding new category \(e)")
                    } else {
                        print("Succesfully added new category")
                    }
                }

                
            }
                        
        }
    }
    
    //MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.categoryToItem {
            if let destinationVC = segue.destination as? ItemVC {
                if let category = selectedCategory {
                    destinationVC.currentCategory = category
                } else {
                    destinationVC.currentCategory = "Items"
                }
            }
        }
    }

}

