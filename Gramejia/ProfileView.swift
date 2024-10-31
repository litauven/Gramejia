import UIKit
import CoreData

class ProfileView: UIViewController {

    var userID: UUID?
    var username: String = "user?"
    var balance: Int?

    @IBAction func TopUpBTN(_ sender: UIButton) {
        // Create the alert controller
            let alertController = UIAlertController(title: "Enter your top up amount", message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "Top Up Amount ( > 10000 IDR)"
                textField.keyboardType = .numberPad
            }

               // Add an action to the alert controller
            let saveAction = UIAlertAction(title: "Top Up", style: .default) { action in
                   // Handle the action when the "Save" button is tapped
                if let amountText = alertController.textFields?.first?.text, let topUpBalance = Int(amountText), topUpBalance > 10000 {
                       
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                       
                    let fetchRequestBalance = NSFetchRequest<NSManagedObject>(entityName: "User")
                    fetchRequestBalance.predicate = NSPredicate(format: "userID == %@", self.userID! as CVarArg)
                       
                    do {
                        let users = try context.fetch(fetchRequestBalance)
                           
                        if let user = users.first {
                               
                            let currentBalance = user.value(forKey: "balance") as? Int
                            print("Current balance: \(currentBalance ?? 404)")
                            let newBalance = (currentBalance ?? 0) + topUpBalance
                            print("newBalance: \(newBalance)")
                            user.setValue(newBalance, forKey: "balance")
                               
                            try context.save()
                               
                            self.balanceLabel.text = "\(newBalance) IDR"
                            print("todo: Balance topped up alert")
                               
                        }
                    } catch {
                        print("todo: Failed to top up alert")
                    }
                      
                } else {
                       
                    let alert = UIAlertController(title: "Invalid", message: "Please enter an amount greater than 10000 IDR", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                       
                }
            }
        alertController.addAction(saveAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var viewRounded2: UIView!
    @IBOutlet weak var BalanceView: UIView!
    @IBOutlet weak var TopUpBTN: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestBalance = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequestBalance.predicate = NSPredicate(format: "userID == %@", userID! as CVarArg)
        
        do {
            let users = try context.fetch(fetchRequestBalance), user = users.first
            if user == nil {
                print("User invalid!")
                return
            } else {
                usernameLabel.text = user!.value(forKey: "username") as? String
                balanceLabel.text = "\(user?.value(forKey: "balance") as! Int) IDR"
                balance = user?.value(forKey: "balance") as? Int
            }
        } catch {
            print("Failed to load balance: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestBalance = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequestBalance.predicate = NSPredicate(format: "userID == %@", userID! as CVarArg)
        
        do {
            let users = try context.fetch(fetchRequestBalance), user = users.first
            if user == nil {
                print("User invalid!")
                return
            } else {
                balanceLabel.text = "\(user?.value(forKey: "balance") as! Int) IDR"
            }
        } catch {
            print("Failed to load balance: \(error)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addShadow2(to: BalanceView)
        addShadow2(to: viewRounded2)
        radius10(to: BalanceView)
        radius10(to: viewRounded2)
        radius10(to: TopUpBTN)
        
        self.userID = UserSession.shared.userID
        self.username = UserSession.shared.username ?? "user?"
        
//        if let tabBar = self.tabBarController as? CustomTabControllerViewController {
//            self.userID = UserSession.shared.userID
//            self.username = tabBar.username!
//        }
        
        print("Current UserID: \(String(describing: self.userID))")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestBalance = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequestBalance.predicate = NSPredicate(format: "userID == %@", userID! as CVarArg)
        
        do {
            let users = try context.fetch(fetchRequestBalance), user = users.first
            if user == nil {
                print("User invalid!")
                return
            } else {
                balanceLabel.text = "\(user?.value(forKey: "balance") as! Int) IDR"
            }
        } catch {
            print("Failed to load balance: \(error)")
        }

        usernameLabel.text = self.username
        
    }
    
    @IBAction func accountSettingOnClick(_ sender: Any) {
//        performSegue(withIdentifier: "toAccountSetting", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAccountSetting" {
            if let nextVC = segue.destination as? account_SettingsViewController {
                nextVC.balance = balance
            }
        }
    }
    
    func radius20(to border: UIView) {
        border.roundedCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 60)
    }
    
    func radius10(to border: UIView) {
        border.roundedCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
    }
    
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
    }
    
    func addShadow2(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
    }

}


extension UIView {
//    func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
//        if #available(iOS 11, *) {
//            var cornerMask = CACornerMask()
//            if corners.contains(.topLeft) {
//                cornerMask.insert(.layerMinXMinYCorner)
//            }
//            if corners.contains(.topRight) {
//                cornerMask.insert(.layerMaxXMinYCorner)
//            }
//            if corners.contains(.bottomLeft) {
//                cornerMask.insert(.layerMinXMaxYCorner)
//            }
//            if corners.contains(.bottomRight) {
//                cornerMask.insert(.layerMaxXMaxYCorner)
//            }
//            self.layer.cornerRadius = radius
//            self.layer.maskedCorners = cornerMask
//        } else {
//            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            self.layer.mask = mask
//        }
//    }
}
