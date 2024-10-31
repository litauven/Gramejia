import UIKit
import CoreData

class account_SettingsViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var balance: Int?
    
    @IBAction func saveOnClick(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to change your account data?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequestUser = NSFetchRequest<NSManagedObject>(entityName: "User")
            fetchRequestUser.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
            
            let username = self.usernameTextField.text! as String
            let email = self.emailTextField.text! as String
            let password = self.passwordTextField.text! as String
            
            do {
                let users = try context?.fetch(fetchRequestUser)
                
                if let user = users?.first {
                    
                    user.setValue(username, forKey: "username")
                    user.setValue(email, forKey: "email")
                    user.setValue(password, forKey: "password")
                    
                    UserSession.shared.username = username
                    
                    try context?.save()
                    
                }
            } catch {
                print("todo: Failed to change account information alert")
            }
            
            if let navigationController = self.navigationController {
                for controller in navigationController.viewControllers {
                    if controller is ProfileView {
                        navigationController.popToViewController(controller, animated: true)
                        return
                    }
                }
            }
            
            self.dismiss(animated: true)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
        
    }
    
    @IBOutlet weak var accset: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transactionCountLabel: UILabel!
    
    var transaction: [NSManagedObject] = []
    var users: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radius10(to: accset)
        addShadow(to: accset)
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequestTransaction = NSFetchRequest<NSManagedObject>(entityName: "Transaction")
        let fetchRequestUser = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequestTransaction.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
        fetchRequestUser.predicate = NSPredicate(format: "userID == %@", UserSession.shared.userID! as CVarArg)
        
        do {
            transaction = try context.fetch(fetchRequestTransaction)
            transactionCountLabel.text = String(transaction.count)
        } catch {
            print("Failed to load transaction count")
        }
        
        balanceLabel.text = String(balance ?? 404) as String
        
        do {
            users = try context.fetch(fetchRequestUser)
            if let user = users.first {
                    usernameTextField.text = UserSession.shared.username
                emailTextField.text = user.value(forKey: "email") as? String
                    passwordTextField.text = user.value(forKey: "password") as? String
            }
        } catch {
            print("unable to load user data")
        }
    }
    
    func radius10(to border: UIView) {
        border.roundedCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
    }
    
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
    }
    

}
