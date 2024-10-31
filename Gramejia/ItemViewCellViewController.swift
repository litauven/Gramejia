    import UIKit
    import CoreData

    class ItemViewCellViewController: UIViewController {
        
        @IBOutlet weak var CollectionView: UICollectionView!
    //    var images: [String] = ["Tas","2","3"]
    //    var names: [String] = ["Tas","Gabut","s"]
        
        var itemNames: [String] = []
        var itemPrices: [Double] = []
        var itemImagesUrl: [String] = []
        var itemDescription : [String] = []
        
        var selectedCategory: String?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            CollectionView.collectionViewLayout = UICollectionViewFlowLayout()
            fetchData()
            CollectionView.delegate = self
            CollectionView.dataSource = self
            
            let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        @objc func backButtonTapped() {
            self.dismiss(animated: true, completion: nil)
        }
        
        func fetchData() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
            
            do {
                let items = try context.fetch(fetchRequest)
                
                for item in items {
                    if let itemName = item.value(forKey: "name") as? String,
                       let itemDesc = item.value(forKey: "desc") as? String,
                       let itemPrice = item.value(forKey: "price") as? Double,
                       let imageUrl = item.value(forKey: "imageurl") as? String {
                        
                        // Filter items based on the selected category
                        if let selectedCategory = selectedCategory {
                            if item.value(forKey: "category") as? String == selectedCategory {
                                itemNames.append(itemName)
                                itemPrices.append(itemPrice)
                                itemImagesUrl.append(imageUrl)
                                itemDescription.append(itemDesc)
                            }
                        } else {
                            // If no category selected, fetch all items
                            itemNames.append(itemName)
                            itemPrices.append(itemPrice)
                            itemImagesUrl.append(imageUrl)
                            itemDescription.append(itemDesc)
                        }
                    }
                }

            } catch {
                print("Failed to fetch items: \(error)")
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

    extension ItemViewCellViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return itemNames.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {

                    layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 10, right: 5) // Padding untuk semua sisi
                    

                }
            // Mengatur corner radius
               cell.layer.cornerRadius = 10
               cell.layer.masksToBounds = false  //  Agar shadow bisa terlihat dengan baik

               // Mengatur shadow (bayangan)
               cell.layer.shadowColor = UIColor.black.cgColor  // Warna shadow
               cell.layer.shadowOffset = CGSize(width: 0, height: 5)  // Posisi shadow (geserannya), bisa disesuaikan
               cell.layer.shadowOpacity = 0.3  // Opasitas shadow (transparansi), antara 0 (tidak terlihat) dan 1 (sepenuhnya terlihat)
               cell.layer.shadowRadius = 5 // Radius untuk soft edge shadow, semakin besar semakin blur
               cell.layer.borderColor = UIColor.white.cgColor  // Menentukan warna border
               cell.layer.borderWidth = 1
            cell.backgroundColor = UIColor.white
               // Mengatur label dan image sesuai dengan data
               cell.NameLabel.text = itemNames[indexPath.row]
            cell.PriceLabel.text = "\(Int(itemPrices[indexPath.row])) IDR"
            
            let imageUrl = itemImagesUrl[indexPath.row]
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    cell.ItemImage.image = image
                }
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.size.width - 20) / 2
            let height = width * 1.2
            return CGSize(width: width, height: height)
            
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Check if index is within bounds
            guard indexPath.row < itemNames.count,
                  indexPath.row < itemPrices.count,
                  indexPath.row < itemImagesUrl.count,
                  indexPath.row < itemDescription.count else {
                return // Exit if out of bounds
            }
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailPageView") as! DetailPageView
            
            // Pass data to DetailPageView
            vc.mimgURL = itemImagesUrl[indexPath.row]
            vc.mLbl = itemNames[indexPath.row]
            vc.mPrice = itemPrices[indexPath.row]
            vc.mDesc = itemDescription[indexPath.row]  // Pass description
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

