//
//  BooksTableViewCell.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/13/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit

class BooksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
