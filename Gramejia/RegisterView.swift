import UIKit
import CoreData

class RegisterView: UIViewController {
    
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        // Cek apakah passwordTextField sedang tersembunyi (secure text entry)
        let isSecure = passwordTextField.isSecureTextEntry
        
        // Toggle antara true dan false
        passwordTextField.isSecureTextEntry = !isSecure
        
        // Ubah ikon tombol tergantung pada kondisi password
        let eyeIcon = isSecure ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill")
        sender.setImage(eyeIcon, for: .normal)
    }
    
    @IBAction func registeButtonOnClick(_ sender: Any) {
        
        guard let username = usernameTextField.text, let password = passwordTextField.text, let email = emailTextView.text else {
            print("All data must not be empty!")
            //todo: alert message here
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: "Error", message: "Please enter a valid email address.")
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try context.fetch(fetchRequest)
            if users.first != nil{
                print("User Already Exits!")
                
                let alert = UIAlertController(title: "Error", message: "This username is already in use!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
                let adminIDGen = NSEntityDescription.insertNewObject(forEntityName: "Admin", into: context)
                newUser.setValue(username, forKey: "username")
                newUser.setValue(password, forKey: "password")
                newUser.setValue(email, forKey: "email")
                
                let newID = UUID()
                print("New userID: \(newID)")
                
                adminIDGen.setValue(newID, forKey: "genUID")
                newUser.setValue(newID, forKey: "userID")
                newUser.setValue(0, forKey: "balance")
                
                do {
                    try context.save()
                    print("User registered successfully: (\(username)|\(password)")
                    
                    if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } catch {
                    print("Failed to register user: \(error)")
                }
            }
        } catch {
            print("Register error: \(error)")
        }
        
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @IBOutlet weak var RoundedCorner: UIView!
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
}
