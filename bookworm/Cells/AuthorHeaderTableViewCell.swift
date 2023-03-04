//
//  AuthorHeaderTableViewCell.swift
//  bookworm
//
//  Created by Elena Varbanova on 19.02.23.
//

import UIKit

class AuthorHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var authorPhotoImage: UIImageView! {
        didSet {
            authorPhotoImage.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var birthdayLabel: UILabel!
    
}
