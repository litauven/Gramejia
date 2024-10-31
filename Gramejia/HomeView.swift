import UIKit
import CoreData

class HomeView: UIViewController {
    
    @IBOutlet weak var RoundedBorderView: UIView!
    
    @IBOutlet weak var category1Button: UIButton!
    @IBOutlet weak var category2Button: UIButton!
    @IBOutlet weak var category3Button: UIButton!
    @IBOutlet weak var category4Button: UIButton!
    
    @IBOutlet weak var imageUsed: UIImageView!
    @IBOutlet weak var LeftOut: UIButton!
    @IBOutlet weak var RightOut: UIButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var userID: UUID?
    var username = ""
    
    var timer: Timer?
    var currentI = 0
    let arrayI = [UIImage(named: "1 1"), UIImage(named: "2 1"), UIImage(named: "3 1")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let tabBar = self.tabBarController as? CustomTabControllerViewController {
//            self.userID = UserSession.shared.userID
//            self.username = tabBar.username ?? "user?"
//        }
        
        print("Current UserID: \(String(describing: self.userID))")
        
        self.userID = UserSession.shared.userID
        self.username = UserSession.shared.username ?? "user?"
        
        usernameLabel.text = self.username
        
        imageUsed.image = arrayI[currentI]
        LeftOut.isEnabled = false
        radius20(to: RoundedBorderView)
        addShadow(to: RoundedBorderView)

        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameLabel.text = UserSession.shared.username
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startImageCarousel() // Mulai carousel saat tampilan muncul
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate() // Stop the timer when the view is disappearing
    }

    @IBAction func Category1Button(_ sender: UIButton) {
        performSegue(withIdentifier: "accessory", sender: sender)
    }
        
    @IBAction func Category2Button(_ sender: UIButton) {
        performSegue(withIdentifier: "painting", sender: sender)
    }
        
    @IBAction func Category3Button(_ sender: UIButton) {
        performSegue(withIdentifier: "notetaking", sender: sender)
    }
    
    @IBAction func Category4Button(_ sender: UIButton) {
        performSegue(withIdentifier: "general", sender: sender) // Or nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController, let destinationVC = navigationController.topViewController as? ItemViewCellViewController {
            if segue.identifier == "notetaking" {
                    destinationVC.selectedCategory = "Notetaking"
            } else if segue.identifier == "painting" {
                    destinationVC.selectedCategory = "Painting"
            } else if segue.identifier == "accessory" {
                    destinationVC.selectedCategory = "Accessory"
            } else if segue.identifier == "general" {
                    destinationVC.selectedCategory = nil
            }
        }
        
    }
    
    @IBAction func LeftAction(_ sender: Any) {
// Stop the timer
        currentI = (currentI - 1 + arrayI.count) % arrayI.count
        imageUsed.image = arrayI[currentI]
        updateButtonStates()
    }
   
    @IBAction func RightAction(_ sender: Any) {
 // Stop the timer
        currentI = (currentI + 1) % arrayI.count
        imageUsed.image = arrayI[currentI]
        updateButtonStates()
    }
    
    @objc func showNextImage() {
        currentI = (currentI + 1) % arrayI.count
        
        // Menambahkan animasi transisi
        UIView.transition(with: imageUsed, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageUsed.image = self.arrayI[self.currentI]
        }, completion: nil)
        
        updateButtonStates()
    }
    
    func startImageCarousel() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(showNextImage), userInfo: nil, repeats: true)
    }
    
    func setupUI() {
        RoundedBorderView.roundedCorners([.topLeft, .topRight], radius: 37)
        
        for button in [category1Button, category2Button, category3Button, category4Button] {
            radius20(to: button!)
            addShadow(to: button!)
        }
    }
    
    func updateButtonStates() {
        LeftOut.isEnabled = currentI > 0
        RightOut.isEnabled = currentI < arrayI.count - 1
    }

    func radius20(to border: UIView) {
        border.roundedCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 20)
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
    }

}

extension UIView {
    func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()
            if corners.contains(.topLeft) {
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if corners.contains(.topRight) {
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if corners.contains(.bottomLeft) {
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
        } else {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    
}
