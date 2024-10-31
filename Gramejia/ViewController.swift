import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    var userID: UUID?
    var username: String?
    var loginSuccess: Bool = false
    
    @IBOutlet weak var RoundedCorner: UIView!
    
    
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        // Cek apakah passwordTextField sedang tersembunyi (secure text entry)
        let isSecure = passwordTextField.isSecureTextEntry
        
        // Toggle antara true dan false
        passwordTextField.isSecureTextEntry = !isSecure
        
        // Ubah ikon tombol tergantung pada kondisi password
        let eyeIcon = isSecure ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill")
        sender.setImage(eyeIcon, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        radius20(to: RoundedCorner)
        addShadow(to: RoundedCorner)
    }
    
    func radius20(to border: UIView) {
        border.roundedCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 70)
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = false
    }
    
    @IBAction func loginOnClick(_ sender: Any) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password.")
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            if email == "admin" && password == "admin" {
                // Navigate to Admin View Controller
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let adminVC = storyboard.instantiateViewController(withIdentifier: "AdminViewController") as? AdminViewController {
                    navigationController?.pushViewController(adminVC, animated: true)
                }
            } else {
                // Fetch User from Core Data
                let users = try context.fetch(fetchRequest)
                
                if let user = users.first, let savedPassword = user.value(forKey: "password") as? String {
                    if savedPassword == password {
                        print("Login successful! | UUID: \(user.value(forKey: "userID") ?? "invalid ID")")
                        
                        userID = user.value(forKey: "userID") as? UUID
                        username = user.value(forKey: "username") as? String
                        
                        UserSession.shared.userID = self.userID
                        UserSession.shared.username = self.username
                        
                        performSegue(withIdentifier: "loginSuccess", sender: self)
                    } else {
                        showAlert(title: "Error", message: "Incorrect password.")
                    }
                } else {
                    showAlert(title: "Error", message: "User not found.")
                }
            }
        } catch {
            print("Login failed: \(error)")
            showAlert(title: "Error", message: "Login failed due to a system error.")
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginSuccess" {
            return userID != nil
        }
        return true
    }
}
