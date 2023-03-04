//
//  BookTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.01.23.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookCoverImage: UIImageView! {
        didSet {
            bookCoverImage.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    var imageID: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookCoverImage.image = nil
        bookTitleLabel.text = nil
        authorLabel.text = nil
    }
}
