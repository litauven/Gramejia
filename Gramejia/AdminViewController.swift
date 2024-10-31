//
//  AdminViewController.swift
//  Gramejia
//
//  Created by prk on 02/10/24.
//

import UIKit
import CoreData

class AdminViewController: UIViewController {
    
//    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var ItemDescriptionTextField: UITextField!
    @IBOutlet weak var ItemBrandTextField: UITextField!
    @IBOutlet weak var ItemNameTextField: UITextField!
    @IBOutlet weak var ItemCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var ItemPriceTextField: UITextField!
    @IBOutlet weak var ItemURLTextField: UITextField!
    @IBOutlet weak var ItemIDLabel: UILabel!
    
    var itemCategory = "Notetaking"
    var username = ""
    var userID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        greetingLabel.text = "Welcome, \(username)"
        ItemIDLabel.lineBreakMode = .byWordWrapping
    }
    
    // MARK: - Segmented Control Action
    @IBAction func ItemCategoryOnSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            itemCategory = "Notetaking"
        case 1:
            itemCategory = "Painting"
        case 2:
            itemCategory = "Accessory"
        default:
            itemCategory = "Misc"
        }
    }
    
    // MARK: - Add Item Action
    @IBAction func AddItemOnClick(_ sender: Any) {
        guard let itemName = ItemNameTextField.text, !itemName.isEmpty else {
            print("Please fill in the item name")
            showAlert(title: "Error", message: "Please fill in the item name.")
            return
        }
        guard let ItemBrand = ItemBrandTextField.text, !ItemBrand.isEmpty else{
            print("Please fill in the item brand")
            showAlert(title: "Error", message: "please fill in the item brand")
            return
        }
        
        guard let itemPriceString = ItemPriceTextField.text, let itemPrice = Double(itemPriceString) else {
            print("Please input a valid price")
            showAlert(title: "Error", message: "Please input a valid price.")
            return
        }
        guard let ItemDescription = ItemDescriptionTextField.text,   !ItemDescription.isEmpty else{
            print("Please fill in the item Description")
            showAlert(title: "Error", message: "Please fill the item Description")
            return
        }
        
        let itemUrl = ItemURLTextField.text?.isEmpty == false ? ItemURLTextField.text! : "https://placeholder.com"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "name == %@", itemName)
        
        do {
            let items = try context.fetch(fetchRequest)
            if items.first != nil {
                print("Item already exists!")
                showAlert(title: "Error", message: "Item already exists!")
            } else {
                let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
                newItem.setValue(ItemBrand, forKey: "brand")
                newItem.setValue(itemName, forKey: "name")
                newItem.setValue(itemPrice, forKey: "price")
                newItem.setValue(itemCategory, forKey: "category")
                newItem.setValue(itemUrl, forKey: "imageurl")
                newItem.setValue(ItemDescription, forKey: "desc")
                
                do {
                    try context.save()
                    print("Item Registered: \(itemName) | \(itemCategory) | \(itemPrice) | \(itemUrl)|\(ItemDescription)")
                    ItemIDLabel.text = "Registered: \(itemName) | \(itemCategory) | \(itemPrice)"
                    clearInputFields()
                } catch {
                    print("Failed to register item: \(error)")
                    showAlert(title: "Error", message: "Failed to register item.")
                }
            }
        } catch {
            print("Failed to fetch item: \(error)")
            showAlert(title: "Error", message: "Failed to fetch item.")
        }
    }
    
    // MARK: - Navigation to Item List
    @IBAction func goToItemListOnClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let itemListVC = storyboard.instantiateViewController(withIdentifier: "ItemListViewController") as? ItemListViewController {
            itemListVC.userID = userID
            navigationController?.pushViewController(itemListVC, animated: true)
        }
    }
    
    // MARK: - Navigation to Cart List
//    @IBAction func goToCartListOnClick(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let cartVC = storyboard.instantiateViewController(withIdentifier: "CartViewController") as? CartViewController {
//            cartVC.userID = userID
//            cartVC.adminVC = self
//            navigationController?.pushViewController(cartVC, animated: true)
//        }
//    }
    
    // MARK: - Helper Methods
    
    /// Menampilkan alert sederhana
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    /// Membersihkan field input setelah item berhasil ditambahkan
    func clearInputFields() {
        ItemBrandTextField.text = ""
        ItemNameTextField.text = ""
        ItemPriceTextField.text = ""
        ItemURLTextField.text = ""
        ItemCategorySegmentedControl.selectedSegmentIndex = 0
        itemCategory = "Notetaking"
        ItemDescriptionTextField.text = ""
    }
}
