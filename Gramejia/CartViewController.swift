import UIKit
import CoreData

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewCellDelegate{

    var userID: UUID?
    var username: String?
    
    var items: [NSManagedObject] = []
    var users: [NSManagedObject] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func loadImage(from url: URL, into imageView: UIImageView) {
        
        imageView.image = nil
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in guard let data = data, error == nil else {
            print("Failed to load image: \(error?.localizedDescription ?? "No error desc")")
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Table.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! TableViewCell

        let item = items[indexPath.row]
        
        if let itemAmount = item.value(forKey: "amount") as? Int {
            cell.value = itemAmount
        }
        
        if let itemName = item.value(forKey: "name") as? String,
           let itemPrice = item.value(forKey: "price") as? Int,
           let itemAmount = item.value(forKey: "amount") as? Int,
           let itemUrlString = item.value(forKey: "imageurl") as? String,
           let itemImage = URL(string: itemUrlString) {
            
            cell.NameItem.text = "\(itemName)"
            cell.Price.text = "\(itemPrice)"
            loadImage(from: itemImage, into: cell.IMG)
            
        }
        
        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 2)
        let shadowOpacity: Float = 0.3
        let shadowRadius: CGFloat = 4

        // Set layer properties untuk shadow
        cell.layer.shadowColor = shadowColor.cgColor
        cell.layer.shadowOffset = shadowOffset
        cell.layer.shadowOpacity = shadowOpacity
        cell.layer.shadowRadius = shadowRadius

        // Agar shadow tidak keluar dari bounds
        cell.layer.masksToBounds = false

        // Optional: Set rounded corners untuk cell
        let cornerRadius: CGFloat = 8
        cell.layer.cornerRadius = cornerRadius
        
        cell.delegate = self
        
        return cell
    }
    
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBAction func checkOutOnClick(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to check out (\(items.count)) item(s)?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequestBalance = NSFetchRequest<NSManagedObject>(entityName: "User")
            fetchRequestBalance.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
            
            do {
                let users = try context.fetch(fetchRequestBalance)
                
                if let user = users.first {
                    let currentBalance = user.value(forKey: "balance") as? Int ?? 0
                    let totalCartAmount = self.calculateTotalPrice()
                    let totalItemAmount = self.items.count
                    
                    if currentBalance >= totalCartAmount {
                        // Deduct from balance
                        let newBalance = currentBalance - totalCartAmount
                        user.setValue(newBalance, forKey: "balance")
                        
                        // Save transaction details
                        self.saveTransaction(cartItems: self.items)
                        
                        // Clear cart
                        self.checkOut()
                        
                        try context.save()
                        
                        let successAlert = UIAlertController(title: "Thank You", message: "You successfully checked out (\(totalItemAmount)) item(s)", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(successAlert, animated: true)
                    } else {
                        let insufficientAlert = UIAlertController(title: "Error", message: "Insufficient balance!", preferredStyle: .alert)
                        insufficientAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(insufficientAlert, animated: true)
                    }
                }
            } catch {
                print("Invalid user: \(error)")
            }
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

    func saveTransaction(cartItems: [NSManagedObject]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        for item in cartItems {
            let transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: context)
            
            // Transfer cart item data to transaction
            if let itemName = item.value(forKey: "name") as? String,
               let itemPrice = item.value(forKey: "price") as? Int,
               let itemAmount = item.value(forKey: "amount") as? Int,
               let itemImage = item.value(forKey: "imageurl") as? String {
                
                transaction.setValue(itemName, forKey: "name")
                transaction.setValue(itemPrice, forKey: "price") // stored as Int for price
                transaction.setValue(itemAmount, forKey: "amount")
                transaction.setValue(itemImage, forKey: "imageurl")
                transaction.setValue(UserSession.shared.userID, forKey: "userID")
            }
        }
        
        do {
            try context.save()
            print("Transaction saved successfully.")
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    func checkOut() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        for item in items {
            context.delete(item)
        }
        
        do {
            try context.save()
            items.removeAll()
            Table.reloadData()
            countLabel.text = String(items.count)
            updateTotalPriceLabel()
        } catch {
            print("Failed to clear cart: \(error.localizedDescription)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = []
        
        Table.dataSource = self
        Table.separatorStyle = .singleLine
        Table.delegate = self
        
        self.userID = UserSession.shared.userID
        self.username = UserSession.shared.username
        
        fetchCartItems()
        
        self.Table.reloadData()
        updateTotalPriceLabel()
        print("todo: Implement total price label")
        self.Table.reloadData()
        updateTotalPriceLabel()
        countLabel.text = String(items.count)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        items = []
        
        fetchCartItems()
        Table.reloadData()
        updateTotalPriceLabel()
        countLabel.text = String(items.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        items = []
        
        fetchCartItems()
        Table.reloadData()
        updateTotalPriceLabel()
        countLabel.text = String(items.count)
    }
    
    func fetchCartItems() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestItem = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        
        if let userID = self.userID {
            fetchRequestItem.predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        }
        
        do {
            items = try context.fetch(fetchRequestItem)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func updateTotalPriceLabel() {
        let totalPrice = calculateTotalPrice()
        totalLabel.text = "\(totalPrice) IDR"
    }
    
    func calculateTotalPrice() -> Int {
        var totalPrice = 0
        for item in items {
            if let itemPrice = item.value(forKey: "price") as? Int,
               let itemAmount = item.value(forKey: "amount") as? Int {
                totalPrice += itemPrice * itemAmount
            }
        }
        return totalPrice
    }

    func didUpdateItemAmount(cell: TableViewCell, newAmount: Int) {
        if let indexPath = Table.indexPath(for: cell) {
            let item = items[indexPath.row]
            item.setValue(newAmount, forKey: "amount")
            saveContext()
            updateTotalPriceLabel()
        }
    }
    
    func didDeleteItem(cell: TableViewCell) {
        if let indexPath = Table.indexPath(for: cell) {
            items.remove(at: indexPath.row)
            Table.deleteRows(at: [indexPath], with: .automatic)
            
            self.Table.reloadData()
            updateTotalPriceLabel()
            countLabel.text = String(items.count)
        }
    }
    
    func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            print("Failed to save updated item amount: \(error)")
        }
    }

}

