//
//  ViewController.swift
//  Todo-CoreData
//
//  Created by Yilmaz Edis (employee ID: y84185251) on 7.12.2021.
//
import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray: Results<Item>?
    let realm = try! Realm()

    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            if let navBarColour = UIColor(hexString: colourHex) {
                let titleColour = ContrastColorOf(navBarColour, returnFlat: true)
                let title = selectedCategory!.name

                configureNavigationBar(largeTitleColor: titleColour, backgoundColor: navBarColour, tintColor: titleColour, title: title, preferredLargeTitle: true)

                searchBar.barTintColor = navBarColour
            }
        }
    }

    //MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = itemArray![indexPath.row]

        cell.textLabel?.text = item.title
        if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }

    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = itemArray![indexPath.row]
        do {
            try realm.write{
                // realm.delete(item)
                item.done = !item.done
            }
        } catch {
            print("Error saving done status, \(error)")
        }


        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

       var textField = UITextField()
       let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
       let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
           //what will happen once the user clicks the Add Item button on our UIAlert
           if let currentCategory = self.selectedCategory {
               do {
                   try self.realm.write {
                       let newItem = Item()
                       newItem.title = textField.text!
                       newItem.dateCreated = Date()
                       currentCategory.items.append(newItem)
                   }
               } catch {
                   print("Error saving new items, \(error)")
               }
           }
           self.tableView.reloadData()
       }

       alert.addTextField { (alertTextField) in
           alertTextField.placeholder = "Create new item"
           textField = alertTextField
       }

       alert.addAction(action)
       present(alert, animated: true, completion: nil)
    }


    //MARK - Model Manupulation Methods

    func loadItems() {

        itemArray = (selectedCategory?.items.sorted(byKeyPath: "title", ascending: true))!
        tableView.reloadData()

    }

    //Mark: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        let item = itemArray![indexPath.row]
        do {
            try realm.write{
                realm.delete(item)
            }
        } catch {
            print("Error deleting item, \(error)")
        }
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray!.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}








