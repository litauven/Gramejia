import UIKit

class CustomTabControllerViewController: UITabBarController {
    
//    var userID: UUID?
//    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Menambahkan shadow di atas tab bar
              let topShadow = UIView()
              topShadow.frame = CGRect(x: 0, y: self.tabBar.frame.origin.y - 10, width: self.tabBar.bounds.width, height: 10) // Sesuaikan tinggi shadow
              topShadow.backgroundColor = UIColor.clear
              
              // Menambahkan shadow
              topShadow.layer.shadowColor = UIColor.black.cgColor
              topShadow.layer.shadowOffset = CGSize(width: 0, height: 2) // Offset sedikit ke bawah
              topShadow.layer.shadowOpacity = 0.7 // Naikkan opacity agar lebih terlihat
              topShadow.layer.shadowRadius = 5 // Radius shadow
              topShadow.layer.cornerRadius = 10
              
              // Tambahkan shadow ke view utama
              self.view.addSubview(topShadow)
              self.view.bringSubviewToFront(self.tabBar)
        
    }
}
