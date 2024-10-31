import UIKit
import CoreData

class DetailSheetViewController: UIViewController {
    var itemName: String?
    var itemImageUrl: String?
    var itemDescription: String?

    @IBOutlet weak var Desc_Label: UILabel!
    @IBOutlet weak var ImageDetail: UIImageView!
    @IBOutlet weak var Namelabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display the received data
        Namelabel.text = itemName
        Desc_Label.text = itemDescription
        
        if let imageUrl = itemImageUrl {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.ImageDetail.image = image
                }
            }
        }
    }

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
}
