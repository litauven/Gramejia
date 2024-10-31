//
//  CartViewCell.swift
//  Gramejia
//
//  Created by prk on 08/10/24.
//

import UIKit

class CartViewCell: UITableViewCell {
    
    @IBOutlet weak var LblName: UILabel!
    @IBOutlet weak var cartImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
