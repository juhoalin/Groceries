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
    
    var filteredCategories: [FSCategoryModel] = []
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    var selectedCategory: String?
  
    let db = Firestore.firestore()
    
    let toolBarButton = UIButton(type: .system)
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = false
        
        toolBarButton.addTarget(self, action: #selector(toolbarButtonAction(_:)), for: .touchUpInside)
        
        toolBarButton.semanticContentAttribute = .forceLeftToRight
        toolBarButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        toolBarButton.setAttributedTitle(NSAttributedString(string: "New Category", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor(named: K.mazarineBlue)!]), for: .normal)
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
        
        
        navigationItem.title = "Categories"
        navigationItem.largeTitleDisplayMode = .always
        
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
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        
        
            
        
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
        
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        
        
    }
    
    @objc func toolbarButtonAction(_ sender: UIButton!) {
        
        print("ToolbarButton tapped")
        
        let alert = UIAlertController(title: "Create a New Category", message: "Organize your tasks", preferredStyle: .alert)
        
        var alertTextField = UITextField()
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Groceries"
            
            alertTextField = textfield

        }
 
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let text = alertTextField.text, text.isEmpty == false {
                
                 let categoryExists = self.categoryArray.contains { (Category) -> Bool in
                     if alertTextField.text == Category.name {
                         return true
                     } else {
                         return false
                     }
                 }
            
                if categoryExists {
                    self.addBasicAlert(title: "Category Already Exists", message: "Give a different name for your category", present: alert)
                } else {
                    print("Added new category")
                    self.addCategory(with: text)
                    self.tableView.reloadData()

                }
            }
            
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }

    
    
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredCategories.count
        }
        
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath)
                
        let category: FSCategoryModel
        
        if isFiltering {
            category = filteredCategories[indexPath.row]
        } else {
            category = categoryArray[indexPath.row]
        }
        
        cell.textLabel?.text = category.name
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        cell.textLabel?.textColor = UIColor(named: K.mazarineBlue)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    //MARK: - Tablew View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        selectedCategory = cell?.textLabel?.text
        
        performSegue(withIdentifier: K.categoryToItem, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tableviewCell = tableView.cellForRow(at: indexPath)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
                if self.isFiltering {
                    self.filteredCategories.remove(at: indexPath.row)
                } else {
                    self.categoryArray.remove(at: indexPath.row)
                }
                
                if let userID = self.currentUser, let cell = tableviewCell, let category = cell.textLabel?.text {
                    self.db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).collection(K.Firebase.items).getDocuments { (QuerySnapshot, error) in
                        if let e = error {
                            print("Error deleting category items \(e)")
                        } else {
                        if let documents = QuerySnapshot?.documents {
                            for doc in documents {
                                doc.reference.delete()
                            }
                          }
                            print("Succesfully deleted category items")
                            
                            self.db.collection(K.Firebase.users).document(userID).collection(K.Firebase.categories).document(category).delete { (error) in
                            if let e = error {
                                print("Error deleting category \(e)")
                            } else {
                                print("Succesfully deleted category")
                            }
                       }
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
    
    func addCategory(with title: String?) {
        
        if let name = title {
            if let user = Auth.auth().currentUser?.uid {
                
                db.collection(K.Firebase.users).document(user).collection(K.Firebase.categories).document(name).setData([K.Firebase.name: name, K.Firebase.date: Date().timeIntervalSince1970]) { (error) in
                    if let e = error {
                        print("Error adding new category \(e)")
                    } else {
                        print("Succesfully added new category")
                        
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(item: self.categoryArray.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
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


//MARK: - Updating and filtering search results

extension CategoryVC: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        
        filteredCategories = categoryArray.filter({ (Category) -> Bool in
            return Category.name.lowercased().contains(searchText.lowercased())
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

//MARK: - State restoring methods

extension CategoryVC {
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
    }
}

extension CategoryVC {
    
    func addBasicAlert(title name: String, message description: String? = nil, present newAlert: UIAlertController) {
        
        let alert = UIAlertController(title: name, message: description, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.present(newAlert, animated: true, completion: nil)
        }))
        
        alert.view.tintColor = UIColor(named: K.mazarineBlue)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}


