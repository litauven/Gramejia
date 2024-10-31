import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    
    var transactions: [NSManagedObject] = []
    
    @IBOutlet weak var Table: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        transactions = []
        fetchTransactionHistory()
        Table.reloadData()
        updateTotalAmountAndCount()
        totalCountLabel.text = String(transactions.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        transactions = []
        fetchTransactionHistory()
        Table.reloadData()
        updateTotalAmountAndCount()
        totalCountLabel.text = String(transactions.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Table.dataSource = self
        Table.delegate = self
        fetchTransactionHistory()
        
        // Update total count and amount
        updateTotalAmountAndCount()
    }
    
    @IBAction func clearHistoryOnClick(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to clear your history?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequestHistory = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
            fetchRequestHistory.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
            
            do {
                
                let histories = try context.fetch(fetchRequestHistory)
                
                for history in histories {
                    context.delete(history)
                }
                
                try context.save()
                
                print("Transaction history for user \(UserSession.shared.userID!) successfully cleared.")
                
                transactions.removeAll()
                Table.reloadData()
                updateTotalAmountAndCount()
                totalCountLabel.text = String(transactions.count)
            } catch {
                print("Failed to delete transaction history: \(error)")
            }
            
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    // Fetch transaction history from Core Data
    func fetchTransactionHistory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
        fetchRequest.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
        
        do {
            transactions = try context.fetch(fetchRequest)
            Table.reloadData()
        } catch {
            print("Failed to fetch transaction history: \(error)")
        }
    }
    
    // Update total amount and total count labels
    func updateTotalAmountAndCount() {
        var totalAmount = 0.0
        var totalCount = 0
        
        for transaction in transactions {
            if let price = transaction.value(forKey: "price") as? Double,
               let amount = transaction.value(forKey: "amount") as? Int {
                totalAmount += price * Double(amount)
                totalCount += amount
            }
        }
        
        totalAmountLabel.text = "\(Int(totalAmount)) IDR"
        totalCountLabel.text = "\(Int(totalCount))"
    }
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        
        return cell
    }
}
