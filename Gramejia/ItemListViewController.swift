import UIKit
import CoreData

class ItemListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var items: [NSManagedObject] = []
    var userID: UUID?
    var defaultID = UUID(uuidString: "888888")
    
    @IBOutlet weak var ItemCountLabel: UILabel!
    @IBOutlet weak var ItemListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Mengatur dataSource dan delegate
        ItemListTableView.dataSource = self
        ItemListTableView.delegate = self
        
        // Mengambil data dari Core Data
        fetchAllItems()
        
        // Reload data tabel
        ItemListTableView.reloadData()
        
        // Mengatur label jumlah item
        ItemCountLabel.text = "Item Count: \(items.count)"
    }
    
    // Fungsi untuk mengambil semua item dari Core Data
    func fetchAllItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        do {
            items = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        print("Tapped on row: \(indexPath.row), data: \(selectedItem)")
        
        amountInputAlert(for: selectedItem.value(forKey: "name") as! String, indexPath: indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Fungsi untuk menampilkan alert input jumlah pembelian
    func amountInputAlert(for item: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Amount", message: "Enter amount of item to buy:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter amount (must be greater than 0)"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let amountText = alert.textFields?.first?.text, let amount = Int(amountText), amount > 0 {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let selectedItem = self.items[indexPath.row]
                
                let purchaseItem = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context)
                purchaseItem.setValue(selectedItem.value(forKey: "name"), forKey: "name")
                purchaseItem.setValue(amount, forKey: "amount")
                purchaseItem.setValue(self.userID, forKey: "userID")
                purchaseItem.setValue(selectedItem.value(forKey: "price"), forKey: "price")
                purchaseItem.setValue(selectedItem.value(forKey: "category"), forKey: "category")
                purchaseItem.setValue(selectedItem.value(forKey: "imageurl"), forKey: "imageurl")
                
                do {
                    try context.save()
                    print("User (\(self.userID ?? self.defaultID!)) added (\(purchaseItem.value(forKey: "amount") ?? 0)) of item (\(purchaseItem.value(forKey: "name") ?? "Unknown")) into cart successfully!")
                } catch {
                    print("Failed to add item into cart: \(error)")
                }
                
            } else {
                self.presentInvalidAmountAlert()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // Fungsi untuk menampilkan alert jumlah invalid
    func presentInvalidAmountAlert() {
        let alert = UIAlertController(title: "Invalid Amount", message: "Please enter a valid number greater than 0.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Fungsi untuk mengkonfigurasi sel tabel
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemTableViewCell else {
            fatalError("Unable to dequeue ItemTableViewCell")
        }
        
        let item = items[indexPath.row]
        
        if let itemName = item.value(forKey: "name") as? String,
           let itemPrice = item.value(forKey: "price") as? Double, // Menggunakan Double
           let itemCategory = item.value(forKey: "category") as? String,
           let itemUrlString = item.value(forKey: "imageurl") as? String,
           let itemImageURL = URL(string: itemUrlString) {
            
            cell.LabelItemCell.text = "\(itemName) (\(itemCategory))\n\(itemPrice) IDR"
            loadImage(from: itemImageURL, into: cell.ImageItemCell)
        }
        
        return cell
    }
    
    // MARK: - Swipe Actions
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editItem(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteItem(at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeActions
    }
    
    // Fungsi untuk mengedit item
    func editItem(at indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Item", message: "Update item details", preferredStyle: .alert)
        
        // Menambahkan text fields untuk mengedit
        alert.addTextField { textField in
            textField.text = item.value(forKey: "name") as? String
        }
        alert.addTextField { textField in
            textField.text = "\(item.value(forKey: "price") as? Double ?? 0)"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.text = item.value(forKey: "category") as? String
        }
        alert.addTextField { textField in
            textField.text = item.value(forKey: "imageurl") as? String
        }
        
        // Menambahkan tombol save
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let name = alert.textFields?[0].text,
                  let priceText = alert.textFields?[1].text,
                  let category = alert.textFields?[2].text,
                  let price = Double(priceText),
                  let imageUrl = alert.textFields?[3].text else { return }
            
            // Memperbarui item di Core Data
            item.setValue(name, forKey: "name")
            item.setValue(price, forKey: "price")
            item.setValue(category, forKey: "category")
            item.setValue(imageUrl, forKey: "imageurl")
            
            // Menyimpan konteks
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                try context.save()
                self?.ItemListTableView.reloadData() // Refresh tabel view
            } catch {
                print("Failed to update item: \(error)")
            }
        }
        
        // Menambahkan tombol cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        // Menampilkan alert
        present(alert, animated: true, completion: nil)
    }
    
    // Fungsi untuk memuat gambar dari URL
    func loadImage(from url: URL, into imageView: UIImageView) {
        imageView.image = nil
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image: \(error?.localizedDescription ?? "No Error Description")")
                return
            }
            
            if let itemImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = itemImage
                }
            }
        }
        task.resume()
    }
  
    // Fungsi untuk menghapus item
    func deleteItem(at indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let itemToDelete = items[indexPath.row]
        
        context.delete(itemToDelete)
        
        do {
            try context.save()
            items.remove(at: indexPath.row)
            ItemListTableView.deleteRows(at: [indexPath], with: .automatic)
            ItemCountLabel.text = "Item Count: \(items.count)"
        } catch {
            print("Failed to delete item: \(error.localizedDescription)")
        }
    }
}
