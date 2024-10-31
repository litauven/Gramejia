import UIKit
import CoreData

class TransactionCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var itemTotalPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // Optionally, add a method to configure the cell with transaction data
    func configure(with transaction: NSManagedObject) {
        if let itemName = transaction.value(forKey: "name") as? String,
           let price = transaction.value(forKey: "price") as? Int,
           let amount = transaction.value(forKey: "amount") as? Int {
            itemNameLabel.text = itemName
            priceLabel.text = "\(price) IDR"
            amountLabel.text = "(\(amount)) pcs"
            itemTotalPriceLabel.text = "\(amount * price) IDR"
        }
        if let imageUrlString = transaction.value(forKey: "imageurl") as? String,
           let imageUrl = URL(string: imageUrlString) {
            // Load image asynchronously
            loadImage(from: imageUrl)
        }
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.itemImageView.image = image
                }
            }
        }
        task.resume()
    }
}
