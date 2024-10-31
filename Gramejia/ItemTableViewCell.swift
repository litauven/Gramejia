//
//  ItemTableViewCell.swift
//  Gramejia
//
//  Created by prk on 18/10/24.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var ImageItemCell: UIImageView!
    @IBOutlet weak var LabelItemCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
