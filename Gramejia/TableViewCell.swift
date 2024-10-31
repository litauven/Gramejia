import UIKit
import CoreData

protocol TableViewCellDelegate: AnyObject {
    func didUpdateItemAmount(cell: TableViewCell, newAmount: Int)
    func didDeleteItem(cell: TableViewCell)
}

class TableViewCell: UITableViewCell{

    @IBOutlet weak var Price: UILabel! // cart item price
    @IBOutlet weak var NameItem: UILabel! // cart item name
    @IBOutlet weak var IMG: UIImageView! // cart image
    @IBOutlet weak var valueLabel: UILabel! // cart item amount
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    weak var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var value = 0 {
            didSet {
                valueLabel.text = "\(value)"
            }
        }
    
    func makeButtonCircular(button: UIButton) {
        let width = button.frame.size.width
        let height = button.frame.size.height
        button.layer.cornerRadius = height / 2  // Set corner radius sesuai dengan tinggi untuk membuat tombol oval
        button.clipsToBounds = true  // Memastikan konten tombol sesuai dengan corner radius
    }
        
        // IBAction untuk tombol "+"
        @IBAction func increaseValue(_ sender: UIButton) {
            value += 1
            print("todo: Update amount every click")
            // function to update amount everytime is clicked
            delegate?.didUpdateItemAmount(cell: self, newAmount: value)
        }
        
        // IBAction untuk tombol "-"
        @IBAction func decreaseValue(_ sender: UIButton) {
            if value > 0 {
                value -= 1
            }
            // function to update amount everytime is clicked
            if value == 0 {
                deleteItemFromCart()
                delegate?.didDeleteItem(cell: self)
            }
            delegate?.didUpdateItemAmount(cell: self, newAmount: value)
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        makeButtonCircular(button: plusButton)
        makeButtonCircular(button: minusButton)
        // Configure the view for the selected state
    }
    
    func updateItemAmount(newAmount: Int) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestItem = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        fetchRequestItem.predicate = NSPredicate(format: "name == %@", NameItem.text!)
        
        do {
            let items = try context.fetch(fetchRequestItem)
            if let item = items.first {
                item.setValue(newAmount, forKey: "amount")
                try context.save()
                print("Item \(item.value(forKey: "name") ?? 404) amount updated to \(newAmount)")
            } else {
                print("Item \(NameItem.text ?? "404") not found")
            }
        } catch {
            print("Failed to update item amount: \(error)")
        }
        
    }
    
    func deleteItemFromCart() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestItem = NSFetchRequest<NSManagedObject>(entityName: "Cart")
        fetchRequestItem.predicate = NSPredicate(format: "name == %@", NameItem.text!)
        
        do {
            let items = try context.fetch(fetchRequestItem)
            if let item = items.first {
                context.delete(item)
                try context.save()
                print("Item \(NameItem.text ?? "404") deleted from cart")
            } else {
                print("Item \(NameItem.text ?? "404") not found")
            }
        } catch {
            print("Failed to delete item: \(error)")
        }
        
    }

}
