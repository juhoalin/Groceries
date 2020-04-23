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
    
    var filteredItems: [FSItemModel] = []
    
    let db = Firestore.firestore()
    
    let currentUser = Auth.auth().currentUser?.uid
    
    let toolBarButton = UIButton(type: .system)
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    var currentCategory: String? {
        didSet {
            loadItems()
            
           
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
            navigationController?.isToolbarHidden = false
        
            toolBarButton.addTarget(self, action: #selector(toolbarButtonAction(_:)), for: .touchUpInside)
            
            toolBarButton.semanticContentAttribute = .forceLeftToRight
            toolBarButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            toolBarButton.setAttributedTitle(NSAttributedString(string: "New Item", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor(named: K.mazarineBlue)!]), for: .normal)
            toolBarButton.tintColor = UIColor(named: K.mazarineBlue)
            toolBarButton.titleEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
            toolBarButton.sizeToFit()
            
            toolbarItems = [UIBarButtonItem(customView: toolBarButton)]
            
            navigationController?.toolbar.contentMode = .left
            
            let defaultToolbarAppearance = UIToolbarAppearance()
            defaultToolbarAppearance.configureWithTransparentBackground()
            defaultToolbarAppearance.backgroundEffect = UIBlurEffect(style: .extraLight)
            defaultToolbarAppearance.backgroundColor = .white
        
            navigationController?.toolbar.standardAppearance = defaultToolbarAppearance

        
        navigationItem.title = currentCategory
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(named: K.mazarineBlue)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.tableFooterView = UIView()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        


    }
    
    //MARK: - Buttons pressed
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        searchController.searchBar.becomeFirstResponder()
        
    }
    
    @objc func toolbarButtonAction(_ sender: UIButton!) {
        
        print("Add items button pressed")
        
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        var alertTextField = UITextField()
        
        alert.addTextField { (textField) in
            textField.placeholder = "Cereals"
            alertTextField = textField
            
            
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
                        
            if let text = alertTextField.text, text.isEmpty == false {
                
                let itemExists = self.itemArray.contains { (Item) -> Bool in
                    if alertTextField.text == Item.name {
                        return true
                    } else {
                        return false
                    }
                }
                
                if itemExists {
                    self.addBasicAlert(title: "Item Already Exists", message: "Give a different name for your item", present: alert)
                } else {
                    self.addItem(with: text, done: false)
                      self.tableView.reloadData()
                      print("Added new Item")
                      
                }
                
            }
            
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if isFiltering {
            return filteredItems.count
        }
        
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: FSItemModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellIdentifier, for: indexPath)
        
        if isFiltering {
            item = filteredItems[indexPath.row]
        } else {
            item = itemArray[indexPath.row]
        }
        
        cell.textLabel?.text = item.name
        cell.accessoryType = item.done ? .checkmark : .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.textLabel?.textColor = UIColor(named: K.mazarineBlue)
        cell.tintColor = UIColor(named: K.mazarineBlue)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Table View Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item: FSItemModel
        
        if isFiltering {
            item = filteredItems[indexPath.row]
            
        } else {
            item = itemArray[indexPath.row]
        }
        
        item.done = !item.done
        
        changeCheckmark(from: item)
        
        
        DispatchQueue.main.async {
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let tableviewCell = tableView.cellForRow(at: indexPath)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            if self.isFiltering {
                self.filteredItems.remove(at: indexPath.row)
            } else {
                self.itemArray.remove(at: indexPath.row)
            }
            
            if let userID = self.currentUser, let cell = tableviewCell, let item = cell.textLabel?.text, let category = self.currentCategory {
                
                self.db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).collection(K.Firebase.items).document(item).delete { (error) in
                    if let e = error {
                        print("Error deleting item \(e)")
                    } else {
                        print("Item deleted succesfully")
                    }
                }
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            
            
        }
        
        deleteAction.backgroundColor = UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 1.00)
        deleteAction.image = UIImage(systemName: "trash.circle.fill")
        
        editAction.backgroundColor = .lightGray
        editAction.image = UIImage(systemName: "ellipsis.circle.fill")

        
        let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        swipeActionConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeActionConfiguration
        
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
                                if self.isFiltering == false {
                                self.tableView.reloadData()
                                }
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
                                        
                    DispatchQueue.main.async {
                    let indexPath = IndexPath(item: self.itemArray.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    }
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
                    if self.isFiltering {
                        self.searchController.searchBar.becomeFirstResponder()
                        self.searchController.searchBar.resignFirstResponder()
                    }

                }
            }
            
        }

        
    }
    
}

//MARK: - SearchBar methods


extension ItemVC: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        filteredItems = itemArray.filter({ (Item) -> Bool in
            return Item.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
        
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.scrollsToTop = false
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        navigationController?.isToolbarHidden = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationController?.isToolbarHidden = false
    }
    
    
    
}

extension ItemVC {
    
    func addBasicAlert(title name: String, message description: String? = nil, present newAlert: UIAlertController) {
        
        let alert = UIAlertController(title: name, message: description, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.present(newAlert, animated: true, completion: nil)
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
