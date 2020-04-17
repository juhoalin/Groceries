//
//  ItemVC.swift
//  Groceries
//
//  Created by Juho Alin on 9.4.2020.
//  Copyright © 2020 Juho Alin. All rights reserved.
//

import UIKit
import Firebase

class ItemVC: UITableViewController {
    
    var itemArray: [FSItemModel] = []
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser?.uid
    
    var currentCategory: String? {
        didSet {
            loadItems()
            
           
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = currentCategory
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(named: K.mazarineBlue)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.tableFooterView = UIView()


    }
    
    //MARK: - Buttons pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        var alertTextField = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Cereals"
            alertTextField = textField
            
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let text = alertTextField.text, text.isEmpty == false {
                self.addItem(with: text, done: false)
                self.tableView.reloadData()
                print("Added new Item")
                
            } else {
                print("Could not add new Item")
            }
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = item.name
        cell.accessoryType = item.done ? .checkmark : .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.textLabel?.textColor = UIColor(named: K.mazarineBlue)
        
        return cell
    }
    
    //MARK: - Table View Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        changeCheckmark(from: itemArray[indexPath.row])
        
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK: - Firestore data methods
    
    func loadItems() {
        
        if let userID = currentUser, let category = currentCategory {
        
            db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).collection(K.Firebase.items).order(by: K.Firebase.date, descending: false).addSnapshotListener { (QuerySnapshot, error) in
                if let e = error {
                    print("Error loading items \(e.localizedDescription)")
                } else {
                    self.itemArray = []
                    
                   if let items = QuerySnapshot?.documents {
                    for item in items {
                        let data = item.data()
                        if let itemName = data[K.Firebase.name] as? String, let done = data[K.Firebase.done] as? Bool {
                            self.itemArray.append(FSItemModel(name: itemName, done: done))
                            print("Updated items")
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(item: self.itemArray.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
                            }
                        }
                    }
                    }
                }
            }
        
        }
    }
    
    
    func addItem(with title: String?, done checkmark: Bool?) {
        
        if let userID = currentUser, let category = currentCategory, let name = title, let accessory = checkmark {
            
            db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).collection(K.Firebase.items).document(name).setData([K.Firebase.name: name, K.Firebase.done: accessory, K.Firebase.date: Date().timeIntervalSince1970]) { (error) in
                if let e = error {
                    print("Error adding new Item \(e.localizedDescription)")
                } else {
                    print("Successfully added new item")
                }
            }
            
        }
        
    }
    
    func changeCheckmark(from item: FSItemModel) {
        
        if let userID = currentUser, let category = currentCategory {
            
            db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).collection(K.Firebase.items).document(item.name).updateData([K.Firebase.done: item.done]) { (error) in
                if let e = error {
                    print("Error changing checkmark \(e.localizedDescription)")
                } else {
                    print("Checkmark changed in Firestore")
                }
            }
            
        }

        
    }
    
}
