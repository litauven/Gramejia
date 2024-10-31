import UIKit
import CoreData

class DetailPageView: UIViewController {

    @IBOutlet weak var ViewBorder: UIView!
    @IBOutlet weak var LBL: UILabel! // item name
    @IBOutlet weak var IMG: UIImageView!
    @IBOutlet weak var PRICE: UILabel! // item price
    
    @IBOutlet weak var DESC: UILabel! // item description
    @IBOutlet weak var amountLBL: UILabel! // item amount
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func readMoreOnClick(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailSheetViewController") as! DetailSheetViewController

        // Pass the necessary data to the DetailSheetViewController
        detailVC.itemImageUrl = mimgURL
        detailVC.itemName = mLbl
        detailVC.itemDescription = mDesc
        
        detailVC.modalPresentationStyle = .pageSheet
        
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(detailVC, animated: true, completion: nil)
    }

    
    var mimgURL: String?  // Instead of UIImage, we'll pass the image URL
    var mLbl: String?
    var mDesc: String?
    var mPrice: Double?
    var userID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userID = UserSession.shared.userID
        
        ViewBorder.layer.cornerRadius = 30
        addShadow(to: ViewBorder)
        
        // Set label and price
        LBL.text = mLbl
        if let price = mPrice {
            PRICE.text = "\(Int(price)) IDR"
        }
        DESC.text = mDesc
        
        // Download and set the image from URL
        if let url = mimgURL {
            downloadImage(from: url) { image in
                DispatchQueue.main.async {
                    self.IMG.image = image
                }
            }
        }

        amountLBL.text = "0"
        stepper.stepValue = 1.0
    }
    
    @IBAction func stepperClicked(_ sender: UIStepper) {
        amountLBL.text = Int(sender.value).description
    }
    
    // Helper function to download image from URL
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
    
    @IBAction func checkOutOnClick(_ sender: Any) {
        
        let itemName = LBL.text, itemDesc = DESC.text, priceText = PRICE.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(), itemPrice = Int(priceText ?? "0")
        
        if let amount = Int(amountLBL.text ?? "0"), amount > 0 {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let cartItem = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context)
            cartItem.setValue(itemName, forKey: "name")
            cartItem.setValue(itemDesc, forKey: "desc")
            cartItem.setValue(itemPrice, forKey: "price")
            cartItem.setValue(amount, forKey: "amount")
            cartItem.setValue(UserSession.shared.userID, forKey: "userID")
            cartItem.setValue(mimgURL, forKey: "imageurl")
            
            do {
                try context.save()
                print("\(amount) Item (\(itemName ?? "404")) successfully added to (\(userID!))'s cart")
            } catch {
                print("Failed to add to cart: \(error)")
            }
            
        } else {
            let alert = UIAlertController(title: "Invalid", message: "Please set your desired amount", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // Adds shadow effect to the provided view
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = false
    }
}
